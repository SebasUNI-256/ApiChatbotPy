# Instalacion SQL - Foro 3

Esta carpeta contiene solamente los tres scripts necesarios para levantar las bases utilizadas por la API. Los instaladores no eliminan tablas, historial ni datos existentes y pueden volver a ejecutarse.

## Requisitos

- SQL Server con autenticacion de Windows.
- SQL Server Management Studio (SSMS).
- Permiso para crear las bases `DB_ECOMMERCE` y `DB_EcommerceAgent` cuando no existan.

## Orden de ejecucion

Abre cada archivo en SSMS, conectate a la instancia local y ejecutalos en este orden:

1. `01_DB_ECOMMERCE.sql`
2. `02_DB_EcommerceAgent.sql`
3. `03_SEED_PRUEBA.sql`

El tercer script deja impresos los IDs que se utilizan en las pruebas. Si las bases ya contenian informacion, los scripts conservan esos datos y agregan solamente lo que haga falta.

## Usuario de prueba

- Usuario: `FORO3_DEMO`
- Correo: `foro3.demo@example.com`
- Contrasena: `ClaveDemo123!`
- Tarjeta de demostracion: `4111111111111111`
- CVV de demostracion: `123`

La tarjeta es un numero reservado para pruebas. No uses datos bancarios reales.

## Configurar y ejecutar la API

Desde PowerShell, entra en la carpeta `python_api` e inicia la API:

```powershell
python -m pip install -r requirements.txt
python -m uvicorn main:app
```

No necesitas crear `.env` ni configurar `SQL_SERVER` si usas `.\SQLEXPRESS`,
porque ese es el valor predeterminado. Para una instancia diferente, define la
variable solo en la consola actual antes de iniciar:

```powershell
$env:SQL_SERVER = ".\OTRA_INSTANCIA"
```

La API queda en `http://localhost:8000`, la documentacion interactiva en `http://localhost:8000/docs` y el WebSocket en `ws://localhost:8000/ws/chat`.

## Comprobacion rapida

```sql
USE DB_ECOMMERCE;
GO

SELECT userId, userName, userEmail
FROM SQM_SECURITY.Tbl_Users
WHERE userName = 'FORO3_DEMO';

SELECT ProductVariableID, ProductName, ProductVariableName, StockAvailable
FROM SQM_GENERAL.VW_GENERAL_PRODUCTS
WHERE ProductName = 'TENIS DEPORTIVOS FORO 3';

USE DB_EcommerceAgent;
GO

SELECT NombreRegla, AccionPython
FROM dbo.ReglasChatbot
WHERE Activo = 1
ORDER BY ReglaID;
```

Para comprobar que la instalacion es repetible, vuelve a ejecutar los tres scripts. Debe seguir existiendo un solo usuario `FORO3_DEMO`, una sola variante `TALLA 42 NEGRO` y una sola copia de cada palabra clave y plantilla.

