console.log(process.env.NODE_ENV, process.env.SENTRY_RELEASE)

const Sentry = require('@sentry/node')
Sentry.init({
  dsn: 'https://6e5d25b08f5c4d01a3d24b69ade9dbf1@sentry.io/1438725',
  // Приложение должно быть запущено с правильной версией релиза, чтобы ошибки попадали именно в этот релиз
  release: process.env.SENTRY_RELEASE,
  // Позволяет обработать сообщения/ошибки перед отправкой
  beforeSend(event, hint) {
    // console.log('EVENT', event)
    // console.log('HINT', event)
    return event
  },
  environment: process.env.NODE_ENV,
  // Добавляет стектрейс при отправке сообщений в Sentry
  // При ошибках стектрейс всегда отправляется вне зависимости от этого флага
  attachStacktrace: true,
})

class SentryExtendedError extends Error {
  constructor(extraData, ...params) {
    super(...params)

    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, SentryExtendedError)
    }

    this.name = new.target.prototype.constructor.name
    this.extraData = extraData
  }
}

const a = () => {
  setTimeout(() => {
    try {
      throw new SentryExtendedError({ baz: 'baz', bar: 'bar' }, 'My Custom Error')
    } catch (e) {
      Sentry.withScope(scope => {
        if (e instanceof SentryExtendedError) {
          Object.entries(e.extraData).forEach(([k, v]) => {
            scope.setExtra(k, JSON.stringify(v))
          })
        }
        Sentry.captureException(e)
      })
    }

    Sentry.withScope(scope => {
      Object.entries({ foo: 'foo' }).forEach(([k, v]) => {
        scope.setExtra(k, JSON.stringify(v))
      })
      Sentry.captureMessage('My Custom Message')
    })
  }, 10000)
}

const b = () => {
  a()
}

const c = function () {
  b()
}

c()
