# Casos de uso y validacion

Esta guia prueba la API con el usuario creado por `SQL/03_SEED_PRUEBA.sql`. La identidad siempre sale de la cookie firmada `chat_session`: nunca envies `userId` en el WebSocket.

## Preparacion

1. Ejecuta los tres scripts de `Backend/SQL` en el orden indicado en su README.
2. Inicia la API desde `Backend/python_api`:

```powershell
python -m uvicorn main:app
```

No crees un `.env` para SQL Server: la API ya usa `.\SQLEXPRESS` de forma
predeterminada. `SQL_SERVER` se define únicamente si la instancia local tiene
otro nombre.

3. Usa siempre el mismo host: `http://localhost:8000` y `ws://localhost:8000/ws/chat`.
4. En Postman conserva la cookie recibida. En el navegador usa `credentials: "include"`.

Credenciales demostrativas:

```text
Usuario: FORO3_DEMO
Correo: foro3.demo@example.com
Contrasena: ClaveDemo123!
```

## 1. Iniciar sesion

`POST http://localhost:8000/auth/login`

```json
{
  "identifier": "FORO3_DEMO",
  "password": "ClaveDemo123!"
}
```

La respuesta correcta devuelve `resultCode: 200`, el objeto `user` y la cookie `chat_session`. Comprueba la restauracion con `GET http://localhost:8000/auth/session`.

## 2. Consultar opciones para pagar

`GET http://localhost:8000/checkout/options`

Respuesta resumida:

```json
{
  "addresses": [
    {
      "addressId": 1,
      "zipCode": 10001,
      "description": "Direccion de prueba Foro 3, Managua",
      "isPrincipal": true
    }
  ],
  "paymentMethods": [
    {
      "paymentMethodId": 1,
      "paymentMethodTypeId": 1,
      "typeName": "TARJETA VISA DEMO",
      "lastFour": "1111",
      "expirationDate": "2029-08",
      "cardHolderName": "USUARIO FORO 3 DEMO"
    }
  ],
  "paymentMethodTypes": [
    {
      "paymentMethodTypeId": 1,
      "name": "TARJETA VISA DEMO",
      "description": "Tarjeta de demostracion para Foro 3"
    }
  ],
  "orders": []
}
```

Los IDs pueden variar. La API nunca devuelve el CVV ni el numero completo.

## 3. Registrar otra direccion

`POST http://localhost:8000/checkout/addresses`

```json
{
  "zipCode": 11001,
  "description": "Residencial de prueba, casa 12, Managua",
  "isPrincipal": false
}
```

La respuesta correcta usa HTTP `201` e incluye `address.addressId`. Una descripcion demasiado corta o un codigo postal invalido produce HTTP `422`.

## 4. Registrar otro metodo de pago

Primero toma `paymentMethodTypeId` de `GET /checkout/options`. Luego envia:

`POST http://localhost:8000/checkout/payment-methods`

```json
{
  "paymentMethodTypeId": 1,
  "cardNumber": "4111111111111111",
  "expirationDate": "2029-12",
  "cvv": "123",
  "cardHolderName": "USUARIO FORO 3 DEMO"
}
```

La respuesta correcta usa HTTP `201` y solo devuelve los ultimos cuatro digitos. Usa un vencimiento posterior al mes actual.

## 5. Abrir el WebSocket y buscar el producto de prueba

Con la sesion activa abre `ws://localhost:8000/ws/chat` y envia:

```json
{
  "message": "quiero tenis",
  "pageNumber": 1
}
```

La respuesta debe incluir `conversationId`, `products`, `pageNumber`, `pageSize` y `totalRows`. Guarda el `ProductVariableID` del resultado.

## 6. Agregar al carrito

```json
{
  "message": "agregar al carrito",
  "conversationId": 1,
  "parameters": {
    "productVariableId": 1,
    "quantity": 1
  }
}
```

Sustituye ambos IDs por los obtenidos realmente. `data` devuelve el carrito actualizado y cada linea incluye `cartDetailId`.

## 7. Consultar y eliminar productos

Consultar:

```json
{
  "message": "ver carrito",
  "conversationId": 1
}
```

Eliminar una linea:

```json
{
  "message": "quitar del carrito",
  "conversationId": 1,
  "parameters": {
    "cartDetailId": 1
  }
}
```

Para eliminar usa `cartDetailId`; no uses `productVariableId`.

## 8. Procesar el pago

Si eliminaste el producto, vuelve a agregarlo. Toma `addressId` y `paymentMethodId` de `GET /checkout/options`:

```json
{
  "message": "procesar pago",
  "conversationId": 1,
  "parameters": {
    "addressId": 1,
    "paymentMethodId": 1
  }
}
```

Una respuesta correcta devuelve en `data`:

```json
{
  "order": {
    "orderId": 1,
    "status": "PROCESADO",
    "subtotal": 49.99,
    "discount": 0.0,
    "shipping": 0.0,
    "tax": 0.0,
    "total": 49.99,
    "currencyId": 1
  },
  "details": []
}
```

El procedimiento valida propietario, carrito no vacio, direccion, metodo, moneda y stock dentro de una transaccion. Al finalizar descuenta inventario y cierra el carrito.

## 9. Consultar la orden

```json
{
  "message": "consultar orden",
  "conversationId": 1,
  "parameters": {
    "orderId": 1
  }
}
```

Usa el `orderId` recibido al pagar. La API solo devuelve ordenes del usuario autenticado.

## 10. Historial y cierre de sesion

```http
GET http://localhost:8000/users/{userId}/conversations
GET http://localhost:8000/conversations/{conversationId}/messages
POST http://localhost:8000/conversations/{conversationId}/close
DELETE http://localhost:8000/conversations/{conversationId}
POST http://localhost:8000/auth/logout
```

El `userId` de la ruta debe coincidir con `user.id` de la sesion. No es una credencial y nunca se envia dentro del mensaje WebSocket.

## Errores esperados

| Codigo | Significado |
| --- | --- |
| HTTP `401` | No existe una sesion valida |
| HTTP `403` | Se intenta consultar recursos de otro usuario |
| HTTP `404` | Direccion, metodo, conversacion u orden inexistente |
| HTTP `422` | El cuerpo HTTP no cumple el formato requerido |
| WebSocket `400` | Faltan parametros o no son enteros positivos |
| WebSocket `409` | Carrito vacio, monedas incompatibles o stock insuficiente |
| WebSocket `4401` | La sesion vencio o no existe |
| WebSocket `4403` | La conversacion pertenece a otro usuario |

## Consultas SQL de comprobacion

```sql
USE DB_ECOMMERCE;
GO

SELECT U.userId, U.userName, A.userAddressId, P.userPaymentMethodId
FROM SQM_SECURITY.Tbl_Users U
LEFT JOIN SQM_GENERAL.Tbl_UserAddress A ON A.userAddressUserId = U.userId
LEFT JOIN SQM_GENERAL.Tbl_UserPaymentMethods P ON P.userPaymentMethodUserId = U.userId
WHERE U.userName = 'FORO3_DEMO';

SELECT O.orderId, O.orderTotal, S.statusName
FROM SQM_GENERAL.Tbl_PaymentOrders O
INNER JOIN SQM_CATALOGS.Tbl_Status S ON S.statusId = O.orderStatusId
WHERE O.orderUserId = (SELECT userId FROM SQM_SECURITY.Tbl_Users WHERE userName = 'FORO3_DEMO')
ORDER BY O.orderId DESC;

SELECT ProductVariableID, ProductName, StockAvailable
FROM SQM_GENERAL.VW_GENERAL_PRODUCTS
WHERE ProductName = 'TENIS DEPORTIVOS FORO 3';

USE DB_EcommerceAgent;
GO

SELECT C.ConversacionID, C.UsuarioID, M.ChatBot, M.Texto, M.FechaHora
FROM dbo.HistorialConversaciones C
INNER JOIN dbo.HistorialMensajes M ON M.ConversacionID = C.ConversacionID
ORDER BY C.ConversacionID DESC, M.MensajeID;
```
