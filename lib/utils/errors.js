function defineError (ctx, type, statusCode, message, body) {
  ctx.message = message
  ctx.name = type
  ctx.body = body
  ctx.statusCode = statusCode || body.statusCode
  // For backwards compatibility
  ctx.code = ctx.statusCode
}

const hasCaptureStackTrace = Error.captureStackTrace

export class HttpError extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'HttpError', null, message, body)
    hasCaptureStackTrace ?
      Error.captureStackTrace(this, HttpError) : Error().stack
  }
}

export class BadRequest extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'BadRequest', 400, message, body)
    hasCaptureStackTrace ?
      Error.captureStackTrace(this, BadRequest) : Error().stack
  }
}

export class Unauthorized extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'Unauthorized', 401, message, body)
    hasCaptureStackTrace ?
      Error.captureStackTrace(this, Unauthorized) : Error().stack
  }
}

export class NotFound extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'NotFound', 404, message, body)
    hasCaptureStackTrace ?
      Error.captureStackTrace(this, NotFound) : Error().stack
  }
}

export class ConcurrentModification extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'ConcurrentModification', 409, message, body)
    hasCaptureStackTrace ?
      Error.captureStackTrace(this, ConcurrentModification) : Error().stack
  }
}

export class InternalServerError extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'InternalServerError', 500, message, body)
    hasCaptureStackTrace ?
      Error.captureStackTrace(this, InternalServerError) : Error().stack
  }
}

export class ServiceUnavailable extends Error {
  constructor (message, body = {}) {
    super(message)

    defineError(this, 'ServiceUnavailable', 503, message, body)
    hasCaptureStackTrace ?
      Error.captureStackTrace(this, ServiceUnavailable) : Error().stack
  }
}
