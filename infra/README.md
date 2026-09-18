# infra

Локальное окружение и деплой.

- `docker-compose.yml` — Postgres+PostGIS, Redis, MinIO. Поднимается `pnpm infra:up`.
  Бакет `onwave-media` создаётся автоматически контейнером `minio-init`.
  Консоль MinIO: http://localhost:9001 (onwave / onwave123).
- Dev-стенд (ONW-14) переезжает сюда же: конфиг платформы деплоя и переменные окружения.
