createCustomError = require 'custom-error-generator'

###*
 * A general {Error} type, specific for HTTP errors
 * @param  {String} message The error message
 * @param  {Object} [body] A JSON object with optional information to pass to the error
 *                         like the error response body.
###
HttpError = createCustomError 'HttpError', null, (message, body = {}) ->
  @message = message
  @body = body
  @code = body.statusCode if body.statusCode

###*
 * A general {Error} type, specific for Sphere
 * @param  {String} message The error message
 * @param  {Object} [body] A JSON object with optional information to pass to the error
 *                         like the error response body.
###
SphereError = createCustomError 'SphereError', null, (message, body = {}) ->
  @message = message
  @body = body
  @code = body.statusCode if body.statusCode

###*
 * A specific {SphereError} type for BadRequest errors
 * HTTP 400
###
BadRequest = createCustomError 'BadRequest',
  code: 400
, SphereError

###*
 * A specific {SphereError} type for NotFound errors
 * HTTP 404
###
NotFound = createCustomError 'NotFound',
  code: 404
, SphereError

###*
 * A specific {SphereError} type for ConcurrentModification errors
 * HTTP 409
###
ConcurrentModification = createCustomError 'ConcurrentModification',
  code: 409
, SphereError

###*
 * A specific {SphereError} type for InternalServerError errors
 * HTTP 500
###
InternalServerError = createCustomError 'InternalServerError',
  code: 500
, SphereError

###*
 * A specific {SphereError} type for ServiceUnavailable errors
 * HTTP 503
###
ServiceUnavailable = createCustomError 'ServiceUnavailable',
  code: 503
, SphereError

###*
 * A specific {SphereError} type for UnknownStatusCode errors
 * HTTP ???
###
UnknownStatusCode = createCustomError 'UnknownStatusCode', null, SphereError

###*
 * Expose custom Error types specific for Sphere error responses
###
module.exports =
  HttpError: HttpError
  SphereError: SphereError
  SphereHttpError:
    BadRequest: BadRequest
    NotFound: NotFound
    ConcurrentModification: ConcurrentModification
    InternalServerError: InternalServerError
    ServiceUnavailable: ServiceUnavailable
    UnknownStatusCode: UnknownStatusCode
