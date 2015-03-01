debug = require('debug')('sphere-connect:rest')
_ = require 'underscore'
_.mixin require('underscore-mixins')
request = require 'request'
OAuth2 = require './oauth2'

###*
 * Creates a new Rest instance, used to connect to https://api.sphere.io
 * @class Rest
###
class Rest

  ###*
   * Initialize the class
   * @constructor
   * @param {Object} [opts] A JSON object containg configuration options
   * @throws {Error} if credentials are missing
  ###
  constructor: (opts = {}) ->
    config = opts.config
    throw new Error('Missing credentials') unless config
    throw new Error('Missing \'client_id\'') unless config.client_id
    throw new Error('Missing \'client_secret\'') unless config.client_secret
    throw new Error('Missing \'project_key\'') unless config.project_key

    rejectUnauthorized = if _.isUndefined(opts.rejectUnauthorized) then true else opts.rejectUnauthorized
    userAgent = if _.isUndefined(opts.user_agent) then 'sphere-node-connect' else opts.user_agent
    @_options =
      config: config
      host: opts.host or 'api.sphere.io'
      access_token: opts.access_token or undefined
      timeout: opts.timeout or 20000
      rejectUnauthorized: rejectUnauthorized
      headers:
        'User-Agent': userAgent
    @_options.uri = "https://#{@_options.host}/#{@_options.config.project_key}"

    oauth_options = _.deepClone(opts)
    _.extend oauth_options,
      host: opts.oauth_host
    @_oauth = new OAuth2 oauth_options

    if @_options.access_token
      @_options.headers['Authorization'] = "Bearer #{@_options.access_token}"

    debug 'rest options: %j', @_options
    return

  ###*
   * Send a HTTP GET request to an API endpoint
   * @param {String} resource The API resource endpoint, with query string parameters.
   * @param {Function} callback A function fulfilled with `error, response, body` arguments.
  ###
  GET: (resource, callback) ->
    params =
      method: 'GET'
      resource: resource
    debug 'GET request params: %j', _.extend {}, params,
      project: @_options.config.project_key
    @_preRequest(params, callback)

  ###*
   * Send a HTTP POST request to an API endpoint
   * @param {String} resource The API resource endpoint, with query string parameters.
   * @param {Object} payload A JSON object used as `body` payload
   * @param {Function} callback A function fulfilled with `error, response, body` arguments.
  ###
  POST: (resource, payload, callback) ->
    params =
      method: 'POST'
      resource: resource
      body: payload
    debug 'POST request params: %j', _.extend {}, params,
      project: @_options.config.project_key
    @_preRequest(params, callback)

  ###*
   * Send a HTTP DELETE request to an API endpoint
   * @param {String} resource The API resource endpoint, with query string parameters.
   * @param {Function} callback A function fulfilled with `error, response, body` arguments.
  ###
  DELETE: (resource, callback) ->
    params =
      method: 'DELETE'
      resource: resource
    debug 'DELETE request params: %j', _.extend {}, params,
      project: @_options.config.project_key
    @_preRequest(params, callback)

  ###*
   * @throws {Error} as there is currently no implementation
  ###
  PUT: -> throw new Error 'Not implemented yet'

  ###*
   * Prepare the request to be sent by automatically retrieving an `access_token`
   * @param {Object} params A JSON object containing all required parameters for the request
   * @param {Function} callback A function fulfilled with `error, response, body` arguments.
   * @throws {Error} if `access_token` could not be retrieved
  ###
  _preRequest: (params, callback) ->
    _req = (retry) =>
      unless @_options.access_token
        @_oauth.getAccessToken (error, response, body) =>
          if error
            if retry is 10
              throw new Error 'Error on retrieving access_token after 10 attempts.\n' +
                "Error: #{error}\n"
            else
              debug "Failed to retrieve access_token (error: %j), retrying...#{retry + 1}", error
              return _req(retry + 1)
          if response.statusCode isnt 200
            # try again to get an access token
            if retry is 10
              throw new Error 'Could not retrieve access_token after 10 attempts.\n' +
                "Status code: #{response.statusCode}\n" +
                "Body: #{JSON.stringify(body)}\n"
            else
              debug "Failed to retrieve access_token (statusCode: #{response.statusCode}), retrying...#{retry + 1}"
              _req(retry + 1)
          else
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

  ###*
   * Execute the request using the underling `request` module
   * @link https://github.com/mikeal/request
   * @param {Object} options A JSON object containing all required options for the request
   * @param {Function} callback A function fulfilled with `error, response, body` arguments.
  ###
  _doRequest: (options, callback) ->
    request options, (e, r, b) ->
      debug('error on request: %j', e) if e
      callback(e, r, b)

  ###*
   * Fetch all results of a Sphere resource query endpoint in batches of pages using a recursive function.
   * Supports subscription of progress notifications.
   * @param {String} resource The resource endpoint to be queried, with query string parameters.
   * @param {Function} resolve A function fulfilled with `error, response, body` arguments. Body is an {Object} of {PagedQueryResponse}
   * @param {Function} [notify] A function fulfilled with `percentage, value` arguments. Value is an {Object} of the current body results.
   *                            This function is called for each batch iteration, allowing you to track the progress.
   * @throws {Error} if `limit` param is not 0
  ###
  PAGED: (resource, resolve, notify) ->
    splitted = resource.split('?')
    endpoint = splitted[0]
    query = _.parseQuery splitted[1]

    throw new Error 'Query limit doesn\'t seem to be 0. This function queries all results, are you sure you want to use this?' if query.limit and query.limit isnt '0'

    params = _.extend {}, query,
      limit: 50 # limit used for batches
      offset: 0
    limit = params.limit
    debug 'PAGED request params: %j', params

    _buildPagedQueryResponse = (results) ->
      tot = _.size(results)

      offset: params.offset
      count: tot
      total: tot
      results: results

    tmpResponse = {}

    _page = (offset, total, accumulator = []) =>
      debug 'PAGED iteration (offset: %s, total: %s)', offset, total
      if total? and (offset + limit) >= total + limit
        notify(percentage: 100, value: accumulator) if notify
        # return if there are no more pages
        resolve null, tmpResponse, _buildPagedQueryResponse(accumulator)
      else
        queryParams = _.stringifyQuery _.extend {}, params, offset: offset
        @GET "#{endpoint}?#{queryParams}", (error, response, body) ->
          notify(
            percentage: if total then _.percentage(offset, total) else 0
            value: body
          ) if notify
          if error
            resolve(error, response, body)
          else
            if response.statusCode is 200
              tmpResponse = response
              _page(offset + limit, body.total, accumulator.concat(body.results))
            else
              resolve(error, response, body)
    _page(params.offset)
    return


###
Exports object
###
module.exports = Rest
