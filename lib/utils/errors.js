function defineError (ctx, type, statusCode, message, body) {
  ctx.message = message
  ctx.name = type
  ctx.body = body
  ctx.statusCode = statusCode || body.statusCode
  // For backwards compatibility
  ctx.code = ctx.statusCode
}

export class HttpError extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'HttpError', null, message, body)
    Error.captureStackTrace(this, HttpError)
  }
}

export class BadRequest extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'BadRequest', 400, message, body)
    Error.captureStackTrace(this, BadRequest)
  }
}

export class Unauthorized extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'Unauthorized', 401, message, body)
    Error.captureStackTrace(this, Unauthorized)
  }
}

export class NotFound extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'NotFound', 404, message, body)
    Error.captureStackTrace(this, NotFound)
  }
}

export class ConcurrentModification extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'ConcurrentModification', 409, message, body)
    Error.captureStackTrace(this, ConcurrentModification)
  }
}

export class InternalServerError extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'InternalServerError', 500, message, body)
    Error.captureStackTrace(this, InternalServerError)
  }
}

export class ServiceUnavailable extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'ServiceUnavailable', 503, message, body)
    Error.captureStackTrace(this, ServiceUnavailable)
  }
}
