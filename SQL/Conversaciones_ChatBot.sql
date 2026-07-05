USE DB_EcommerceAgent
GO

CREATE TABLE Conversaciones (
    ConversationId NVARCHAR(50) PRIMARY KEY,
    UserId NVARCHAR(50),
    Language NVARCHAR(10),
    LastIntent NVARCHAR(50),
    CartId NVARCHAR(50),
    OrderId NVARCHAR(50),
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Mensajes (
    Id INT IDENTITY PRIMARY KEY,
    ConversationId NVARCHAR(50),
    Role NVARCHAR(20),
    Timestamp DATETIME,
    Intent NVARCHAR(50),
    Content NVARCHAR(MAX),
    Metadata NVARCHAR(MAX) -- Guardamos JSON dinamico aqui
);
GO

SELECT *
FROM Conversaciones

SELECT *
FROM Mensajes

CREATE OR ALTER PROCEDURE sp_GuardarConversacion
    @ConversationJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ConversationId NVARCHAR(50);
    DECLARE @UserId NVARCHAR(50);
    DECLARE @Language NVARCHAR(10);
    DECLARE @LastIntent NVARCHAR(50);
    DECLARE @CartId NVARCHAR(50);
    DECLARE @OrderId NVARCHAR(50);

    -- Extraer datos principales
    SELECT 
        @ConversationId = conversation_id,
        @UserId = user_id
    FROM OPENJSON(@ConversationJson)
    WITH (
        conversation_id NVARCHAR(50) '$.conversation_id',
        user_id NVARCHAR(50) '$.user_id'
    );

    -- Extraer contexto
    SELECT 
        @Language = language,
        @LastIntent = last_intent,
        @CartId = cart_id,
        @OrderId = order_id
    FROM OPENJSON(@ConversationJson, '$.context')
    WITH (
        language NVARCHAR(10) '$.language',
        session_variables NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(session_variables)
    WITH (
        last_intent NVARCHAR(50) '$.last_intent',
        cart_id NVARCHAR(50) '$.cart_id',
        order_id NVARCHAR(50) '$.order_id'
    );

    -- Insertar conversaci�n
    INSERT INTO Conversaciones (ConversationId, UserId, Language, LastIntent, CartId, OrderId)
    VALUES (@ConversationId, @UserId, @Language, @LastIntent, @CartId, @OrderId);

    -- Insertar mensajes
    INSERT INTO Mensajes (ConversationId, Role, Timestamp, Intent, Content, Metadata)
    SELECT 
        @ConversationId,
        role,
        CAST(timestamp AS DATETIME),
        intent,
        content,
        metadata
    FROM OPENJSON(@ConversationJson, '$.messages')
    WITH (
        role NVARCHAR(20) '$.role',
        timestamp NVARCHAR(50) '$.timestamp',
        intent NVARCHAR(50) '$.intent',
        content NVARCHAR(MAX) '$.content',
        metadata NVARCHAR(MAX) '$.metadata' AS JSON
    );
END;


CREATE or ALTER PROCEDURE sp_ObtenerHistorialConversacion
    @ConversationId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        m.Id,
        m.Role,
        m.Timestamp,
        m.Intent,
        m.Content,
        m.Metadata
    FROM Mensajes m
    WHERE m.ConversationId = @ConversationId
    ORDER BY m.Timestamp ASC;
END;


EXEC sp_ObtenerHistorialConversacion
@ConversationId = 'abc123'