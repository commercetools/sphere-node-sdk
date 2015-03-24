# Public: A general {Error} type, specific for HTTP errors
class HttpError extends Error

  # Public: Create a new `HttpError`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "HttpError"
    @code = @body.statusCode if @body.statusCode
    Error.captureStackTrace(@, HttpError)

# Public: A general {Error} type, specific for Sphere
class SphereError extends Error

  # Public: Create a new `SphereError`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "SphereError"
    @code = @body.statusCode if @body.statusCode
    Error.captureStackTrace(@, SphereError)

# Public: A specific {SphereError} type for `BadRequest` errors (HTTP 400)
class BadRequest extends SphereError

  # Public: Create a new `BadRequest`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "BadRequest"
    @code = 400
    Error.captureStackTrace(@, BadRequest)

# Public: A specific {SphereError} type for `NotFound` errors (HTTP 404)
class NotFound extends SphereError

  # Public: Create a new `NotFound`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "NotFound"
    @code = 404
    Error.captureStackTrace(@, NotFound)

# Public: A specific {SphereError} type for `ConcurrentModification` errors (HTTP 409)
class ConcurrentModification extends SphereError

  # Public: Create a new `ConcurrentModification`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "ConcurrentModification"
    @code = 409
    Error.captureStackTrace(@, ConcurrentModification)

# Public: A specific {SphereError} type for `InternalServerError` errors (HTTP 500)
class InternalServerError extends SphereError

  # Public: Create a new `InternalServerError`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "InternalServerError"
    @code = 500
    Error.captureStackTrace(@, InternalServerError)

# Public: A specific {SphereError} type for `ServiceUnavailable` errors (HTTP 503)
class ServiceUnavailable extends SphereError

  # Public: Create a new `ServiceUnavailable`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "ServiceUnavailable"
    @code = 503
    Error.captureStackTrace(@, ServiceUnavailable)

module.exports =
  HttpError: HttpError
  SphereError: SphereError
  SphereHttpError:
    BadRequest: BadRequest
    NotFound: NotFound
    ConcurrentModification: ConcurrentModification
    InternalServerError: InternalServerError
    ServiceUnavailable: ServiceUnavailable
