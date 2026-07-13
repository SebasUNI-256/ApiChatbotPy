from contextlib import asynccontextmanager
from datetime import date
import re
from typing import Any

import pyodbc
from fastapi import FastAPI, HTTPException, Request, WebSocket, WebSocketDisconnect
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, field_validator
from starlette.middleware.sessions import SessionMiddleware

from app.application.chat_use_case import ResolveChatMessageUseCase
from app.domain.entities import ChatResponse
from app.infrastructure.memory_rule_cache import InMemoryRuleCache
from app.infrastructure.config import get_cors_origins, get_session_secret, get_session_secure
from app.infrastructure.sql_auth import (
    AuthConfigurationError,
    DuplicateEmailError,
    DuplicateUsernameError,
    SqlServerAuthGateway,
)
from app.infrastructure.sql_chat_history import SqlServerChatHistoryGateway
from app.infrastructure.sql_product_search import SqlServerProductSearchGateway
from app.infrastructure.sql_rule_repository import SqlServerRuleRepository

rule_repository = SqlServerRuleRepository()
rule_cache = InMemoryRuleCache()
search_gateway = SqlServerProductSearchGateway()
history_gateway = SqlServerChatHistoryGateway()
auth_gateway = SqlServerAuthGateway()
chat_use_case = ResolveChatMessageUseCase(
    search_gateway=search_gateway,
    history_gateway=history_gateway,
    rule_cache=rule_cache,
)


def response_to_dict(response: ChatResponse) -> dict[str, Any]:
    payload = {
        "resultCode": response.result_code,
        "resultMessage": response.result_message,
        "rule": response.rule,
        "reply": response.reply,
        "products": response.products,
    }
    if response.conversation_id is not None:
        payload["conversationId"] = response.conversation_id
    return payload


@asynccontextmanager
async def lifespan(app: FastAPI):
    rule_cache.set_rules(rule_repository.load_rules())
    yield


app = FastAPI(title="Ecommerce Agent API", lifespan=lifespan)
app.add_middleware(
    SessionMiddleware,
    secret_key=get_session_secret(),
    session_cookie="chat_session",
    max_age=8 * 60 * 60,
    same_site="lax",
    https_only=get_session_secure(),
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=get_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class RegisterRequest(BaseModel):
    full_name: str = Field(alias="fullName", min_length=2, max_length=100)
    username: str = Field(min_length=3, max_length=50, pattern=r"^[A-Za-z0-9_.-]+$")
    email: str = Field(min_length=5, max_length=80)
    password: str = Field(min_length=8, max_length=256)
    phone_number: str = Field(alias="phoneNumber", min_length=7, max_length=20)
    country_id: int = Field(alias="countryId", gt=0)
    gender_id: int = Field(alias="genderId", gt=0)
    birth_date: date = Field(alias="birthDate")

    @field_validator("email")
    @classmethod
    def validate_email(cls, value: str) -> str:
        normalized = value.strip().lower()
        if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", normalized):
            raise ValueError("El correo no tiene un formato valido.")
        return normalized

    @field_validator("birth_date")
    @classmethod
    def validate_birth_date(cls, value: date) -> date:
        if value >= date.today():
            raise ValueError("La fecha de nacimiento debe ser anterior a hoy.")
        return value


class LoginRequest(BaseModel):
    identifier: str = Field(min_length=3, max_length=80)
    password: str = Field(min_length=1, max_length=256)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(_request: Request, error: RequestValidationError):
    return JSONResponse(
        status_code=400,
        content={
            "detail": "Los datos enviados no son validos.",
            "errors": [
                {"location": item["loc"], "message": item["msg"], "type": item["type"]}
                for item in error.errors()
            ],
        },
    )


def require_user(request: Request) -> dict:
    user_id = request.session.get("userId")
    if user_id is None:
        raise HTTPException(status_code=401, detail="No hay una sesion activa.")
    user = auth_gateway.get_user(int(user_id))
    if user is None:
        request.session.clear()
        raise HTTPException(status_code=401, detail="La sesion ya no es valida.")
    return user


def require_owned_conversation(conversation_id: int, user_id: int) -> None:
    if not history_gateway.conversation_belongs_to_user(conversation_id, str(user_id)):
        raise HTTPException(status_code=404, detail="Conversacion no encontrada.")


@app.post("/auth/register", status_code=201)
def register(payload: RegisterRequest, request: Request) -> dict[str, Any]:
    try:
        user = auth_gateway.register(payload.model_dump())
    except DuplicateUsernameError as error:
        raise HTTPException(status_code=409, detail="El nombre de usuario ya esta registrado.") from error
    except DuplicateEmailError as error:
        raise HTTPException(status_code=409, detail="El correo ya esta registrado.") from error
    except AuthConfigurationError as error:
        raise HTTPException(status_code=500, detail="La autenticacion no esta configurada en la base de datos.") from error
    except pyodbc.Error as error:
        raise HTTPException(status_code=400, detail="No fue posible registrar el usuario con esos datos.") from error

    request.session.clear()
    request.session["userId"] = user["id"]
    return {"resultCode": 201, "resultMessage": "Usuario registrado correctamente.", "user": user}


@app.post("/auth/login")
def login(payload: LoginRequest, request: Request) -> dict[str, Any]:
    user = auth_gateway.login(payload.identifier.strip(), payload.password)
    if user is None:
        raise HTTPException(status_code=401, detail="Usuario, correo o contrasena incorrectos.")
    request.session.clear()
    request.session["userId"] = user["id"]
    return {"resultCode": 200, "resultMessage": "Inicio de sesion correcto.", "user": user}


@app.get("/auth/session")
def get_session(request: Request) -> dict[str, Any]:
    return {"user": require_user(request)}


@app.post("/auth/logout")
def logout(request: Request) -> dict[str, Any]:
    request.session.clear()
    return {"resultCode": 200, "resultMessage": "Sesion cerrada correctamente."}


@app.get("/")
def healthcheck() -> dict[str, Any]:
    rules = rule_cache.get_rules()
    return {
        "status": "ok",
        "rulesLoaded": len(rules),
        "rules": [rule.name for rule in rules],
    }


@app.get("/conversations/{conversation_id}/messages")
def get_conversation_messages(conversation_id: int, request: Request) -> dict[str, Any]:
    user = require_user(request)
    require_owned_conversation(conversation_id, user["id"])
    return {
        "conversationId": conversation_id,
        "messages": history_gateway.get_conversation_messages(conversation_id),
    }


@app.get("/users/{user_id}/conversations")
def get_user_conversations(user_id: str, request: Request) -> dict[str, Any]:
    user = require_user(request)
    if user_id != str(user["id"]):
        raise HTTPException(status_code=403, detail="No puedes consultar conversaciones de otro usuario.")
    return {
        "userId": user_id,
        "conversations": history_gateway.get_user_conversations(user_id),
    }


@app.post("/conversations/{conversation_id}/close")
def close_conversation(conversation_id: int, request: Request) -> dict[str, Any]:
    user = require_user(request)
    require_owned_conversation(conversation_id, user["id"])
    history_gateway.close_conversation(conversation_id)
    return {
        "resultCode": 200,
        "resultMessage": "Conversacion cerrada correctamente.",
        "conversationId": conversation_id,
    }


@app.delete("/conversations/{conversation_id}")
def delete_conversation(conversation_id: int, request: Request) -> dict[str, Any]:
    user = require_user(request)
    require_owned_conversation(conversation_id, user["id"])
    history_gateway.delete_conversation(conversation_id)
    return {
        "resultCode": 200,
        "resultMessage": "Conversacion eliminada correctamente.",
        "conversationId": conversation_id,
    }


@app.websocket("/ws/chat")
async def websocket_chat(websocket: WebSocket):
    await websocket.accept()

    user_id = websocket.session.get("userId")
    if user_id is None or auth_gateway.get_user(int(user_id)) is None:
        await websocket.close(code=4401, reason="Sesion requerida.")
        return

    try:
        while True:
            payload = await websocket.receive_json()
            message = str(payload.get("message", ""))
            raw_conversation_id = payload.get("conversationId")
            conversation_id = None if raw_conversation_id in (None, "", 0, "0") else int(raw_conversation_id)
            response = chat_use_case.execute(message, user_id=str(user_id), conversation_id=conversation_id)
            await websocket.send_json(response_to_dict(response))
    except PermissionError:
        await websocket.close(code=4403, reason="Conversacion no autorizada.")
    except WebSocketDisconnect:
        return
