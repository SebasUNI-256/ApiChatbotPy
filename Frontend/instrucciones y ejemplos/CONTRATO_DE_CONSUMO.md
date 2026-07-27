# Contrato De Consumo

## Reglas comunes

- Frontend local esperado: `http://localhost:5173`.
- Base HTTP local: `http://localhost:8000`.
- WebSocket local: `ws://localhost:8000/ws/chat`.
- Todas las llamadas HTTP autenticadas usan `credentials: "include"`.
- El navegador adjunta la cookie al WebSocket si HTTP y WebSocket usan el mismo host.
- El frontend nunca envia `userId` en el chat.
- `conversationId` es opcional en el primer mensaje y debe reutilizarse despues.
- `pageNumber` es opcional y solo se usa en busquedas; si se omite, vale `1`.

## Endpoints HTTP

| Metodo | Ruta | Uso | Requiere sesion |
| --- | --- | --- | --- |
| `GET` | `/` | Estado y reglas cargadas | No |
| `POST` | `/auth/register` | Registrar cliente e iniciar sesion | No |
| `POST` | `/auth/login` | Iniciar sesion | No |
| `GET` | `/auth/session` | Restaurar usuario al recargar | Si |
| `POST` | `/auth/logout` | Cerrar la sesion si existe | No |
| `GET` | `/users/{userId}/conversations` | Listar conversaciones propias | Si |
| `GET` | `/conversations/{conversationId}/messages` | Leer una conversacion propia | Si |
| `POST` | `/conversations/{conversationId}/close` | Cerrar una conversacion propia | Si |
| `DELETE` | `/conversations/{conversationId}` | Eliminar una conversacion propia | Si |

En `/users/{userId}/conversations`, el valor debe coincidir con `user.id`
devuelto por `/auth/login` o `/auth/session`. La API rechaza consultar otro usuario.

## Autenticacion

### Registro

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

Respuesta `201`:

```json
{
  "resultCode": 201,
  "resultMessage": "Usuario registrado correctamente.",
  "user": {
    "id": 8,
    "username": "JUANP",
    "fullName": "Juan Perez",
    "email": "juan@example.com",
    "role": "CLIENTE"
  }
}
```

### Login

```json
{
  "identifier": "JUANP",
  "password": "ClaveSegura123!"
}
```

`identifier` acepta nombre de usuario o correo. Una respuesta correcta devuelve
el mismo objeto `user` que el registro.

## WebSocket

Mensaje general:

```json
{
  "message": "texto que activa la regla",
  "conversationId": null,
  "pageNumber": 1,
  "parameters": {}
}
```

Respuesta general:

```json
{
  "resultCode": 200,
  "resultMessage": "OK",
  "rule": "Nombre de la regla",
  "reply": "Texto para mostrar al usuario",
  "products": [],
  "data": null,
  "conversationId": 12
}
```

- `reply` es el mensaje visible del bot.
- `products` contiene resultados de busqueda.
- `data` contiene el carrito o una orden.
- Confirma el resultado con `resultCode`; no deduzcas exito solamente desde `reply`.

Las respuestas de busqueda tambien incluyen los metadatos de paginacion:

```json
{
  "resultCode": 200,
  "resultMessage": "Busqueda realizada satisfactoriamente.",
  "rule": "Buscar Producto",
  "reply": "Resultados encontrados.",
  "products": [],
  "data": null,
  "conversationId": 12,
  "pageNumber": 1,
  "pageSize": 10,
  "totalRows": 22
}
```

- `pageNumber` es la pagina solicitada.
- `pageSize` es la capacidad fija de cada pagina: `10`.
- `totalRows` es la cantidad total de variantes que coinciden con el filtro.
- La cantidad recibida en la pagina actual es `products.length`.
- El total de paginas se calcula con `Math.ceil(totalRows / pageSize)`.
- Las respuestas que no son busquedas omiten estos tres campos.

## Acciones disponibles

| Accion | Ejemplo de `message` | `parameters` | Resultado |
| --- | --- | --- | --- |
| Buscar productos | `quiero tenis` | No; usa `pageNumber` en el nivel principal | `products` y metadatos de paginacion |
| Ver ofertas | `quiero ver ofertas` | No | Mensaje en `reply` |
| Agregar al carrito | `agregar al carrito` | `productVariableId`, `quantity` | Carrito actualizado en `data` |
| Consultar carrito | `ver carrito` | No | Carrito en `data` |
| Eliminar del carrito | `quitar del carrito` | `cartDetailId` | Carrito actualizado en `data` |
| Procesar pago | `procesar pago` | `addressId`, `paymentMethodId` | Orden en `data` |
| Consultar orden | `consultar orden` | `orderId` | Orden en `data` |

Los nombres dentro de `parameters` distinguen mayusculas y minusculas. Usa
exactamente los nombres de la tabla.

## Forma de los productos

La busqueda devuelve registros como:

```json
{
  "ProductID": 1,
  "ProductName": "TENIS AIR MAX",
  "ProductVariableID": 1,
  "ProductVariableName": "TALLA 40",
  "ProductVariablePrice": 120.0,
  "CurrencyISO": "USD",
  "CategoryName": "CALZADO",
  "SubcategoryName": "TENIS",
  "SegmentName": "DEPORTIVO",
  "MarkName": "NIKE",
  "ProviderName": "PROVEEDOR",
  "StockAvailable": 50
}
```

Para agregar un resultado al carrito, envia `ProductVariableID` como
`parameters.productVariableId`.

## Paginar productos

Primera pagina:

```json
{
  "message": "quiero tenis",
  "conversationId": null,
  "pageNumber": 1
}
```

Siguiente pagina, reutilizando la misma conversacion y el mismo mensaje:

```json
{
  "message": "quiero tenis",
  "conversationId": 12,
  "pageNumber": 2
}
```

`pageNumber` debe ser un entero positivo. Un texto, un booleano, cero o un valor
negativo produce `resultCode: 400` sin consultar productos en la base de datos.

## Forma del carrito

`data` es una lista. Agregar, consultar y eliminar devuelven esta misma forma:

```json
[
  {
    "cartDetailId": 4,
    "productVariableId": 1,
    "productName": "TENIS AIR MAX",
    "productVariableValue": "TALLA 40",
    "quantity": 2,
    "unitPrice": 120.0,
    "total": 240.0,
    "currencyId": 1
  }
]
```

Usa `cartDetailId` para eliminar una linea. No uses `productVariableId` para esa
operacion.

## Forma de la orden

Procesar pago y consultar orden devuelven:

```json
{
  "order": {
    "orderId": 9,
    "orderCreationDate": "2026-07-26T19:56:39.657000",
    "status": "PROCESADO",
    "subtotal": 120.0,
    "discount": 0.0,
    "shipping": 0.0,
    "tax": 0.0,
    "total": 120.0,
    "currencyId": 1
  },
  "details": [
    {
      "orderDetailId": 10,
      "productVariableId": 1,
      "productName": "TENIS AIR MAX",
      "productVariableValue": "TALLA 40",
      "quantity": 1,
      "unitPrice": 120.0,
      "total": 120.0
    }
  ]
}
```

## De donde sale cada ID

| ID | Origen correcto |
| --- | --- |
| `userId` | `user.id` de login o sesion; no se envia al WebSocket |
| `conversationId` | Respuesta anterior del WebSocket |
| `productVariableId` | `ProductVariableID` de una busqueda |
| `cartDetailId` | `data[].cartDetailId` del carrito |
| `orderId` | `data.order.orderId` del pago |
| `addressId` | Debe existir previamente en la base de datos |
| `paymentMethodId` | Debe existir previamente en la base de datos |

## Errores y cierres

| Codigo | Significado para el frontend |
| --- | --- |
| `400` | Faltan parametros o tienen formato invalido |
| `204` | La pagina solicitada no contiene productos |
| `401` HTTP | No hay sesion valida |
| `403` HTTP | Se intento consultar otro usuario |
| `404` | Recurso inexistente o no perteneciente al usuario |
| `409` | Conflicto de negocio: carrito vacio, moneda o stock |
| `500` | Error de configuracion o base de datos |
| `4401` WebSocket | Debe iniciar sesion otra vez |
| `4403` WebSocket | La conversacion no pertenece al usuario |

Los errores normales de carrito llegan como mensajes WebSocket con
`resultCode >= 400`; no necesariamente cierran la conexion.

## Limites actuales

- No hay endpoints para listar o registrar direcciones y metodos de pago.
- El frontend no puede completar un pago por si solo hasta disponer de esos IDs.
- No hay endpoints REST separados para carrito: estas acciones pasan por el chat.
- Las busquedas usan paginas fijas de 10 variantes.
- Impuestos y envio permanecen en cero porque no existen reglas de calculo.
- Las reglas del chatbot se cargan al iniciar la API; cambios SQL requieren reinicio.
- La API no implementa reconexion automatica del WebSocket; corresponde al cliente.
