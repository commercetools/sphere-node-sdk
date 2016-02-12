function defineError (statusCode, message, body) {
  this.message = message
  this.body = body
  this.statusCode = statusCode || body.statusCode
  // For backwards compatibility
  this.code = this.statusCode

  this.name = this.constructor.name
  this.constructor.prototype.__proto__ = Error.prototype
  Error.captureStackTrace(this, this.constructor)
}

/* eslint-disable max-len */
export function HttpError () { defineError.call(this, null, ...arguments) }
export function BadRequest () { defineError.call(this, 400, ...arguments) }
export function Unauthorized () { defineError.call(this, 401, ...arguments) }
export function NotFound () { defineError.call(this, 404, ...arguments) }
export function ConcurrentModification () { defineError.call(this, 409, ...arguments) }
export function InternalServerError () { defineError.call(this, 500, ...arguments) }
export function ServiceUnavailable () { defineError.call(this, 503, ...arguments) }
export function GraphQLError () { defineError.call(this, 400, ...arguments) }
/* eslint-enable max-len */

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
