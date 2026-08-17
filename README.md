# FastAPI Todo Lab

Proyecto de aprendizaje para conectar un frontend sencillo con una API FastAPI,
Pydantic, SQLAlchemy, SQLite, Docker y GitHub Actions.

## Ejecutar en local

Instalar dependencias:

```bash
uv sync
```

Arrancar la API:

```bash
uv run uvicorn app.main:app --reload
```

La API queda disponible en `http://127.0.0.1:8000`. La documentación Swagger
está en `http://127.0.0.1:8000/docs`.

Para servir el frontend, en otra terminal:

```bash
python3 -m http.server 5500 --directory front
```

## Tests

```bash
uv run pytest
```

## Docker

Construir y ejecutar la imagen:

```bash
docker build -t trivy-project:local .
docker run --rm -p 8000:8000 trivy-project:local
```

SQLite se guarda en el archivo `tasks.db`. Al ejecutar el contenedor, ese
archivo vive dentro del contenedor y se pierde al eliminarlo, salvo que se
monte un volumen.

## CI y Trivy

El workflow de `.github/workflows/ci.yml` se ejecuta en cada push a `master` y
en cada pull request. Hace tres cosas:

1. Instala las dependencias bloqueadas con `uv`.
2. Ejecuta los tests.
3. Construye la imagen y la escanea con Trivy.

El job falla si Trivy encuentra vulnerabilidades `HIGH` o `CRITICAL` que estén
solucionadas en la base de datos de vulnerabilidades.
