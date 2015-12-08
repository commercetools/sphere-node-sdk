# Public: A general {Error} type, specific for HTTP errors
class HttpError extends Error

  # Public: Create a new `HttpError`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "HttpError"
    @statusCode = @body.statusCode if @body.statusCode
    @code = @statusCode
    Error.captureStackTrace(@, HttpError)

# Public: A general {Error} type, specific for Sphere
class SphereError extends Error

  # Public: Create a new `SphereError`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "SphereError"
    @statusCode = @body.statusCode if @body.statusCode
    @code = @statusCode
    Error.captureStackTrace(@, SphereError)

# Public: A general GraphQL {Error} type
class GraphQLError extends Error

  # Public: Create a new `GraphQLError`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "GraphQLError"
    @statusCode = @body.statusCode if @body.statusCode
    @code = @statusCode
    Error.captureStackTrace(@, GraphQLError)

# Public: A specific {SphereError} type for `BadRequest` errors (HTTP 400)
class BadRequest extends SphereError

  # Public: Create a new `BadRequest`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "BadRequest"
    @statusCode = 400
    @code = @statusCode
    Error.captureStackTrace(@, BadRequest)

# Public: A specific {SphereError} type for `Unauthorized` errors (HTTP 401)
class Unauthorized extends SphereError

  # Public: Create a new `Unauthorized`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "Unauthorized"
    @statusCode = 401
    @code = @statusCode
    Error.captureStackTrace(@, SphereError)

# Public: A specific {SphereError} type for `NotFound` errors (HTTP 404)
class NotFound extends SphereError

  # Public: Create a new `NotFound`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "NotFound"
    @statusCode = 404
    @code = @statusCode
    Error.captureStackTrace(@, NotFound)

# Public: A specific {SphereError} type for `ConcurrentModification` errors (HTTP 409)
class ConcurrentModification extends SphereError

  # Public: Create a new `ConcurrentModification`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "ConcurrentModification"
    @statusCode = 409
    @code = @statusCode
    Error.captureStackTrace(@, ConcurrentModification)

# Public: A specific {SphereError} type for `InternalServerError` errors (HTTP 500)
class InternalServerError extends SphereError

  # Public: Create a new `InternalServerError`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "InternalServerError"
    @statusCode = 500
    @code = @statusCode
    Error.captureStackTrace(@, InternalServerError)

# Public: A specific {SphereError} type for `ServiceUnavailable` errors (HTTP 503)
class ServiceUnavailable extends SphereError

  # Public: Create a new `ServiceUnavailable`
  #
  # message - {String} The error message
  # body - {Object} A JSON object with optional information to pass to the error, like the error response body
  constructor: (@message, @body = {}) ->
    @name = "ServiceUnavailable"
    @statusCode = 503
    @code = @statusCode
    Error.captureStackTrace(@, ServiceUnavailable)

module.exports =
  HttpError: HttpError
  SphereError: SphereError
  GraphQLError: GraphQLError
  SphereHttpError:
    BadRequest: BadRequest
    Unauthorized: Unauthorized
    NotFound: NotFound
    ConcurrentModification: ConcurrentModification
    InternalServerError: InternalServerError
    ServiceUnavailable: ServiceUnavailable
