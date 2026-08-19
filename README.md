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

Construir y ejecutar el backend:

```bash
docker build -t trivy-project-backend:local .
docker run --rm -p 8000:8000 trivy-project-backend:local
```

SQLite se guarda en el archivo `tasks.db`. Al ejecutar el contenedor, ese
archivo vive dentro del contenedor y se pierde al eliminarlo, salvo que se
monte un volumen.

El frontend se construye por separado:

```bash
docker build -t trivy-project-frontend:local front
```

## CI y Trivy

El workflow de `.github/workflows/ci.yml` se ejecuta en cada push a `master` y
en cada pull request. Hace estas comprobaciones:

1. Instala las dependencias bloqueadas con `uv`.
2. Ejecuta los tests.
3. Ejecuta SAST con Semgrep sobre el código Python.
4. Levanta la API y ejecuta un DAST pasivo con OWASP ZAP Baseline.
5. Construye y escanea las imágenes separadas de backend y frontend.
6. Publica ambas imágenes en GHCR cuando el push llega a `master`.

El job falla si Trivy encuentra vulnerabilidades `HIGH` o `CRITICAL` que estén
solucionadas en la base de datos de vulnerabilidades. ZAP está configurado
inicialmente con `fail_action: false` para poder observar sus hallazgos sin
bloquear todavía el pipeline; después puedes endurecer esa política.

## Kubernetes local y Argo CD

El backend y el frontend tienen charts independientes:

```text
helm/backend
helm/frontend
```

`helmfile.yaml` los instala como dos releases coordinadas:

```bash
helmfile sync
```

La release `todo-frontend` depende de `todo-backend`. El frontend usa Nginx
como proxy y reenvía `/api/*` al Service interno del backend.

Argo CD usa dos Applications, porque no interpreta Helmfile directamente:

```text
argocd/backend-application.yaml
argocd/frontend-application.yaml
```

Para aplicarlas en kind:

```bash
kubectl --context kind-desktop apply -f argocd/backend-application.yaml
kubectl --context kind-desktop apply -f argocd/frontend-application.yaml
```

Argo CD sincronizará ambos charts desde GitHub y creará el namespace `todo`.
Las imágenes se descargan desde:

```text
ghcr.io/jualvarez9/trivy-project-backend:latest
ghcr.io/jualvarez9/trivy-project-frontend:latest
```

Para comprobar el despliegue:

```bash
kubectl --context kind-desktop get applications -n argocd
kubectl --context kind-desktop get pods -n todo
```
