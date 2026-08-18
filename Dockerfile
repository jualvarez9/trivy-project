FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:0.12.5 /uv /uvx /bin/

WORKDIR /app

RUN groupadd --system appgroup \
    && useradd --system --gid appgroup --home-dir /app appuser

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_SYSTEM_CERTS=true

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-dev

COPY app ./app

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

CMD ["uv", "run", "--no-dev", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]