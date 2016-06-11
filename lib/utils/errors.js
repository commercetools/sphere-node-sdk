function defineError (statusCode, message, body) {
  this.message = message
  this.body = body
  this.statusCode = statusCode || body.statusCode
  // For backwards compatibility
  this.code = this.statusCode

  this.name = this.constructor.name
  this.constructor.prototype.__proto__ = Error.prototype // eslint-disable-line no-proto,max-len

  if (Error.captureStackTrace)
    Error.captureStackTrace(this, this.constructor)
}

/* eslint-disable max-len */
export function HttpError (...args) { defineError.call(this, null, ...args) }
export function BadRequest (...args) { defineError.call(this, 400, ...args) }
export function Unauthorized (...args) { defineError.call(this, 401, ...args) }
export function Forbidden (...args) { defineError.call(this, 403, ...args) }
export function NotFound (...args) { defineError.call(this, 404, ...args) }
export function ConcurrentModification (...args) { defineError.call(this, 409, ...args) }
export function InternalServerError (...args) { defineError.call(this, 500, ...args) }
export function ServiceUnavailable (...args) { defineError.call(this, 503, ...args) }
export function GraphQLError (...args) { defineError.call(this, 400, ...args) }
/* eslint-enable max-len */

// White-list native error types.
export const nativeErrors = new Set([
  Error,
  EvalError,
  ReferenceError,
  RangeError,
  SyntaxError,
  TypeError,
  URIError,
])
