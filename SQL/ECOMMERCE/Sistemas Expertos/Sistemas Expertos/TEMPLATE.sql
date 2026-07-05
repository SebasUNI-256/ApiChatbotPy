USE DB_EcommerceAgent
GO

--SELECT *
--FROM ReglasChatbot

DECLARE
	@Code INT,
	@Message VARCHAR(255),
	@TemplateId INT,
	@Plantilla NVARCHAR(MAX),
	@ResponseTabla NVARCHAR(MAX);

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

SELECT @Plantilla = TextoRespuesta
FROM PlantillasRespuesta
WHERE PlantillaID = @TemplateId

SET @Plantilla = @Plantilla
+ CHAR(13) + CHAR(10) + @Message
+ CHAR(13) + CHAR(10) + '[@TABLA]';

SELECT @ResponseTabla = STRING_AGG('-> ' + categoryName, CHAR(13) + CHAR(10))
FROM (
    SELECT categoryName
	FROM @TABLA
) AS MisProductos;

SET @Plantilla = REPLACE(@Plantilla, '[@TABLA]', ISNULL(@ResponseTabla, @Message));

PRINT @Plantilla