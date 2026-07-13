USE [DB_ECOMMERCE]
GO

IF EXISTS
(
    SELECT userName
    FROM SQM_SECURITY.Tbl_Users
    GROUP BY userName
    HAVING COUNT(*) > 1
)
    THROW 50001, 'No se puede crear UX_Tbl_Users_UserName: existen usuarios duplicados.', 1;
GO

IF EXISTS
(
    SELECT userEmail
    FROM SQM_SECURITY.Tbl_Users
    GROUP BY userEmail
    HAVING COUNT(*) > 1
)
    THROW 50002, 'No se puede crear UX_Tbl_Users_UserEmail: existen correos duplicados.', 1;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_Tbl_Users_UserName'
      AND object_id = OBJECT_ID('SQM_SECURITY.Tbl_Users')
)
    CREATE UNIQUE INDEX UX_Tbl_Users_UserName
        ON SQM_SECURITY.Tbl_Users(userName);
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_Tbl_Users_UserEmail'
      AND object_id = OBJECT_ID('SQM_SECURITY.Tbl_Users')
)
    CREATE UNIQUE INDEX UX_Tbl_Users_UserEmail
        ON SQM_SECURITY.Tbl_Users(userEmail);
GO

IF NOT EXISTS
(
    SELECT 1
    FROM SQM_SECURITY.Tbl_Roles
    WHERE UPPER(RolName) = 'CLIENTE'
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userId = 1)
        THROW 50003, 'No se puede crear el rol CLIENTE: no existe el usuario interno con ID 1.', 1;

    INSERT INTO SQM_SECURITY.Tbl_Roles
    (
        RolName, RolDescription, RolCreatorId, RolCreationDate, RolStatusId
    )
    VALUES
    (
        'CLIENTE', 'Compras, carrito y consulta de sus ordenes', 1, GETDATE(), 1
    );
END
GO

CREATE OR ALTER PROCEDURE SQM_SECURITY.sp_RegistrarCliente
    @NombreCompleto VARCHAR(100),
    @NombreUsuario VARCHAR(50),
    @Correo VARCHAR(80),
    @Contrasena VARCHAR(256),
    @Telefono VARCHAR(20),
    @PaisID INT,
    @GeneroID INT,
    @FechaNacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NombreCompleto = LTRIM(RTRIM(@NombreCompleto));
    SET @NombreUsuario = UPPER(LTRIM(RTRIM(@NombreUsuario)));
    SET @Correo = LOWER(LTRIM(RTRIM(@Correo)));
    SET @Telefono = LTRIM(RTRIM(@Telefono));

    IF EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userName = @NombreUsuario)
        THROW 50011, '[DUPLICATE_USERNAME] El nombre de usuario ya esta registrado.', 1;

    IF EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userEmail = @Correo)
        THROW 50012, '[DUPLICATE_EMAIL] El correo ya esta registrado.', 1;

    DECLARE @EstadoActivoID INT =
    (
        SELECT TOP (1) statusId
        FROM SQM_CATALOGS.Tbl_Status
        WHERE UPPER(statusName) = 'ACTIVO' AND statusStatusId = 1
        ORDER BY statusId
    );
    DECLARE @RolClienteID INT =
    (
        SELECT TOP (1) RolId
        FROM SQM_SECURITY.Tbl_Roles
        WHERE UPPER(RolName) = 'CLIENTE' AND RolStatusId = 1
        ORDER BY RolId
    );

    IF @EstadoActivoID IS NULL
        THROW 50013, '[MISSING_ACTIVE_STATUS] No existe el estado ACTIVO.', 1;
    IF @RolClienteID IS NULL
        THROW 50014, '[MISSING_CLIENT_ROLE] No existe el rol CLIENTE.', 1;
    IF NOT EXISTS (SELECT 1 FROM SQM_SECURITY.Tbl_Users WHERE userId = 1)
        THROW 50015, '[MISSING_SYSTEM_USER] No existe el usuario interno con ID 1.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        OPEN SYMMETRIC KEY KEY_HASH
            DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

        INSERT INTO SQM_SECURITY.Tbl_Users
        (
            userFullName, userName, userPassword, userEmail, userPhoneNumber,
            userCountryId, userGenderId, userBirthDay, userCreatorId,
            userCreationDate, userStatusId
        )
        VALUES
        (
            @NombreCompleto, @NombreUsuario,
            SQM_SECURITY.Fn_EncryptByKey(@Contrasena), @Correo, @Telefono,
            @PaisID, @GeneroID, @FechaNacimiento, 1, GETDATE(), @EstadoActivoID
        );

        CLOSE SYMMETRIC KEY KEY_HASH;

        DECLARE @UsuarioID INT = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO SQM_SECURITY.Tbl_UserByRoles
        (
            UserByRolRolId, UserByRolUserId, UserByRolTypeCreatorId,
            UserByRolTypeCreationDate, UserByRolTypeStatusId
        )
        VALUES (@RolClienteID, @UsuarioID, @UsuarioID, GETDATE(), 1);

        COMMIT TRANSACTION;

        EXEC SQM_SECURITY.sp_ObtenerUsuarioSesion @UsuarioID = @UsuarioID;
    END TRY
    BEGIN CATCH
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'KEY_HASH')
            CLOSE SYMMETRIC KEY KEY_HASH;
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE SQM_SECURITY.sp_ObtenerUsuarioSesion
    @UsuarioID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        U.userId AS id,
        U.userName AS username,
        U.userFullName AS fullName,
        U.userEmail AS email,
        R.RolName AS role
    FROM SQM_SECURITY.Tbl_Users U
    INNER JOIN SQM_CATALOGS.Tbl_Status S ON S.statusId = U.userStatusId
    LEFT JOIN SQM_SECURITY.Tbl_UserByRoles UR
        ON UR.UserByRolUserId = U.userId AND UR.UserByRolTypeStatusId = 1
    LEFT JOIN SQM_SECURITY.Tbl_Roles R
        ON R.RolId = UR.UserByRolRolId AND R.RolStatusId = 1
    WHERE U.userId = @UsuarioID
      AND UPPER(S.statusName) = 'ACTIVO'
      AND S.statusStatusId = 1
    ORDER BY R.RolId;
END
GO

CREATE OR ALTER PROCEDURE SQM_SECURITY.sp_IniciarSesion
    @Identificador VARCHAR(80),
    @Contrasena VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsuarioID INT;

    OPEN SYMMETRIC KEY KEY_HASH
        DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

    SELECT TOP (1) @UsuarioID = U.userId
    FROM SQM_SECURITY.Tbl_Users U
    INNER JOIN SQM_CATALOGS.Tbl_Status S ON S.statusId = U.userStatusId
    WHERE (U.userName = UPPER(LTRIM(RTRIM(@Identificador)))
           OR U.userEmail = LOWER(LTRIM(RTRIM(@Identificador))))
      AND SQM_SECURITY.Fn_DecryptByKey(U.userPassword) = @Contrasena
      AND UPPER(S.statusName) = 'ACTIVO'
      AND S.statusStatusId = 1;

    CLOSE SYMMETRIC KEY KEY_HASH;

    IF @UsuarioID IS NOT NULL
        EXEC SQM_SECURITY.sp_ObtenerUsuarioSesion @UsuarioID = @UsuarioID;
END
GO
