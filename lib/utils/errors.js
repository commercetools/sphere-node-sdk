import errorClass from 'error-class'

function defineError () {
  const [statusCode,,body] = arguments
  this.statusCode = statusCode || body.statusCode
  // For backwards compatibility
  this.code = this.statusCode
  this.body = body
}

export const HttpError = errorClass('HttpError',
  function () { defineError.call(this, null, ...arguments) })

export const BadRequest = errorClass('BadRequest',
  function () { defineError.call(this, 400, ...arguments) })

export const Unauthorized = errorClass('Unauthorized',
  function () { defineError.call(this, 401, ...arguments) })

export const NotFound = errorClass('NotFound',
  function () { defineError.call(this, 404, ...arguments) })

export const ConcurrentModification = errorClass('ConcurrentModification',
  function () { defineError.call(this, 409, ...arguments) })

export const InternalServerError = errorClass('InternalServerError',
  function () { defineError.call(this, 500, ...arguments) })

export const ServiceUnavailable = errorClass('ServiceUnavailable',
  function () { defineError.call(this, 503, ...arguments) })

// White-list native error types.
export const nativeErrors = new Set([
  Error,
  EvalError,
  ReferenceError,
  RangeError,
  SyntaxError,
  TypeError,
  URIError
])
