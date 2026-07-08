USE [DB_EcommerceAgent]
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
