# Casos De Uso Y Validacion

Este archivo sirve para probar la API y comprobar en SQL Server que el historial queda asociado al usuario autenticado. Primero inicia sesion; el WebSocket obtiene `userId` desde la cookie y no acepta identidad enviada por el cliente.

## Endpoint

- `POST http://127.0.0.1:8000/auth/register`
- `POST http://127.0.0.1:8000/auth/login`
- `GET http://127.0.0.1:8000/auth/session`
- `POST http://127.0.0.1:8000/auth/logout`
- `GET http://127.0.0.1:8000/`
- `WebSocket ws://127.0.0.1:8000/ws/chat`
- `GET http://127.0.0.1:8000/conversations/{conversationId}/messages`
- `GET http://127.0.0.1:8000/users/{userId}/conversations`
- `POST http://127.0.0.1:8000/conversations/{conversationId}/close`
- `DELETE http://127.0.0.1:8000/conversations/{conversationId}`

En Postman, conserva la cookie recibida al registrar o iniciar sesion. En el
navegador, las solicitudes HTTP deben usar `credentials: "include"`.

## Caso 1. Saludo inicial

Entrada:

```json
{
  "message": "hola"
}
```

Salida esperada:

```json
{
  "resultCode": 200,
  "resultMessage": "OK",
  "rule": "Saludo Inicial",
  "reply": "<una plantilla activa de saludo>",
  "conversationId": "<numero generado por la BD>"
}
```

Notas:
- `reply` puede variar porque sale de las plantillas activas de la base de datos.
- Lo importante es que `rule` sea `Saludo Inicial`.
- Guarda el `conversationId` si luego quieres continuar la misma conversacion.

## Caso 2. Busqueda de productos iniciando conversacion

Entrada:

```json
{
  "message": "quiero tecnologia",
  "pageNumber": 1
}
```

Salida esperada:

```json
{
  "resultCode": 200,
  "resultMessage": "Busqueda realizada satisfactoriamente.",
  "rule": "Buscar Producto",
  "reply": "<una plantilla activa de busqueda>",
  "conversationId": "<numero generado por la BD>",
  "products": [
    {
      "ProductID": "<id>",
      "ProductName": "<nombre del producto>",
      "ProductVariableID": "<id de la variante>"
    }
  ],
  "pageNumber": 1,
  "pageSize": 10,
  "totalRows": 11
}
```

Notas:
- `reply` puede variar.
- `products` trae como maximo 10 variantes por pagina.
- `pageSize` permanece en `10`, aunque la ultima pagina tenga menos productos.
- `totalRows` depende de los datos instalados; `11` corresponde a la base local usada en este ejemplo.
- Lo importante es que `rule` sea `Buscar Producto` y que venga `conversationId`.

## Caso 3. Segunda pagina continuando una conversacion existente

Entrada:

```json
{
  "conversationId": 2,
  "message": "quiero tecnologia",
  "pageNumber": 2
}
```

Salida esperada:

```json
{
  "resultCode": 200,
  "resultMessage": "Busqueda realizada satisfactoriamente.",
  "rule": "Buscar Producto",
  "reply": "<una plantilla activa de busqueda>",
  "conversationId": 2,
  "products": [
    {
      "ProductID": "<id>",
      "ProductName": "<nombre del producto>",
      "ProductVariableID": "<id de la variante>"
    }
  ],
  "pageNumber": 2,
  "pageSize": 10,
  "totalRows": 11
}
```

Notas:
- El `conversationId` debe mantenerse igual.
- El mensaje de busqueda tambien se mantiene; solo cambia `pageNumber`.
- Con 11 coincidencias, la segunda pagina contiene una variante.
- Eso permite que el historial quede unido a la misma conversacion.

## Caso 4. Pagina sin resultados

Entrada:

```json
{
  "conversationId": 2,
  "message": "quiero tecnologia",
  "pageNumber": 99
}
```

Salida esperada:

```json
{
  "resultCode": 204,
  "resultMessage": "No se encontraron productos en la pagina solicitada.",
  "rule": "Buscar Producto",
  "reply": "No se encontraron productos en la pagina solicitada.",
  "products": [],
  "data": null,
  "conversationId": 2,
  "pageNumber": 99,
  "pageSize": 10,
  "totalRows": 11
}
```

`204` indica que el filtro existe, pero la pagina solicitada no contiene filas.

## Caso 5. Numero de pagina invalido

Entrada:

```json
{
  "message": "quiero tecnologia",
  "pageNumber": 0
}
```

Salida esperada:

```json
{
  "resultCode": 400,
  "resultMessage": "El parametro pageNumber debe ser un entero positivo.",
  "rule": "Buscar Producto",
  "reply": "El parametro pageNumber debe ser un entero positivo.",
  "products": [],
  "data": null
}
```

Tambien se rechazan negativos, texto y booleanos. La API no consulta productos
ni devuelve metadatos de paginacion cuando el valor es invalido.

## Caso 6. Mensaje no entendido

Entrada:

```json
{
  "message": "asdasdasd"
}
```

Salida esperada:

```json
{
  "resultCode": 200,
  "resultMessage": "OK",
  "rule": "No Entendimos La Peticion",
  "reply": "<una plantilla activa de no entendido>",
  "conversationId": "<numero generado por la BD>"
}
```

Notas:
- `reply` puede variar.
- Lo importante es que `rule` sea `No Entendimos La Peticion`.

## Caso 7. Busqueda con texto vacio

Entrada:

```json
{
  "message": ""
}
```

Salida esperada:

```json
{
  "resultCode": 400,
  "resultMessage": "El campo message es obligatorio.",
  "rule": null,
  "reply": "Debes enviar un mensaje para procesar la peticion."
}
```

Notas:
- Este caso confirma el manejo del codigo `400`.
- Como el mensaje viene vacio, no se crea historial y no se devuelve `conversationId`.

## Caso 8. Ofertas o descuentos

Entrada:

```json
{
  "message": "quiero ver ofertas"
}
```

Salida esperada:

```json
{
  "resultCode": 200,
  "resultMessage": "OK",
  "rule": "Busqueda por Ofertas Descuentos",
  "reply": "<una plantilla activa de ofertas>",
  "conversationId": "<numero generado por la BD>"
}
```

Notas:
- La regla se activa por palabras como `oferta`, `ofertas`, `descuento`, `descuentos` o `promocion`.
- Si el mensaje tambien contiene palabras generales como `quiero`, la API prioriza la palabra clave mas especifica.

## Caso 9. Consultar historial desde la API

Despues de enviar mensajes por WebSocket, consulta:

```http
GET http://127.0.0.1:8000/conversations/2/messages
```

Salida esperada:

```json
{
  "conversationId": 2,
  "messages": [
    {
      "MensajeID": 1,
      "ChatBot": false,
      "Texto": "hola",
      "FechaHora": "2026-07-07T00:00:00",
      "ReglaActivadaID": null,
      "MetaData": null
    }
  ]
}
```

Tambien puedes listar conversaciones por usuario:

```http
GET http://127.0.0.1:8000/users/8/conversations
```

## Consultas SQL Para Comprobar Historial Por UserId

Usa el ID numerico devuelto por `/auth/login` o `/auth/session`. Luego abre `SQL Server Management Studio`, entra a una nueva consulta y ejecuta lo siguiente.

## 1. Ver conversaciones de un usuario

```sql
USE DB_EcommerceAgent;
GO

SELECT
    ConversacionID,
    UsuarioID,
    FechaInicio,
    FechaFin,
    Activo
FROM dbo.HistorialConversaciones
WHERE UsuarioID = '8'
ORDER BY ConversacionID DESC;
```

## 2. Ver mensajes de un usuario con tipo de mensaje

```sql
USE DB_EcommerceAgent;
GO

SELECT
    c.ConversacionID,
    c.UsuarioID,
    m.MensajeID,
    CASE
        WHEN m.ChatBot = 1 THEN 'Bot'
        ELSE 'Usuario'
    END AS TipoMensaje,
    m.Texto,
    m.FechaHora,
    m.ReglaActivadaID
FROM dbo.HistorialConversaciones c
INNER JOIN dbo.HistorialMensajes m
    ON m.ConversacionID = c.ConversacionID
WHERE c.UsuarioID = '8'
ORDER BY c.ConversacionID DESC, m.MensajeID ASC;
```

## 3. Ver una conversacion especifica

```sql
USE DB_EcommerceAgent;
GO

SELECT
    c.ConversacionID,
    c.UsuarioID,
    m.MensajeID,
    CASE
        WHEN m.ChatBot = 1 THEN 'Bot'
        ELSE 'Usuario'
    END AS TipoMensaje,
    m.Texto,
    m.FechaHora
FROM dbo.HistorialConversaciones c
INNER JOIN dbo.HistorialMensajes m
    ON m.ConversacionID = c.ConversacionID
WHERE c.ConversacionID = 2
ORDER BY m.MensajeID ASC;
```

## 4. Ver las ultimas conversaciones creadas

```sql
USE DB_EcommerceAgent;
GO

SELECT TOP 20
    ConversacionID,
    UsuarioID,
    FechaInicio,
    FechaFin,
    Activo
FROM dbo.HistorialConversaciones
ORDER BY ConversacionID DESC;
```

## 5. Ver los ultimos mensajes guardados

```sql
USE DB_EcommerceAgent;
GO

SELECT TOP 50
    MensajeID,
    ConversacionID,
    CASE
        WHEN ChatBot = 1 THEN 'Bot'
        ELSE 'Usuario'
    END AS TipoMensaje,
    Texto,
    FechaHora,
    ReglaActivadaID
FROM dbo.HistorialMensajes
ORDER BY MensajeID DESC;
```

## Como Validar Que Si Mantiene El Historial

1. Inicia sesion y envia un saludo sin incluir `userId`.
2. Guarda el `conversationId` que regresa la API.
3. Envia otra busqueda usando la misma sesion y el mismo `conversationId`.
4. Ejecuta la consulta de mensajes por usuario.
5. Debes ver varios mensajes bajo la misma conversacion.

## Que Debe Verse Bien

- El ID del usuario autenticado debe aparecer en `HistorialConversaciones`.
- Si reutilizas el mismo `conversationId`, los mensajes deben quedar en esa misma conversacion.
- Los mensajes del usuario se guardan con `ChatBot = 0`.
- Las respuestas del bot se guardan con `ChatBot = 1`.
