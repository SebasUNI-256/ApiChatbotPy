# Contrato de autenticacion para el frontend

Esta es la referencia tecnica de autenticacion de la API. La guia de consumo
orientada al frontend esta en
[`Frontend/instrucciones y ejemplos`](../../Frontend/instrucciones%20y%20ejemplos/README.md).

La API mantiene la sesion durante 8 horas mediante la cookie firmada `chat_session`.
El frontend no debe guardar contrasenas, cookies ni identificadores de sesion en
`localStorage`.

## Configuracion local

Para el arranque local no es obligatorio crear un archivo `.env`. La API ya
incluye estos valores predeterminados:

```text
SQL_SERVER=.\SQLEXPRESS
SESSION_SECURE=false
CORS_ORIGINS=http://localhost:5173
```

`SQL_SERVER` solo se configura cuando la instancia no es `.\SQLEXPRESS`. Las
variables pueden definirse temporalmente en PowerShell; no hace falta crear un
archivo:

```powershell
$env:SQL_SERVER = ".\OTRA_INSTANCIA"
$env:SESSION_SECRET = "una-clave-local-larga-y-aleatoria"
```

En produccion se debe usar HTTPS, cambiar `SESSION_SECURE=true` y configurar el
origen real del frontend. Tambien se debe cambiar `SESSION_SECRET`. Para varios
origenes, `CORS_ORIGINS` acepta valores separados por comas.

Antes de iniciar la API ejecuta los tres archivos de `Backend/SQL` en el orden
indicado por `Backend/SQL/README.md`. Esos instaladores crean o alinean las dos
bases, autenticacion, historial, busqueda, carrito y pagos sin eliminar datos
existentes. `03_SEED_PRUEBA.sql` agrega un usuario y un producto demostrativos.

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
const API_URL = "http://localhost:8000";

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

El WebSocket se abre con el mismo host usado para las llamadas HTTP y el
navegador adjunta la cookie. Con el frontend local en `localhost:5173`, usa:

```javascript
const socket = new WebSocket("ws://localhost:8000/ws/chat");
```

El mensaje ya no necesita `userId`:

```json
{
  "message": "quiero ver ofertas",
  "conversationId": null
}
```

Las busquedas aceptan `pageNumber` en el nivel principal. Si se omite, vale `1`:

```json
{
  "message": "quiero tenis",
  "conversationId": null,
  "pageNumber": 1
}
```

Una respuesta de busqueda incluye `products` y los metadatos de paginacion:

```json
{
  "resultCode": 200,
  "resultMessage": "Busqueda realizada satisfactoriamente.",
  "rule": "Buscar Producto",
  "reply": "Resultados encontrados.",
  "products": [
    {
      "ProductID": 1,
      "ProductVariableID": 1,
      "ProductVariableName": "TALLA 40"
    }
  ],
  "data": null,
  "conversationId": 12,
  "pageNumber": 1,
  "pageSize": 10,
  "totalRows": 22
}
```

`ProductVariableID` identifica la variante que se envia luego como
`parameters.productVariableId`. `pageSize` siempre vale `10`; el total de paginas
se calcula con `Math.ceil(totalRows / pageSize)`. Las respuestas que no son
busquedas omiten los tres campos de paginacion.

Las acciones de carrito usan `parameters` solo cuando necesitan identificadores:

```json
{
  "message": "agregar al carrito",
  "conversationId": null,
  "parameters": {
    "productVariableId": 1,
    "quantity": 2
  }
}
```

Los parametros disponibles son:

- agregar: `productVariableId`, `quantity`;
- eliminar: `cartDetailId`;
- pagar: `addressId`, `paymentMethodId`;
- consultar orden: `orderId`.

Consultar el carrito no requiere parametros. La respuesta coloca el carrito o
la orden en `data`; `userId` siempre se obtiene de la sesion.

Los datos necesarios para pagar se administran con la misma cookie de sesion:

- `GET /checkout/options`: lista direcciones, metodos enmascarados, tipos y ordenes del usuario;
- `POST /checkout/addresses`: registra una direccion propia;
- `POST /checkout/payment-methods`: registra un metodo de pago propio.

El frontend muestra etiquetas legibles y envia internamente `addressId` y
`paymentMethodId`. La API nunca devuelve CVV ni el numero completo de tarjeta.

Una conexion sin sesion se cierra con codigo `4401`; intentar reutilizar una
conversacion ajena se cierra con `4403`.

Los endpoints de historial tambien necesitan la cookie. Para listar se usa
`GET /users/{id-del-usuario-autenticado}/conversations`. Consultar, cerrar o
eliminar una conversacion ajena es rechazado por la API.
