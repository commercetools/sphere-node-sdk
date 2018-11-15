debug = require('debug')('sphere-connect:rest')
_ = require 'underscore'
_.mixin require('underscore-mixins')
request = require 'request'
OAuth2 = require './oauth2'

# Public: Define an HTTP client to connect to the SPHERE.IO API.
#
# Examples
#
#   rest = new Rest
#     config:
#       client_id: "CLIENT_ID_HERE"
#       client_secret: "CLIENT_SECRET_HERE"
#       project_key: "PROJECT_KEY_HERE"
#     host: 'api.sphere.io' # optional
#     protocol: 'https' # optional
#     access_token: '' # optional (if not provided it will automatically retrieve an `access_token`)
#     timeout: 20000 # optional
#     rejectUnauthorized: true # optional
#     oauth_host: 'auth.sphere.io' # optional (used when retrieving the `access_token` internally)
#     oauth_protocol: 'https' # optional (used when retrieving the `access_token` internally)
#     user_agent: 'sphere-node-connect' # optional
class Rest

  # Public: Initialize the HTTP client
  #
  # options - An {Object} to configure the service
  #   :config - {Object} It contains the credentials `project_key`, `client_id`, `client_secret`
  #   :host - {String} The host (default `api.sphere.io`)
  #   :protocol - {String} The protocol (default `https`)
  #   :user_agent - {String} The request `User-Agent` (default `sphere-node-connect`)
  #   :timeout - {Number} The request timeout (default `20000`)
  #   :rejectUnauthorized - {Boolean} Whether to reject clients with invalid certificates or not (default `true`)
  #   :access_token - {String} A valid `access_token` (if not present it will be retrieved)
  #
  # Throws an {Error} if credentials are missing
  constructor: (opts = {}) ->
    config = opts.config
    throw new Error('Missing credentials') unless config
    throw new Error('Missing \'client_id\'') unless config.client_id or opts.access_token
    throw new Error('Missing \'client_secret\'') unless config.client_secret or opts.access_token
    throw new Error('Missing \'project_key\'') unless config.project_key

    host = opts.host or 'api.sphere.io'
    protocol = opts.protocol or 'https'

    rejectUnauthorized = if _.isUndefined(opts.rejectUnauthorized) then true else opts.rejectUnauthorized
    userAgent = if _.isUndefined(opts.user_agent) then 'sphere-node-connect' else opts.user_agent
    @_options =
      config: config
      host: host
      protocol: protocol
      access_token: opts.access_token or undefined
      timeout: opts.timeout or 20000
      rejectUnauthorized: rejectUnauthorized
      headers:
        'User-Agent': userAgent
    @_options.uri = "#{@_options.protocol}://#{@_options.host}/#{@_options.config.project_key}"

    oauth_options = _.deepClone(opts)
    _.extend oauth_options,
      host: opts.oauth_host,
      protocol: opts.oauth_protocol
    @_oauth = new OAuth2 oauth_options

    if @_options.access_token
      @_options.headers['Authorization'] = "Bearer #{@_options.access_token}"

    @_options.gzipEnable = if !_.isUndefined(opts.gzipEnable) then opts.gzipEnable else true

    debug 'rest options: %j', @_options
    return

  # Public: Send a `HTTP GET` request to an API endpoint
  #
  # resource - {String} The API resource endpoint, with query string parameters.
  # callback - {Function} A function fulfilled with `error, response, body` arguments.
  GET: (resource, callback) ->
    params =
      method: 'GET'
      resource: resource
    debug 'GET request params: %j', _.extend {}, params,
      project: @_options.config.project_key
    @_preRequest(params, callback)

  # Public: Send a `HTTP POST` request to an API endpoint
  #
  # resource - {String} The API resource endpoint, with query string parameters.
  # payload - {Object} A JSON object used as `body` payload
  # callback - {Function} A function fulfilled with `error, response, body` arguments.
  POST: (resource, payload, callback) ->
    params =
      method: 'POST'
      resource: resource
      body: payload
    debug 'POST request params: %j', _.extend {}, params,
      project: @_options.config.project_key
    @_preRequest(params, callback)

  # Public: Send a `HTTP DELETE` request to an API endpoint
  #
  # resource - {String} The API resource endpoint, with query string parameters.
  # callback - {Function} A function fulfilled with `error, response, body` arguments.
  DELETE: (resource, callback) ->
    params =
      method: 'DELETE'
      resource: resource
    debug 'DELETE request params: %j', _.extend {}, params,
      project: @_options.config.project_key
    @_preRequest(params, callback)

  # Private: Not implemented
  PUT: -> throw new Error 'Not implemented yet'

  # Private: Prepare the request to be sent by automatically retrieving an `access_token`
  #
  # params - {Object} A JSON object containing all required parameters for the request
  # callback - {Function} A function fulfilled with `error, response, body` arguments.
  #
  # Throws an {Error} if `access_token` could not be retrieved
  _preRequest: (params, callback) ->
    _req = (retry) =>
      isTokenExpired = false
      if @_expirationTime
        isTokenExpired = Date.now() > @_expirationTime

      if not @_options.access_token or (@_options.access_token and isTokenExpired)

        @_oauth.getAccessToken (error, response, body) =>
          if error
            if retry is 10
              return callback(error, response, body)
            else
              debug "Failed to retrieve access_token (error: %j), retrying...#{retry + 1}", error
              return _req(retry + 1)
          if response.statusCode isnt 200
            # try again to get an access token
            if retry is 10
              callback(error, response, body)
            else
              debug "Failed to retrieve access_token (statusCode: #{response.statusCode}), retrying...#{retry + 1}"
              _req(retry + 1)
          else
            # save expiration date for token renewal
            @_expirationTime = Date.now() + (body.expires_in * 1000) -
              # Add a gap of 2 hours before expiration time.
              (2 * 60 * 60 * 1000)
            access_token = body.access_token
            @_options.access_token = access_token
            @_options.headers['Authorization'] = "Bearer #{@_options.access_token}"
            debug 'new access_token received: %s', access_token
            # call itself again (this time with the access_token)
            _req(0)
      else
        request_options =
          uri: "#{@_options.uri}#{params.resource}"
          json: true
          gzip: @_options.gzipEnable
          method: params.method
          host: @_options.host
          headers: @_options.headers
          timeout: @_options.timeout
          rejectUnauthorized: @_options.rejectUnauthorized

        if params.body
          request_options.body = params.body

        debug 'rest request options: %j', request_options
        @_doRequest(request_options, callback)

    _req(0)

  # Private: Execute the request using the underling `request` module
  #
  # See {https://github.com/mikeal/request}
  _doRequest: (options, callback) ->
    request options, (e, r, b) ->
      debug('error on request: %j', e) if e
      callback(e, r, b)

  # Public: Fetch all results of a Sphere resource query endpoint in batches of pages using a recursive function.
  #
  #
  # resource - {String} The API resource endpoint, with query string parameters.
  # resolve - {Function} A function fulfilled with `error, response, body` arguments. Body is an {Object} of `PagedQueryResponse`.
  # notify - {Function} A function fulfilled with `percentage, value` arguments. Value is an {Object} of the current body results.
  #                     This function is called for each batch iteration, allowing you to track the progress.
  #
  # Throws an {Error} if `limit` param is not `0`
  PAGED: (resource, resolve) ->
    splitted = resource.split('?')
    endpoint = splitted[0]
    query = _.parseQuery splitted[1], false

    defaultLimit = 50
    params = _.extend { limit: defaultLimit }, # limit used for batches
      query

    if parseInt(params.limit, 10) is 0
      params.limit = defaultLimit

    limit = params.limit
    debug 'PAGED request params: %j', params

    _page = (lastId, accumulator = []) =>
      debug 'PAGED iteration (lastId: %s)', lastId

      wherePredicate = if params.where then {where: params.where} else {}
      if lastId
        lastIdPredicate = encodeURIComponent("id > \"#{lastId}\"")
        wherePredicate = {where: if params.where then "#{params.where}%20and%20#{lastIdPredicate}" else lastIdPredicate}
      debug 'PAGED where predicate: %j', wherePredicate

      queryParams = _.stringifyQuery(_.extend({}, params,
        withTotal: false
      , wherePredicate))

      @GET "#{endpoint}?#{queryParams}", (error, response, body) ->
        if error
          resolve error, response, body
        else
          if response.statusCode is 200
            debug 'PAGED response: offset %s, count %s', body.offset, body.count

            acc = accumulator.concat(body.results)
            if _.size(body.results) <= limit
              resolve null, response,
                count: body.total
                offset: body.offset
                total: _.size(acc)
                results: acc
            else
              last = _.last(body.results)
              newLastId = last && last.id
              _page(newLastId, acc)
          else
            resolve(error, response, body)

    _page()
    return

module.exports = Rest
