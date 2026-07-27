# Ejemplos JavaScript

Los ejemplos usan JavaScript del navegador sin dependencias. Pueden envolverse en
servicios de React, Vue u otro framework sin cambiar el contrato.

## Configuracion

```javascript
const API_URL = "http://localhost:8000";
const WS_URL = "ws://localhost:8000/ws/chat";

async function apiFetch(path, options = {}) {
  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...options.headers,
    },
  });

  const body = await response.json();
  if (!response.ok) {
    throw new Error(body.detail ?? body.resultMessage ?? "Error de la API");
  }
  return body;
}
```

## Registro, login y sesion

```javascript
const registration = await apiFetch("/auth/register", {
  method: "POST",
  body: JSON.stringify({
    fullName: "Juan Perez",
    username: "JUANP",
    email: "juan@example.com",
    password: "ClaveSegura123!",
    phoneNumber: "88888888",
    countryId: 1,
    genderId: 2,
    birthDate: "2000-05-12",
  }),
});

const login = await apiFetch("/auth/login", {
  method: "POST",
  body: JSON.stringify({
    identifier: "JUANP",
    password: "ClaveSegura123!",
  }),
});

const session = await apiFetch("/auth/session");
console.log(session.user);

await apiFetch("/auth/logout", { method: "POST" });
```

Abre el WebSocket despues de registrar, iniciar o restaurar la sesion, no antes.

## Cliente WebSocket minimo

```javascript
let conversationId = null;
const socket = new WebSocket(WS_URL);

socket.addEventListener("message", (event) => {
  const response = JSON.parse(event.data);

  if (response.conversationId != null) {
    conversationId = response.conversationId;
  }

  if (response.resultCode >= 400) {
    console.error(response.resultMessage);
    return;
  }

  console.log("Bot:", response.reply);
  console.log("Productos:", response.products);
  console.log("Carrito u orden:", response.data);
});

socket.addEventListener("close", (event) => {
  if (event.code === 4401) {
    console.log("La sesion vencio; vuelve a iniciar sesion.");
  } else if (event.code === 4403) {
    console.log("La conversacion no pertenece al usuario.");
  }
});

function sendChat(message, parameters) {
  if (socket.readyState !== WebSocket.OPEN) {
    throw new Error("El chat todavia no esta conectado.");
  }

  socket.send(JSON.stringify({
    message,
    conversationId,
    ...(parameters ? { parameters } : {}),
  }));
}
```

## Buscar productos

```javascript
sendChat("quiero tenis");
```

Lee los resultados desde `response.products`. Para añadir un producto usa su
`ProductVariableID`, no `ProductID`.

## Agregar al carrito

```javascript
sendChat("agregar al carrito", {
  productVariableId: selectedProduct.ProductVariableID,
  quantity: 2,
});
```

`response.data` contiene el carrito actualizado.

## Consultar carrito

```javascript
sendChat("ver carrito");
```

## Eliminar del carrito

```javascript
sendChat("quitar del carrito", {
  cartDetailId: selectedCartLine.cartDetailId,
});
```

## Procesar pago

```javascript
sendChat("procesar pago", {
  addressId: selectedAddressId,
  paymentMethodId: selectedPaymentMethodId,
});
```

La API actual no permite obtener ni registrar esos dos IDs. No habilites esta
accion hasta que existan valores validos proporcionados por el sistema.

## Consultar orden

```javascript
sendChat("consultar orden", {
  orderId: selectedOrder.orderId,
});
```

## Historial

```javascript
const userId = session.user.id;

const conversations = await apiFetch(`/users/${userId}/conversations`);
const messages = await apiFetch(`/conversations/${conversationId}/messages`);

await apiFetch(`/conversations/${conversationId}/close`, {
  method: "POST",
});

await apiFetch(`/conversations/${conversationId}`, {
  method: "DELETE",
});
```

El frontend puede conservar `conversationId` en el estado de la aplicacion. No
debe usarlo como autorizacion: la API siempre comprueba que pertenezca a la sesion.
