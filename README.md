# Onwave

Афиша городских событий. iOS + Android, бэкенд на NestJS.

Задачи и вехи — в Linear, проект **Фаза 0 — Фундамент** (команда ONW).

## Структура

```
apps/api                 NestJS API
apps/mobile              Flutter-приложение (пусто, поднимается в ONW-41)
packages/api-contract    OpenAPI — источник правды для бэка и мобилки
infra                    docker-compose, деплой
docs                     скоуп, доменная модель, чеклист App Store
```

## Быстрый старт

Нужны Node 20+, pnpm 9, Docker.

```bash
pnpm install
cp .env.example .env
pnpm infra:up                 # Postgres+PostGIS, Redis, MinIO
pnpm --filter @onwave/api prisma:migrate
pnpm db:seed
pnpm api:dev
```

- API: http://localhost:3000
- Swagger: http://localhost:3000/docs (вне dev закрыт basic-auth)
- Health: http://localhost:3000/health, http://localhost:3000/health/ready
- Консоль MinIO: http://localhost:9001 (onwave / onwave123)

## Команды

| Команда | Что делает |
| --- | --- |
| `pnpm api:dev` | API в watch-режиме |
| `pnpm api:test` / `pnpm api:e2e` | Unit- и e2e-тесты |
| `pnpm db:migrate` / `pnpm db:seed` | Миграции и сид |
| `pnpm contract:lint` | Валидация OpenAPI-схемы |
| `pnpm lint` / `pnpm format` | ESLint и Prettier |
| `pnpm infra:up` / `pnpm infra:down` | Локальные сервисы |

## Договорённости

- **OpenAPI — источник правды.** Изменения API начинаются в `packages/api-contract`,
  дальше расходятся в бэкенд и в сгенерированный Dart-клиент. Руками модели не пишем.
- **Один формат ошибки** на всё API: `{code, message, details, requestId}`.
  Мобилка ветвит логику по `code`, а не по тексту сообщения.
- **Время в UTC**, таймзона хранится у города и площадки. «Сегодня» считается по
  времени города, а не телефона.
- **Пагинация курсорная, не offset.** Лента постоянно меняется, offset даёт дубли и пропуски.
- **Конфиг валидируется на старте** — приложение падает сразу, а не в рантайме через неделю.
