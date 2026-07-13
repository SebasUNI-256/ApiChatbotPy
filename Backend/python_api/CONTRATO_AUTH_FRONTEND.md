# Contrato de autenticacion para el frontend

La API mantiene la sesion durante 8 horas mediante la cookie firmada `chat_session`.
El frontend no debe guardar contrasenas, cookies ni identificadores de sesion en
`localStorage`.

## Configuracion local

Variables de entorno de la API:

```text
SESSION_SECRET=una-clave-local-larga-y-aleatoria
SESSION_SECURE=false
CORS_ORIGINS=http://localhost:5173
```

En produccion se debe usar HTTPS, cambiar `SESSION_SECURE=true` y configurar el
origen real del frontend. Para varios origenes, `CORS_ORIGINS` acepta valores
separados por comas.

Antes de iniciar la API se debe ejecutar `SQL/Auth_Usuarios.sql` en
`DB_ECOMMERCE`, despues de crear la clave simetrica, los usuarios iniciales y el
estado `ACTIVO`. El instalador crea el rol `CLIENTE` si hace falta y requiere que
exista el usuario interno con ID `1`.

## Registro

`POST /auth/register`

```json
{
  "fullName": "Juan Perez",
  "username": "JUANP",
  "email": "juan@example.com",
  "password": "ClaveSegura123!",
  "phoneNumber": "88888888",
  "countryId": 1,
  "genderId": 2,
  "birthDate": "2000-05-12"
}
```

La respuesta `201` incluye `user` y deja la sesion iniciada. Un usuario o correo
duplicado responde `409`; datos invalidos responden `400`.

## Login y restauracion de sesion

`POST /auth/login`

```json
{
  "identifier": "JUANP",
  "password": "ClaveSegura123!"
}
```

`identifier` acepta nombre de usuario o correo. Credenciales incorrectas o una
cuenta inactiva responden `401`.

`GET /auth/session` restaura el usuario al recargar la pagina. `POST /auth/logout`
cierra la sesion.

Todas las solicitudes deben incluir credenciales:

```javascript
await fetch(`${API_URL}/auth/session`, {
  credentials: "include",
});
```

El usuario publico tiene esta forma:

```json
{
  "id": 8,
  "username": "JUANP",
  "fullName": "Juan Perez",
  "email": "juan@example.com",
  "role": "CLIENTE"
}
```

## Chat e historial

El WebSocket se abre normalmente y el navegador adjunta la cookie:

```javascript
const socket = new WebSocket("ws://127.0.0.1:8000/ws/chat");
```

El mensaje ya no necesita `userId`:

```json
{
  "message": "quiero ver ofertas",
  "conversationId": null
}
```

Una conexion sin sesion se cierra con codigo `4401`; intentar reutilizar una
conversacion ajena se cierra con `4403`.

Los endpoints de historial tambien necesitan la cookie. Para listar se usa
`GET /users/{id-del-usuario-autenticado}/conversations`. Consultar, cerrar o
eliminar una conversacion ajena es rechazado por la API.
