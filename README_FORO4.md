# Foro 4 - Consumo del WebSocket desde frontend

Esta entrega incluye el backend preparado en Foro 3 y el frontend React que consume autenticacion, chat, carrito y pagos.

## Ejecucion completa

1. Ejecuta `Backend/SQL/01_DB_ECOMMERCE.sql`.
2. Ejecuta `Backend/SQL/02_DB_EcommerceAgent.sql`.
3. Ejecuta `Backend/SQL/03_SEED_PRUEBA.sql`.
4. Inicia la API:

```powershell
cd Backend\python_api
python -m pip install -r requirements.txt
python -m uvicorn main:app
```

No crees un `.env` para SQL Server. La API reconoce `.\SQLEXPRESS` de forma
predeterminada. Solo si tu instancia tiene otro nombre, ejecuta antes:

```powershell
$env:SQL_SERVER = ".\OTRA_INSTANCIA"
```

5. En otra consola inicia el frontend:

```powershell
cd Frontend\ChatBot
npm install
npm run dev
```

6. Abre `http://localhost:5173` e inicia sesion con:

```text
Usuario: FORO3_DEMO
Contrasena: ClaveDemo123!
```

Toda la entrega usa `localhost`: API `http://localhost:8000` y WebSocket `ws://localhost:8000/ws/chat`.
El `.env.local` del frontend tambien es opcional y se utiliza solamente si deseas
cambiar esas URL mediante `VITE_API_URL` o `VITE_WS_URL`; no configura SQL Server.
