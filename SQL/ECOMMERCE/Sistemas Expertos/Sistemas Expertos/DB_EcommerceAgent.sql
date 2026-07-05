CREATE DATABASE [DB_EcommerceAgent]
GO

USE [DB_EcommerceAgent]
GO

-- 1. CREACIÓN DE LA TABLA PRINCIPAL: REGLAS
-- Aquí guardamos QUÉ debe hacer el bot cuando se activa una regla.
CREATE TABLE ReglasChatbot (
    ReglaID INT PRIMARY KEY IDENTITY(1,1),
    NombreRegla VARCHAR(100) NOT NULL,
    AccionDinamica BIT NOT NULL,     -- 'TEXTO_ESTATICO' o 'ACCION_DINAMICA'
    AccionPython VARCHAR(100) NULL,         -- Nombre de la función en Python (si es dinámica)
    Activo BIT                    -- Para activar/desactivar reglas fácilmente
);

-- 2. CREACIÓN DE LA TABLA SECUNDARIA: PALABRAS CLAVE (TRIGGERS)
-- Aquí guardamos las palabras que el usuario podría escribir para activar la regla.
CREATE TABLE PalabrasClaveRegla (
    PalabraClaveID INT PRIMARY KEY IDENTITY(1,1),
    ReglaID INT NOT NULL REFERENCES ReglasChatbot(ReglaID),
    PalabraClave VARCHAR(100) NOT NULL,
	Activo BIT
);

-- =====================================================================
-- 1. TABLA: VARIACIONES DE RESPUESTAS (PLANTILLAS DE SALIDA)
-- Modificamos el enfoque anterior para que una regla tenga MUCHAS opciones de respuesta.
-- =====================================================================

-- Primero, una buena práctica: si ya creaste la tabla 'ReglasChatbot' con la columna 'RespuestaTexto',
-- la eliminamos de ahí porque ahora vivirá de forma más organizada en esta nueva tabla.
CREATE TABLE PlantillasRespuesta (
    PlantillaID INT IDENTITY(1,1) PRIMARY KEY,
    ReglaID INT NOT NULL REFERENCES ReglasChatbot(ReglaID),
    TextoRespuesta NVARCHAR(MAX) NOT NULL, -- La frase exacta que dirá el bot
    Activo BIT
);


-- =====================================================================
-- 2. TABLA: HISTORIAL DE CONVERSACIONES (LOGS DE ENTRADA Y SALIDA)
-- Aquí se almacena la interacción real del e-commerce. Todo lo que entra y sale.
-- =====================================================================
CREATE TABLE HistorialConversaciones
(
	ConversacionID BIGINT IDENTITY(1,1) PRIMARY KEY,
	UsuarioID VARCHAR(100) NOT NULL,
	FechaInicio DATETIME NOT NULL,
	FechaFin DATETIME NULL,
	Activo BIT
)

CREATE TABLE HistorialMensajes (
    MensajeID BIGINT IDENTITY(1,1) PRIMARY KEY,
	ConversacionID BIGINT REFERENCES HistorialConversaciones (ConversacionID) NOT NULL,
    ChatBot BIT NOT NULL,           -- 'USUARIO' o 'SISTEMA'
    Texto VARCHAR(1000) NOT NULL,             -- El mensaje de texto enviado o recibido
    FechaHora DATETIME NOT NULL,     -- Momento exacto de la interacción
    ReglaActivadaID INT REFERENCES ReglasChatbot(ReglaID),               -- Qué regla del sistema experto respondió (si fue el SISTEMA)       
);


-- =====================================================================
-- 3. DATOS DE PRUEBA PARA LAS NUEVAS TABLAS
-- =====================================================================
-- 3. INSERCIÓN DE DATOS DE PRUEBA (Caso E-commerce)
-- Insertamos primero las Reglas del Sistema Experto
INSERT INTO ReglasChatbot (NombreRegla, AccionDinamica, AccionPython, Activo)
VALUES 
('Saludo Inicial', 1,  'cargar_saludos_db', 1),
('Buscar Producto', 1, 'buscar_producto_en_db',1);

-- Insertamos las Palabras Clave asociadas a cada Regla (usando los IDs generados)
-- Suponiendo que 'Saludo Inicial' es ID 1, 'Buscar Producto' es ID 2, y 'Soporte Humano' es ID 3
INSERT INTO PalabrasClaveRegla (ReglaID, PalabraClave, Activo)
VALUES 
(1, 'hola',1),
(1, 'buenos dias',1),
(1, 'buenas tardes',1),
(1, 'buenas noches',1),
(2, 'tienen',1),
(2, 'buscar',1),
(2, 'precio',1),
(2, 'stock',1),
(2, 'producto',1);

-- Agregamos múltiples opciones de respuesta para el 'Saludo Inicial' (Asumiendo que es el ReglaID = 1)
INSERT INTO PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
VALUES 
(1, '¡Hola! Bienvenido a nuestra tienda. ¿En qué te puedo colaborar hoy?', 1),
(1, '¡Qué gusto tenerte de vuelta! ¿Buscas algún producto en nuestro catálogo?',1),
(1, 'Hola, soy tu asistente de compras virtuales. ¿Deseas buscar un artículo o ver el estado de un pedido?',1);

INSERT INTO PlantillasRespuesta (ReglaID, TextoRespuesta, Activo)
VALUES 
(2, '¡He encontrado estas opciones para que puedas revisarlas!', 1),
(2, '¡Hola! Claro que sí, con gusto te ayudo a encontrar lo que necesitas.
Para mostrarte las opciones correctas, ¿qué tipo de producto estás buscando hoy?',1),
(2, '¡Buenas noticias! Sí tenemos disponible. Puedes ver los detalles, precio y fotos directamente aquí',1);

SELECT *
FROM ReglasChatbot

SELECT *
FROM PalabrasClaveRegla

SELECT *
FROM PlantillasRespuesta

UPDATE PlantillasRespuesta
SET TextoRespuesta = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(TextoRespuesta, '[@TABLA]', ''),'[@MESSAGE]',''),'\n','')))
WHERE PlantillaID = 5

SELECT *
FROM HistorialMensajes

DECLARE @TEXTO1 VARCHAR(200) = '¡Buenas noticias! Sí tenemos disponible. Puedes ver los detalles, precio y fotos directamente aquí [@ENLACE]'
DECLARE @TEXTO2 VARCHAR(50) = 'https://amazon.com'
DECLARE @TEXTO3 VARCHAR(200) = '¡Hola! Claro que sí, con gusto te ayudo a encontrar lo que necesitas. Para mostrarte las opciones correctas, ¿qué tipo de producto estás buscando hoy? \n Elige una de las siguientes opciones: [TABLA]'

SELECT REPLACE(@TEXTO1, '[@ENLACE]', @TEXTO2)

DECLARE
	@Code INT,
	@Message VARCHAR(255),
	@TemplateId INT

DECLARE @TABLA AS TABLE(
	categoryId INT,
	categoryName VARCHAR(50),
	categoryDescription VARCHAR(100)
)

INSERT INTO @TABLA (categoryId, categoryName, categoryDescription)
EXEC DB_ECOMMERCE..USP_CATEGORIES
@w_methodType = 'LIST',
@o_code = @Code OUT,
@o_message  = @Message OUT,
@o_templateId = @TemplateId OUT

--SELECT categoryName
--FROM @TABLA

--PRINT 'Code: ' + CAST(@Code AS VARCHAR)
--PRINT 'Message: ' + @Message
--PRINT 'TemplateId: ' + CAST(@TemplateId AS VARCHAR)

DECLARE @Plantilla NVARCHAR(MAX)

SELECT @Plantilla = TextoRespuesta
FROM PlantillasRespuesta
WHERE PlantillaID = @TemplateId

SET @Plantilla = @Plantilla
+ CHAR(13) + CHAR(10) + @Message
+ CHAR(13) + CHAR(10) + '[@TABLA]';


PRINT @Plantilla