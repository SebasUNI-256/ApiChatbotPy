
USE [DB_EcommerceAgent]
GO

-- =====================================================================
-- VARIABLES PARA CAPTURAR LOS ID DE LAS REGLAS RECIÉN CREADAS
-- =====================================================================
DECLARE @ReglaSaludoID INT;
DECLARE @ReglaBusquedaID INT;
DECLARE @ReglaNoEntendidoID INT;

-- =====================================================================
-- REQUERIMIENTOS A, B, C: CONFIGURAR REGLAS DE AGENTE
-- =====================================================================

-- A. CONFIGURAR REGLA DE AGENTE PARA SALUDOS INICIAL (Se agrega 1 principal y variaciones o subreglas de saludo si aplica, aquí insertamos la principal y complementarias)
INSERT INTO ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
VALUES ('Saludo Inicial Estándar', 1, 'cargar_saludos_db', 1);
SET @ReglaSaludoID = SCOPE_IDENTITY(); -- Guardamos el ID para usarlo abajo

-- B. CONFIGURAR REGLA DE AGENTE PARA BUSQUEDA DE PRODUCTOS
INSERT INTO ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
VALUES ('Búsqueda Catálogo General', 1, 'buscar_producto_en_db', 1);
SET @ReglaBusquedaID = SCOPE_IDENTITY(); -- Guardamos el ID para usarlo abajo

-- C. CONFIGURAR REGLA DE AGENTE PARA INDICAR QUE NO ENTENDIÓ LA PETICIÓN (Fallback)
INSERT INTO ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
VALUES ('Petición No Entendida', 0, NULL, 1);
SET @ReglaNoEntendidoID = SCOPE_IDENTITY(); -- Guardamos el ID para usarlo abajo

-- Reglas adicionales para cumplir con el mínimo de 5 en la tabla ReglasChatbot
INSERT INTO ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
VALUES 
('Saludo Clientes VIP', 1, 'verificar_vip_saludo', 1),
('Búsqueda por Ofertas/Descuentos', 1, 'buscar_ofertas_db', 1);


-- =====================================================================
-- REQUERIMIENTO D: CONFIGURAR PALABRAS CLAVES PARA SALUDO INICIAL (Mínimo 5)
-- =====================================================================
INSERT INTO PalabrasClaveRegla (ReglaID, PalabraClave, Activo)
VALUES 
(@ReglaSaludoID, 'hola', 1),
(@ReglaSaludoID, 'buenos dias', 1),
(@ReglaSaludoID, 'buenas tardes', 1),
(@ReglaSaludoID, 'que tal', 1),
(@ReglaSaludoID, 'iniciar', 1);


-- =====================================================================
-- REQUERIMIENTO E: CONFIGURAR PALABRAS CLAVES PARA BUSQUEDA DE PRODUCTOS (Mínimo 5)
-- =====================================================================
INSERT INTO PalabrasClaveRegla (ReglaID, PalabraClave, Activo)
VALUES 
(@ReglaBusquedaID, 'buscar', 1),
(@ReglaBusquedaID, 'precio', 1),
(@ReglaBusquedaID, 'tienen', 1),
(@ReglaBusquedaID, 'comprar', 1),
(@ReglaBusquedaID, 'catalogo', 1);


-- =====================================================================
-- REQUERIMIENTO F: CONFIGURAR RESPUESTAS DE AGENTE PARA SALUDO INICIAL (Mínimo 5)
-- =====================================================================
INSERT INTO PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
VALUES 
(@ReglaSaludoID, '¡Hola! Bienvenido a nuestra tienda virtual. ¿En qué te puedo colaborar hoy?', 1),
(@ReglaSaludoID, '¡Qué gusto tenerte aquí! ¿Buscas algún producto en nuestro catálogo o quieres revisar un pedido?', 1),
(@ReglaSaludoID, 'Hola, soy tu asistente de compras. Dime qué artículo estás buscando hoy y lo encuentro por ti.', 1),
(@ReglaSaludoID, '¡Bienvenido! Recuerda que hoy tenemos envío gratis en categorías seleccionadas. ¿Qué te gustaría buscar?', 1),
(@ReglaSaludoID, '¡Hola, hola! Estoy listo para ayudarte a encontrar las mejores ofertas. ¿Qué necesitas comprar?', 1);


-- =====================================================================
-- REQUERIMIENTO G: CONFIGURAR RESPUESTAS DE AGENTE PARA BUSQUEDA DE PRODUCTOS (Mínimo 5)
-- =====================================================================
INSERT INTO PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
VALUES 
(@ReglaBusquedaID, '¡He encontrado estas opciones en nuestro sistema para ti! [@MESSAGE] [@TABLA]', 1),
(@ReglaBusquedaID, 'Claro que sí, déjame revisar nuestro stock. Para darte un mejor resultado, ¿me podrías decir la marca o color? [@MESSAGE]', 1),
(@ReglaBusquedaID, '¡Buenas noticias! Sí lo tenemos disponible. Aquí puedes ver los detalles, precios y fotos: [@TABLA]', 1),
(@ReglaBusquedaID, 'Estoy buscando en el catálogo... Aquí tienes los resultados más relevantes para tu búsqueda: [@MESSAGE]', 1),
(@ReglaBusquedaID, '¡Encontrado! Te comparto la lista de precios y la disponibilidad actual: [@TABLA]', 1);


-- =====================================================================
-- REQUERIMIENTO H: CONFIGURAR RESPUESTA DE AGENTE PARA INDICAR QUE NO ENTENDIMOS LA PETICION (Mínimo 5)
-- =====================================================================
INSERT INTO PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
VALUES 
(@ReglaNoEntendidoID, 'Lo siento, no logré comprender tu solicitud. ¿Podrías intentar escribirlo de otra manera?', 1),
(@ReglaNoEntendidoID, '¡Vaya! No encontré coincidencias con lo que escribiste. Recuerda que puedo ayudarte a buscar productos escribiendo "buscar [producto]".', 1),
(@ReglaNoEntendidoID, 'Disculpa, soy un bot en entrenamiento y no entendí tu mensaje. ¿Me lo repites de forma más sencilla?', 1),
(@ReglaNoEntendidoID, 'No estoy seguro de haber entendido bien. Si buscas un producto, escribe su nombre o pide ver el "catálogo".', 1),
(@ReglaNoEntendidoID, 'Uuups, mi sistema no reconoció esa frase. Intenta usando palabras clave como: precio, stock o el nombre directo del artículo.', 1);