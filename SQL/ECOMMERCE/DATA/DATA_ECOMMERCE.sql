USE DB_ECOMMERCE
GO

INSERT INTO [SQM_CATALOGS].[Tbl_Status](statusName,statusCreatorId,statusCreationDate,statusStatusId)
VALUES
('ACTIVO', 1, GETDATE(), 1),
('INACTIVO', 1, GETDATE(), 1),
('BLOQUEADO', 1, GETDATE(), 1),
('PROCESADO', 1, GETDATE(), 1),
('ENTREGADO', 1, GETDATE(), 1),
('ANULADO', 1, GETDATE(), 1);

----------------------------------------
/* USO DE FUNCIONES ESCALARES         */
----------------------------------------
OPEN SYMMETRIC KEY KEY_HASH
DECRYPTION BY CERTIFICATE CERT_ECOMMERCE;

  DECLARE
	@UserPassword VARCHAR(256),
	@UserPasswordEncrypted VARBINARY(256)
  SET @UserPassword = '12345'
  SET @UserPasswordEncrypted = SQM_SECURITY.Fn_EncryptByKey(@UserPassword)
CLOSE SYMMETRIC KEY KEY_HASH;

INSERT INTO [SQM_SECURITY].[Tbl_Users](userFullName,userName,userPassword,userEmail,userPhoneNumber,userCountryId,userGenderId,userBirthDay,userCreatorId,userCreationDate,userStatusId)
VALUES
('HECTOR JOSE CALERO ALANIZ', 'HCALERO', @UserPasswordEncrypted, 'hcalero@dominio.local','88888888', 1, 2,'2000-05-12', 1, GETDATE(), 1),
('DAVID JOSHUA JIMENEZ URBINA', 'DURBINA', @UserPasswordEncrypted, 'durbina@dominio.local','99999999', 1, 2,'1995-10-21', 1, GETDATE(), 1);


INSERT INTO [SQM_GENERAL].[Tbl_UserAddress](userAddressUserId,userAddressCountryId,userAddressZIPCode,userAddressDescription,userAddressIsPrincipal,userAddressCreatorId,userAddressCreationDate,userAddressStatusId)
VALUES (1,1,'1001','Ciudad el Doral, Mateare', 1, 1, GETDATE(), 1),
(2,1,'1002','Ciudad Sandino, Managua', 1, 1, GETDATE(), 1);

INSERT INTO [SQM_CATALOGS].[Tbl_Categories](categoryName,categoryDescription,categoryCreatorId,categoryCreationDate,categoryStatusId)
VALUES
('CALZADO', 'CALZADO EN GENERAL', 1, GETDATE(), 1),
('ROPA', 'ROPA EN GENERAL', 1, GETDATE(), 1),
('TECNOLOGIA', 'TECNOLOGIA EN GENERAL', 1, GETDATE(), 1),
('ACCESORIOS', 'ACCESORIOS EN GENERAL', 1, GETDATE(), 1);

INSERT INTO [SQM_CATALOGS].[Tbl_SubCategories](subCategoryName,subCategoryDescription,subCategoryCreatorId,subCategoryCreationDate,subCategoryStatusId)
VALUES
('MASCULINO', 'ROPA MASCULINA', 1, GETDATE(), 1),
('FEMENINO', 'ROPA FEMENINA', 1, GETDATE(), 1),
('NIÑOS', 'ROPA PARA NIÑOS', 1, GETDATE(), 1),
('NIÑAS', 'ROPA PARA NIÑAS', 1, GETDATE(), 1),
('CELULARES', 'CELULARES EN GENERAL', 1, GETDATE(), 1),
('COMPUTADORAS', 'COMPUTADORAS EN GENERAL', 1, GETDATE(), 1);

INSERT INTO [SQM_CATALOGS].[Tbl_Segments](segmentName,segmentDescription,segmentCreatorId,segmentCreationDate,segmentStatusId)
VALUES
('DEPORTIVO', 'SEGMENTO DEPORTIVO', 1, GETDATE(), 1),
('CASUAL', 'SEGMENTO CASUAL', 1, GETDATE(), 1),
('ELEGANTE', 'SEGMENTO ELEGANTE', 1, GETDATE(), 1),
('OFICINA', 'SEGMENTO OFICINA', 1, GETDATE(), 1),
('GAMING', 'SEGMENTO GAMING', 1, GETDATE(), 1),
('HOGAR', 'SEGMENTO HOGAR', 1, GETDATE(), 1),
('LAPTOS', 'SEGMENTO LAPTOS', 1, GETDATE(), 1),
('REPUESTOS', 'SEGMENTO REPUESTOS', 1, GETDATE(), 1);

INSERT INTO [SQM_CATALOGS].[Tbl_ProductIdentificators](productIdentificatorCategoryId,productIdentificatorSubCategoryId,productIdentificatorSegmentId,productIdentificatorCreatorId,productIdentificatorCreationDate,productIdentificatorStatusId)
VALUES
(1,1,1,1,GETDATE(),1),
(1,2,1,1,GETDATE(),1),
(1,3,1,1,GETDATE(),1),
(1,4,1,1,GETDATE(),1),
(2,1,1,1,GETDATE(),1),
(2,2,1,1,GETDATE(),1),
(2,3,1,1,GETDATE(),1),
(2,4,1,1,GETDATE(),1),
(3,5,4,1,GETDATE(),1),
(3,5,5,1,GETDATE(),1),
(3,6,4,1,GETDATE(),1),
(3,6,5,1,GETDATE(),1),
(3,6,7,1,GETDATE(),1);

INSERT INTO [SQM_CATALOGS].[Tbl_StockMovementTypes](stockMovementTypeName,stockMovementTypeDescription,stockMovementTypeCreatorId,
stockMovementTypeCreationDate,stockMovementTypeStatusId)
VALUES
('INGRESO DE INVENTARIO', 'INGRESO DE PRODUCTOS AL INVENTARIO', 1, GETDATE(), 1),
('EGRESO DE INVENTARIO', 'EGRESO DE PRODUCTOS DEL INVENTARIO', 1, GETDATE(), 1),
('DEVOLUCIONES DE INVENTARIO', 'DEVOLUCIONES DE PRODUCTOS AL INVENTARIO', 1, GETDATE(), 1);

INSERT INTO [SQM_SECURITY].[Tbl_Roles] (RolName,RolDescription,RolCreatorId,RolCreationDate,RolStatusId)
VALUES
('SUPER ADMINISTRADOR', 'USUARIO SUPER ADMINISTRADOR', 1, GETDATE(), 1),
('ADMINISTRADOR', 'USUARIO ADMINISTRADOR', 1, GETDATE(), 1),
('GENERAL', 'USUARIO GENERAL', 1, GETDATE(), 1);

INSERT INTO [SQM_SECURITY].[Tbl_TransactionTypes] (TransactionTypeName,TransactionTypeDescription,TransactionTypeCreatorId,
TransactionTypeCreationDate,TransactionTypeStatusId)
VALUES
('NUEVO USUARIO', 'CREAR NUEVO USUARIO', 1, GETDATE(), 1),
('ACTUALIZAR USUARIO', 'ACTUALIZAR USUARIO EXISTENTE', 1, GETDATE(), 1),
('CAMBIO CONTRASEÑA USUARIO', 'CAMBIAR CONTRASEÑA A USUARIO EXISTENTE', 1, GETDATE(), 1),
('INICIO DE SESION', 'INICIO DE SESION USUARIO EXISTENTE', 1, GETDATE(), 1);

INSERT INTO [SQM_SECURITY].[Tbl_RolByTransactionTypes] (RolByTransactionRolId,RolByTransactionTransactionTypeId,RolByTransactionTypeCreatorId,
RolByTransactionTypeCreationDate,RolByTransactionTypeStatusId)
VALUES
(1,4,1,GETDATE(),1),
(1,3,1,GETDATE(),1),
(1,2,1,GETDATE(),1),
(1,1,1,GETDATE(),1),
(2,4,1,GETDATE(),1),
(2,3,1,GETDATE(),1),
(2,2,1,GETDATE(),1),
(2,1,1,GETDATE(),1),
(3,4,1,GETDATE(),1),
(3,3,1,GETDATE(),1);

INSERT INTO [SQM_SECURITY].[Tbl_UserByRoles](UserByRolRolId,UserByRolUserId,UserByRolTypeCreatorId,
UserByRolTypeCreationDate,UserByRolTypeStatusId)
VALUES
(2,1,1,GETDATE(),1),
(3,2,1,GETDATE(),1);