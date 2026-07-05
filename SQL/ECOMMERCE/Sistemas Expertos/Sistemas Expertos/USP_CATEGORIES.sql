USE DB_ECOMMERCE
GO

CREATE OR ALTER PROC USP_CATEGORIES
(
@i_categoryId INT = NULL,
@i_categoryName VARCHAR (50) = NULL,
@i_categoryStatusId BIT = NULL,
@w_methodType CHAR(5),
@o_code INT = NULL OUTPUT,
@o_message VARCHAR(255) = NULL OUTPUT,
@o_templateId INT = NULL OUTPUT
)
AS
BEGIN

	IF(@w_methodType = 'LIST')
	BEGIN
		SELECT
			categoryId,
			categoryName,
			categoryDescription
		FROM [SQM_CATALOGS].[Tbl_Categories]
		WHERE categoryStatusId = 1
		ORDER BY categoryId DESC

		IF (@@ROWCOUNT > 0)
		BEGIN
			SET @o_code = 200;
			SET @o_templateId = 5;
			SET @o_message = 'Elige una de las siguientes opciones:';
		END
		ELSE
		BEGIN
			SET @o_code = 404
			SET @o_templateId = 5
			SET @o_message = 'No hay opciones disponibles';
		END
	END
END