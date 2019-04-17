#!/bin/sh

# Документация по релизам https://docs.sentry.io/workflow/releases/?platform=node
# Документация по sentry-cli https://docs.sentry.io/cli/releases/
# Названия переменных окружения используемых в sentry-cli https://docs.sentry.io/cli/configuration/#configuration-values

# Читаем файл окружения
source ./.env

# Файл с фукнциями-утилитами для Sentry деплоя
source ./sentry-cli-utils.sh

start_release

yarn build

# Выполняем загрузку source maps в бекграунде, чтобы не блокировать сборку и запуск приложения
upload_sourcemaps_and_finish_release $(pwd)/lib ./lib &

yarn start
