#!/bin/sh

# Документация по релизам https://docs.sentry.io/workflow/releases/?platform=node
# Документация по sentry-cli https://docs.sentry.io/cli/releases/
# Названия переменных окружения используемых в sentry-cli https://docs.sentry.io/cli/configuration/#configuration-values


# Файл с фукнцами-утилитами для Sentry деплоя
source ./sentry-cli-utils.sh

# Читаем файл окружения
source ./.env

# Имя организации
export SENTRY_ORG=csssr

# Имя проекта
export SENTRY_PROJECT=sentry-sample

# propose-version возвращает хэш последнего коммита
export SENTRY_RELEASE=$(./node_modules/.bin/sentry-cli releases propose-version)

start_release

yarn build

# Выполняем загрузку source maps в бекграунде, чтобы не блокировать сборку и запуск приложения
upload_sourcemaps_and_finish_release $(pwd)/lib ./lib &

yarn start
