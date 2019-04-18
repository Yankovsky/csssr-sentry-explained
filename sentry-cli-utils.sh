#!/bin/sh

SENTRY_CLI=$(yarn bin sentry-cli)

# Если SENTRY_ENV ещё не определена, то используем значение NODE_ENV
export SENTRY_ENV=${SENTRY_ENV:-$NODE_ENV}

start_release() {
	# Если SENTRY_RELEASE ещё не определена, то используем propose-version,
	# который возвращает хэш последнего коммита
	export SENTRY_RELEASE=${SENTRY_RELEASE:-$($SENTRY_CLI releases propose-version)}

	# Создаём новый релиз
	$SENTRY_CLI releases new $SENTRY_RELEASE

	# Прикрепляем коммиты к новому релизу
	$SENTRY_CLI releases set-commits --auto $SENTRY_RELEASE
}

# Функция принимает два параметра – url-prefix и путь до папки с собранным js и source map'ами
# Дока по url-prefix https://docs.sentry.io/cli/releases/#sentry-cli-sourcemaps
upload_sourcemaps() {
	# Для этой команды требуется, чтобы project был указан через переменную окружения
	# https://github.com/getsentry/sentry-cli/issues/451
	$SENTRY_CLI releases files $SENTRY_RELEASE upload-sourcemaps --url-prefix $1 --rewrite $2
}

finish_release() {
	# Завершаем создание релиза
	$SENTRY_CLI releases finalize $SENTRY_RELEASE

	# Создаём новый Deploy в Sentry
	$SENTRY_CLI releases deploys $SENTRY_RELEASE new -e $SENTRY_ENV
}

# Те же параметры, что и у upload_sourcemaps
# Сейчас source maps загружаются последовательно и очень медленно
# https://github.com/getsentry/sentry-cli/issues/405
# Можно эту функцию вызывать в бекграунде, пример в deploy.sh
upload_sourcemaps_and_finish_release() {
	upload_sourcemaps $1 $2

	finish_release
}
