# apps/mobile

Место для Flutter-приложения. Пока пусто — каркас поднимается в ONW-41.

```bash
flutter create --org io.onwave --project-name onwave .
```

Что настраивается сразу при создании (ONW-41):

- флейворы dev / stage / prod с разными bundle id, иконками и названиями;
- `--dart-define` для базового URL API и Sentry DSN, без правки кода;
- схемы Xcode и product flavors в Gradle.

Дальше: кодоген клиента из `packages/api-contract` (ONW-42), Riverpod + go_router
(ONW-43), дизайн-система (ONW-44), локализация arb (ONW-45).
