# Telegram Bot API 10.4 → Docker Hub

Это неофициальная Docker-упаковка официальных исходников tdlib/telegram-bot-api.
Сборка выполняется на GitHub Actions, Docker Hub хранит готовый образ.
Текущий workflow собирает только linux/amd64 (x86_64), не ARM64.

1. Создайте в Docker Hub публичный репозиторий `telegram-bot-api`.
2. Создайте Docker Hub Personal Access Token с правами Read & Write.
3. Создайте GitHub-репозиторий с основной веткой `main`.
4. В Settings → Secrets and variables → Actions → New repository secret добавьте:
   - `DOCKERHUB_USERNAME`: ваш логин Docker Hub, строчными буквами.
   - `DOCKERHUB_TOKEN`: созданный токен.
5. Добавьте в GitHub файлы Dockerfile, .dockerignore и .github/workflows/dockerhub.yml,
   сохранив имена и вложенность. Не загружайте ZIP вместо файлов.
6. В Actions откройте Publish Telegram Bot API → Run workflow → main → Run workflow.
7. После успешной сборки доступны теги ВАШ_ЛОГИН/telegram-bot-api:10.4 и :latest.

Проверка на сервере:

```sh
docker pull ВАШ_ЛОГИН/telegram-bot-api:10.4
docker run --rm ВАШ_ЛОГИН/telegram-bot-api:10.4 --version
```

Ожидается `Bot API 10.4`. TELEGRAM_API_ID и TELEGRAM_API_HASH для сборки и проверки
версии не нужны; задавайте их только при запуске сервера.

Для Dokploy замените Compose в прежнем сервисе содержимым compose.dokploy.yml,
вписав свой логин вместо YOUR_DOCKERHUB_USERNAME. Существующие переменные окружения
и volume сохраняются в рамках того же Compose-проекта. Блок build больше не нужен.
После Deploy проверьте `docker exec telegram-bot-api telegram-bot-api --version`
и `docker logs --tail 50 telegram-bot-api`.

Коммит исходников закреплён в SOURCE_REF в Dockerfile. При обновлении версии изменяйте
его, ожидаемую версию в RUN-проверке, теги workflow и тег в Compose согласованно.
Перезапуск workflow с тем же коммитом не загружает новую версию Telegram автоматически.

Файлы подготовлены по официальным инструкциям; реальная Docker-сборка и публикация
в этом чате не выполнялись.
