# Python API - Foro 3

Entrega del backend WebSocket para busqueda, carrito, pagos e historial.

## Preparacion

1. Ejecuta los scripts de `SQL` siguiendo `SQL/README.md`.
2. Abre PowerShell en `python_api`.
3. Instala las dependencias e inicia FastAPI:

```powershell
python -m pip install -r requirements.txt
python -m uvicorn main:app
```

No necesitas crear un archivo `.env` ni definir `SQL_SERVER`: la API usa
`.\SQLEXPRESS` de forma predeterminada. Solo si tu instancia tiene otro nombre,
define temporalmente la variable antes de iniciar:

```powershell
$env:SQL_SERVER = ".\OTRA_INSTANCIA"
```

Servicios locales:

- API: `http://localhost:8000`
- Swagger: `http://localhost:8000/docs`
- WebSocket: `ws://localhost:8000/ws/chat`

Los casos completos de autenticacion, carrito y pago estan en `python_api/CASOS_DE_USO_Y_VALIDACION.md`.
