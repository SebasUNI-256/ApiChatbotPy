# Guia Para Consumir La API

Esta carpeta contiene lo necesario para conectar el frontend con la API actual.
No describe como disenar las pantallas; describe el contrato que deben respetar.

## Orden recomendado

1. Lee [CONTRATO_DE_CONSUMO.md](CONTRATO_DE_CONSUMO.md) para conocer endpoints,
   mensajes WebSocket, respuestas y limites.
2. Usa [EJEMPLOS_JAVASCRIPT.md](EJEMPLOS_JAVASCRIPT.md) como punto de partida para
   el cliente HTTP y el chat.
3. Si necesitas detalles internos de la API, consulta
   [`Backend/python_api/CONTRATO_AUTH_FRONTEND.md`](../../Backend/python_api/CONTRATO_AUTH_FRONTEND.md).

## Configuracion local

Con el frontend local en `http://localhost:5173`, usa `localhost` tambien para
HTTP y WebSocket:

```javascript
const API_URL = "http://localhost:8000";
const WS_URL = "ws://localhost:8000/ws/chat";
```

No mezcles `localhost` con `127.0.0.1` entre el frontend, las llamadas HTTP y el
WebSocket. La cookie pertenece al sitio que la creo y puede no enviarse si
cambias de host.

## Flujo minimo

1. Registrar o iniciar sesion mediante HTTP.
2. Restaurar la sesion al cargar la aplicacion con `GET /auth/session`.
3. Abrir el WebSocket solamente cuando exista una sesion valida.
4. Cargar direcciones, metodos de pago y ordenes con `GET /checkout/options`.
5. Guardar en memoria el `conversationId` que devuelve el chat.
6. Enviar `pageNumber` para recorrer busquedas; si se omite, la API usa la pagina `1`.
7. Enviar `parameters` solamente para las acciones que los necesitan.
8. Renderizar `products` y sus metadatos de paginacion para busquedas.
9. Renderizar `data` para carrito u orden.
10. Cerrar la sesion con `POST /auth/logout`.

## Disponible actualmente

- Registro, login, restauracion y logout.
- Busqueda de productos por chat en paginas de 10 variantes.
- Saludos, ofertas y respuesta de mensaje no entendido.
- Agregar, consultar y eliminar productos del carrito.
- Listar y registrar direcciones y metodos de pago propios.
- Procesar pagos seleccionando IDs devueltos por la API.
- Consultar orden.
- Listar, consultar, cerrar y eliminar conversaciones propias.

## Regla principal de seguridad

Nunca envies ni guardes `userId` como prueba de identidad. La API obtiene el
usuario de la cookie firmada `chat_session`. Tampoco guardes la cookie, la
contrasena ni datos de tarjeta en `localStorage`.
