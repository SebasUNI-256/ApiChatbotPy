# Casos De Uso Y Validacion

Este archivo sirve para probar la API y luego comprobar en SQL Server que el historial queda guardado correctamente cuando se mantiene el mismo `userId`.

## Endpoint

- `GET http://127.0.0.1:8000/`
- `WebSocket ws://127.0.0.1:8000/ws/chat`

## Caso 1. Saludo inicial

Entrada:

```json
{
  "userId": "usuario-demo-1",
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
  "userId": "usuario-demo-2",
  "message": "quiero tenis"
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
      "ProductName": "<nombre del producto>"
    }
  ]
}
```

Notas:
- `reply` puede variar.
- `products` puede traer uno o varios registros.
- Lo importante es que `rule` sea `Buscar Producto` y que venga `conversationId`.

## Caso 3. Busqueda continuando una conversacion existente

Entrada:

```json
{
  "userId": "usuario-demo-2",
  "conversationId": 2,
  "message": "ahora quiero camisas"
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
      "ProductName": "<nombre del producto>"
    }
  ]
}
```

Notas:
- El `conversationId` debe mantenerse igual.
- Eso permite que el historial quede unido a la misma conversacion.

## Caso 4. Mensaje no entendido

Entrada:

```json
{
  "userId": "usuario-demo-3",
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

## Caso 5. Busqueda con texto vacio

Entrada:

```json
{
  "userId": "usuario-demo-4",
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

## Consultas SQL Para Comprobar Historial Por UserId

Usa siempre el mismo `userId` en Postman o en tu cliente WebSocket. Luego abre `SQL Server Management Studio`, entra a una nueva consulta y ejecuta lo siguiente.

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
WHERE UsuarioID = 'usuario-demo-2'
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
WHERE c.UsuarioID = 'usuario-demo-2'
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

1. Envia un saludo con un `userId`, por ejemplo `usuario-demo-2`.
2. Guarda el `conversationId` que regresa la API.
3. Envia otra busqueda usando el mismo `userId` y el mismo `conversationId`.
4. Ejecuta la consulta de mensajes por usuario.
5. Debes ver varios mensajes bajo la misma conversacion.

## Que Debe Verse Bien

- El mismo `userId` debe aparecer en `HistorialConversaciones`.
- Si reutilizas el mismo `conversationId`, los mensajes deben quedar en esa misma conversacion.
- Los mensajes del usuario se guardan con `ChatBot = 0`.
- Las respuestas del bot se guardan con `ChatBot = 1`.
