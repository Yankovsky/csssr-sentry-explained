#!/bin/sh

# Читаем файл окружения
. ./.env

# Имя организации
export SENTRY_ORG=csssr

# Документация по релизам https://docs.sentry.io/workflow/releases/?platform=node
# Документация по sentry-cli https://docs.sentry.io/cli/releases/
# Названия переменных окружения используемых в sentry-cli https://docs.sentry.io/cli/configuration/#configuration-values

# Имя организации
export SENTRY_ORG=csssr

# propose-version возвращает хэш последнего коммита
export SENTRY_RELEASE=$(./node_modules/.bin/sentry-cli releases propose-version)

# Выполняем загрузку sourcemaps асинхронно, потому что сейчас они загружаются последовательно и очень медленно.
# Не блокируем сборку отправкой sourcemaps
# https://github.com/getsentry/sentry-cli/issues/405
upload_sourcemaps() {
	# Для этой команды требуется, чтобы project был указан через переменную окружения
	# https://github.com/getsentry/sentry-cli/issues/451
	SENTRY_PROJECT=sentry-sample ./node_modules/.bin/sentry-cli releases files $SENTRY_RELEASE upload-sourcemaps --url-prefix $(pwd)/lib --rewrite ./lib

	# Завершаем создание релиза
	yarn sentry-cli releases finalize $SENTRY_RELEASE

	# Создаём новый Deploy в Sentry
	yarn sentry-cli releases deploys $SENTRY_RELEASE new -e $NODE_ENV
}

# Создаём новый релиз
yarn sentry-cli releases new --project sentry-sample $SENTRY_RELEASE

# Прикрепляем коммиты к новому релизу
yarn sentry-cli releases set-commits --auto $SENTRY_RELEASE

yarn build

# Выполняем загрузку
upload_sourcemaps &

yarn start
