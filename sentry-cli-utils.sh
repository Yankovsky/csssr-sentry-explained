#!/bin/sh

start_release() {
	# Создаём новый релиз
	yarn sentry-cli releases new $SENTRY_RELEASE

	# Прикрепляем коммиты к новому релизу
	yarn sentry-cli releases set-commits --auto $SENTRY_RELEASE
}

# Сейчас source maps загружаются последовательно и очень медленно
# https://github.com/getsentry/sentry-cli/issues/405
# Можно эту функцию вызывать в бекграунде, пример в deploy.sh
upload_sourcemaps_and_finish_release() {
	# Для этой команды требуется, чтобы project был указан через переменную окружения
	# https://github.com/getsentry/sentry-cli/issues/451
	yarn sentry-cli releases files $SENTRY_RELEASE upload-sourcemaps --url-prefix $1 --rewrite $2

	# Завершаем создание релиза
	yarn sentry-cli releases finalize $SENTRY_RELEASE

	# Создаём новый Deploy в Sentry
	yarn sentry-cli releases deploys $SENTRY_RELEASE new -e $NODE_ENV
}
