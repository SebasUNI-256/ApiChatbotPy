# Consumo WebSocket - Foro 4

Frontend React para autenticacion, busqueda de productos, carrito, direcciones, metodos de pago y ordenes.

## Antes de iniciar

Prepara primero el backend incluido en esta entrega siguiendo `../../Backend/README.md`. La API debe responder en `http://localhost:8000`.

No mezcles `localhost` con `127.0.0.1`: la cookie de sesion debe viajar por HTTP y WebSocket usando el mismo host.

## Instalar y ejecutar

Desde PowerShell:

```powershell
cd Frontend\ChatBot
npm install
npm run dev
```

Abre `http://localhost:5173`.

Si PowerShell bloquea `npm.ps1`, usa los comandos equivalentes:

```powershell
npm.cmd install
npm.cmd run dev
```

## Direcciones locales

Los valores predeterminados ya estan incluidos en el codigo:

```text
HTTP:      http://localhost:8000
WebSocket: ws://localhost:8000/ws/chat
Frontend:  http://localhost:5173
```

Para usar otro servidor, copia `.env.example` como `.env.local` y cambia:

```text
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000/ws/chat
```

Axios, autenticacion, historial y checkout comparten `VITE_API_URL`. El chat usa `VITE_WS_URL`; si se omite, se deriva automaticamente del servidor HTTP.

## Flujo de demostracion

1. Inicia sesion con `FORO3_DEMO` y `ClaveDemo123!`.
2. Busca `teclado mecanico foro 3`.
3. Agrega la variante al carrito.
4. Revisa o registra direccion y metodo de pago.
5. Selecciona ambas opciones y procesa el pago.
6. Consulta la orden creada.

El contrato completo y ejemplos copiables estan en `../instrucciones y ejemplos`.
