USE [DB_EcommerceAgent]
GO

DECLARE @CartRules TABLE
(
    NombreRegla VARCHAR(100) NOT NULL,
    AccionPython VARCHAR(100) NOT NULL
);

INSERT INTO @CartRules (NombreRegla, AccionPython)
VALUES
('Agregar Producto al Carrito', 'agregar_carrito_db'),
('Consultar Carrito', 'consultar_carrito_db'),
('Eliminar Producto del Carrito', 'eliminar_producto_carrito_db'),
('Procesar Pago del Carrito', 'procesar_pago_carrito_db'),
('Consultar Orden de Pago', 'consultar_orden_pago_db');

UPDATE R
SET R.AccionDinamica = 1,
    R.AccionPython = C.AccionPython,
    R.Activo = 1
FROM dbo.ReglasChatbot R
INNER JOIN @CartRules C
    ON C.NombreRegla = R.NombreRegla;

INSERT INTO dbo.ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
SELECT C.NombreRegla, 1, C.AccionPython, 1
FROM @CartRules C
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.ReglasChatbot R
    WHERE R.NombreRegla = C.NombreRegla
);

DECLARE @CartKeywords TABLE
(
    NombreRegla VARCHAR(100) NOT NULL,
    PalabraClave VARCHAR(100) NOT NULL
);

INSERT INTO @CartKeywords (NombreRegla, PalabraClave)
VALUES
('Agregar Producto al Carrito', 'agregar al carrito'),
('Agregar Producto al Carrito', 'anadir al carrito'),
('Agregar Producto al Carrito', 'agregar producto'),
('Agregar Producto al Carrito', 'anadir producto'),
('Agregar Producto al Carrito', 'llevar al carrito'),
('Consultar Carrito', 'ver carrito'),
('Consultar Carrito', 'mi carrito'),
('Consultar Carrito', 'consultar carrito'),
('Consultar Carrito', 'productos carrito'),
('Consultar Carrito', 'mostrar carrito'),
('Eliminar Producto del Carrito', 'eliminar del carrito'),
('Eliminar Producto del Carrito', 'quitar del carrito'),
('Eliminar Producto del Carrito', 'borrar del carrito'),
('Eliminar Producto del Carrito', 'remover del carrito'),
('Eliminar Producto del Carrito', 'sacar del carrito'),
('Procesar Pago del Carrito', 'pagar'),
('Procesar Pago del Carrito', 'checkout'),
('Procesar Pago del Carrito', 'finalizar compra'),
('Procesar Pago del Carrito', 'procesar pago'),
('Procesar Pago del Carrito', 'realizar pago'),
('Consultar Orden de Pago', 'consultar orden'),
('Consultar Orden de Pago', 'estado pedido'),
('Consultar Orden de Pago', 'ver pedido'),
('Consultar Orden de Pago', 'seguimiento pedido'),
('Consultar Orden de Pago', 'ver orden');

INSERT INTO dbo.PalabrasClaveRegla (ReglaID, PalabraClave, Activo)
SELECT R.ReglaID, K.PalabraClave, 1
FROM @CartKeywords K
INNER JOIN dbo.ReglasChatbot R
    ON R.NombreRegla = K.NombreRegla
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PalabrasClaveRegla P
    WHERE P.ReglaID = R.ReglaID
      AND LOWER(P.PalabraClave) = LOWER(K.PalabraClave)
);

DECLARE @CartTemplates TABLE
(
    NombreRegla VARCHAR(100) NOT NULL,
    TextoRespuesta NVARCHAR(MAX) NOT NULL
);

INSERT INTO @CartTemplates (NombreRegla, TextoRespuesta)
VALUES
('Agregar Producto al Carrito', N'Producto agregado correctamente a tu carrito.'),
('Agregar Producto al Carrito', N'He actualizado tu carrito con el producto solicitado.'),
('Agregar Producto al Carrito', N'Listo, el producto ya esta en tu carrito.'),
('Agregar Producto al Carrito', N'El articulo fue agregado al carrito.'),
('Agregar Producto al Carrito', N'Tu carrito fue actualizado correctamente.'),
('Consultar Carrito', N'Este es el contenido actual de tu carrito.'),
('Consultar Carrito', N'Estos son los productos que tienes en el carrito.'),
('Consultar Carrito', N'He consultado tu carrito.'),
('Consultar Carrito', N'Aqui tienes el resumen de tu carrito.'),
('Consultar Carrito', N'Tu carrito contiene los siguientes productos.'),
('Eliminar Producto del Carrito', N'El producto fue eliminado de tu carrito.'),
('Eliminar Producto del Carrito', N'He quitado el articulo solicitado.'),
('Eliminar Producto del Carrito', N'Tu carrito fue actualizado despues de eliminar el producto.'),
('Eliminar Producto del Carrito', N'El articulo ya no forma parte de tu carrito.'),
('Eliminar Producto del Carrito', N'Producto eliminado correctamente.'),
('Procesar Pago del Carrito', N'Tu pago fue procesado correctamente.'),
('Procesar Pago del Carrito', N'La compra fue finalizada y la orden fue creada.'),
('Procesar Pago del Carrito', N'Listo, tu orden de pago fue registrada.'),
('Procesar Pago del Carrito', N'El pago se completo correctamente.'),
('Procesar Pago del Carrito', N'Tu compra fue procesada con exito.'),
('Consultar Orden de Pago', N'Esta es la informacion de tu orden.'),
('Consultar Orden de Pago', N'He encontrado los detalles de tu pedido.'),
('Consultar Orden de Pago', N'Aqui tienes el estado de tu orden.'),
('Consultar Orden de Pago', N'Estos son los datos registrados para tu orden.'),
('Consultar Orden de Pago', N'Este es el seguimiento actual de tu pedido.');

INSERT INTO dbo.PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
SELECT R.ReglaID, T.TextoRespuesta, 1
FROM @CartTemplates T
INNER JOIN dbo.ReglasChatbot R
    ON R.NombreRegla = T.NombreRegla
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PlantillasRespuesta P
    WHERE P.ReglaID = R.ReglaID
      AND P.TextoRespuesta = T.TextoRespuesta
);
GO

SET NOCOUNT ON;

DECLARE @ReglaSaludoID INT;
DECLARE @ReglaBusquedaID INT;
DECLARE @ReglaNoEntendidoID INT;
DECLARE @ReglaVipID INT;
DECLARE @ReglaOfertasID INT;

IF NOT EXISTS (SELECT 1 FROM dbo.ReglasChatbot WHERE NombreRegla = 'Saludo Inicial')
BEGIN
    INSERT INTO dbo.ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
    VALUES ('Saludo Inicial', 1, 'cargar_saludos_db', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ReglasChatbot WHERE NombreRegla = 'Buscar Producto')
BEGIN
    INSERT INTO dbo.ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
    VALUES ('Buscar Producto', 1, 'buscar_producto_en_db', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ReglasChatbot WHERE NombreRegla = 'No Entendimos La Peticion')
BEGIN
    INSERT INTO dbo.ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
    VALUES ('No Entendimos La Peticion', 0, 'manejar_no_entendido', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ReglasChatbot WHERE NombreRegla = 'Saludo Clientes VIP')
BEGIN
    INSERT INTO dbo.ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
    VALUES ('Saludo Clientes VIP', 1, 'verificar_vip_saludo', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ReglasChatbot WHERE NombreRegla = 'Busqueda por Ofertas Descuentos')
BEGIN
    INSERT INTO dbo.ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
    VALUES ('Busqueda por Ofertas Descuentos', 1, 'buscar_ofertas_db', 1);
END;

SELECT @ReglaSaludoID = ReglaID FROM dbo.ReglasChatbot WHERE NombreRegla = 'Saludo Inicial';
SELECT @ReglaBusquedaID = ReglaID FROM dbo.ReglasChatbot WHERE NombreRegla = 'Buscar Producto';
SELECT @ReglaNoEntendidoID = ReglaID FROM dbo.ReglasChatbot WHERE NombreRegla = 'No Entendimos La Peticion';
SELECT @ReglaVipID = ReglaID FROM dbo.ReglasChatbot WHERE NombreRegla = 'Saludo Clientes VIP';
SELECT @ReglaOfertasID = ReglaID FROM dbo.ReglasChatbot WHERE NombreRegla = 'Busqueda por Ofertas Descuentos';

DECLARE @Keywords TABLE
(
    ReglaID INT NOT NULL,
    PalabraClave VARCHAR(100) NOT NULL
);

INSERT INTO @Keywords (ReglaID, PalabraClave)
VALUES
(@ReglaSaludoID, 'hola'),
(@ReglaSaludoID, 'buenos dias'),
(@ReglaSaludoID, 'buenas tardes'),
(@ReglaSaludoID, 'buenas noches'),
(@ReglaSaludoID, 'que tal'),
(@ReglaSaludoID, 'iniciar'),
(@ReglaBusquedaID, 'buscar'),
(@ReglaBusquedaID, 'busco'),
(@ReglaBusquedaID, 'precio'),
(@ReglaBusquedaID, 'tienen'),
(@ReglaBusquedaID, 'comprar'),
(@ReglaBusquedaID, 'catalogo'),
(@ReglaBusquedaID, 'necesito'),
(@ReglaBusquedaID, 'quiero'),
(@ReglaBusquedaID, 'stock'),
(@ReglaBusquedaID, 'producto'),
(@ReglaOfertasID, 'oferta'),
(@ReglaOfertasID, 'ofertas'),
(@ReglaOfertasID, 'descuento'),
(@ReglaOfertasID, 'descuentos'),
(@ReglaOfertasID, 'promocion');

INSERT INTO dbo.PalabrasClaveRegla (ReglaID, PalabraClave, Activo)
SELECT k.ReglaID, k.PalabraClave, 1
FROM @Keywords k
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PalabrasClaveRegla p
    WHERE p.ReglaID = k.ReglaID
      AND LOWER(p.PalabraClave) = LOWER(k.PalabraClave)
);

DECLARE @Plantillas TABLE
(
    ReglaID INT NOT NULL,
    TextoRespuesta NVARCHAR(MAX) NOT NULL
);

INSERT INTO @Plantillas (ReglaID, TextoRespuesta)
VALUES
(@ReglaSaludoID, N'Hola, bienvenido a nuestra tienda. En que te puedo ayudar hoy?'),
(@ReglaSaludoID, N'Que gusto tenerte de vuelta. Buscas algun producto de nuestro catalogo?'),
(@ReglaSaludoID, N'Hola, soy tu asistente de compras virtuales. Deseas buscar un articulo o ver el estado de un pedido?'),
(@ReglaSaludoID, N'Bienvenido. Puedo ayudarte a buscar productos, precios y disponibilidad.'),
(@ReglaSaludoID, N'Hola. Estoy listo para ayudarte a encontrar lo que necesitas comprar.'),
(@ReglaBusquedaID, N'He encontrado estas opciones para que puedas revisarlas.'),
(@ReglaBusquedaID, N'Buenas noticias. Si tenemos disponible. Puedes revisar estas opciones.'),
(@ReglaBusquedaID, N'Hola. Claro que si, con gusto te ayudo a encontrar lo que necesitas. Que tipo de producto estas buscando hoy?'),
(@ReglaBusquedaID, N'Estoy revisando el catalogo. Estos son los resultados mas relevantes.'),
(@ReglaBusquedaID, N'Encontrado. Te comparto la lista de precios y disponibilidad actual.'),
(@ReglaNoEntendidoID, N'No entendi tu peticion. Puedes saludarme o escribirme el producto que deseas buscar.'),
(@ReglaNoEntendidoID, N'No logre identificar lo que necesitas. Intenta con palabras como hola, buscar, precio o el nombre del producto.'),
(@ReglaNoEntendidoID, N'Disculpa, no comprendi tu mensaje. Puedes escribirlo de otra forma?'),
(@ReglaNoEntendidoID, N'No estoy seguro de haber entendido. Si buscas un producto, escribe su nombre o pide ver el catalogo.'),
(@ReglaNoEntendidoID, N'Mi sistema no reconocio esa frase. Intenta usando precio, stock o el nombre del articulo.'),
(@ReglaOfertasID, N'Puedo ayudarte a revisar productos disponibles. Por ahora las ofertas se consultan sobre el catalogo general.'),
(@ReglaOfertasID, N'Buscare opciones relacionadas con ofertas o descuentos en el catalogo disponible.'),
(@ReglaOfertasID, N'Estas son las opciones disponibles que podrian interesarte.'),
(@ReglaOfertasID, N'Voy a revisar el catalogo para encontrar alternativas convenientes.'),
(@ReglaOfertasID, N'Si buscas descuentos, dime tambien la categoria o producto que te interesa.');

INSERT INTO dbo.PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
SELECT t.ReglaID, t.TextoRespuesta, 1
FROM @Plantillas t
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PlantillasRespuesta p
    WHERE p.ReglaID = t.ReglaID
      AND p.TextoRespuesta = t.TextoRespuesta
);
GO
