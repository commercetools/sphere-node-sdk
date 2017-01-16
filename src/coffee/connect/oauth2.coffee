debug = require('debug')('sphere-connect:oauth2')
_ = require 'underscore'
_.mixin require('underscore-mixins')
request = require 'request'

# Public: Define an HTTP client to connect to the SPHERE.IO OAuth webservice.
#
# Examples
#
#   oa = new OAuth2
#     config:
#       client_id: "CLIENT_ID_HERE"
#       client_secret: "CLIENT_SECRET_HERE"
#       project_key: "PROJECT_KEY_HERE"
#     host: 'auth.sphere.io' # optional
#     accessTokenUrl: '/oauth/token' # optional
#     timeout: 20000 # optional
#     rejectUnauthorized: true # optional
#     user_agent: 'sphere-node-connect' # optional
#   oa.getAccessToken (error, response, body) -> # do something
class OAuth2

  # Public: Initialize the HTTP client
  #
  # options - An {Object} to configure the service
  #   :config - {Object} It contains the credentials `project_key`, `client_id`, `client_secret`
  #   :host - {String} The host (default `auth.sphere.io`)
  #   :protocol - {String} The protocol (default `https`)
  #   :accessTokenUrl - {String} The url path to the token endpoint (default `/oauth/token`)
  #   :user_agent - {String} The request `User-Agent` (default `sphere-node-connect`)
  #   :timeout - {Number} The request timeout (default `20000`)
  #   :rejectUnauthorized - {Boolean} Whether to reject clients with invalid certificates or not (default `true`)
  #
  # Throws an {Error} if credentials are missing
  constructor: (opts = {}) ->
    config = opts.config
    throw new Error('Missing credentials') unless config
    throw new Error('Missing \'client_id\'') unless config.client_id or opts.access_token
    throw new Error('Missing \'client_secret\'') unless config.client_secret or opts.access_token
    throw new Error('Missing \'project_key\'') unless config.project_key

    host = opts.host or 'auth.sphere.io'
    protocol = opts.protocol or 'https'

    rejectUnauthorized = if _.isUndefined(opts.rejectUnauthorized) then true else opts.rejectUnauthorized
    userAgent = if _.isUndefined(opts.user_agent) then 'sphere-node-connect' else opts.user_agent
    @_options =
      config: config
      host: host
      protocol: protocol
      accessTokenUrl: opts.accessTokenUrl or '/oauth/token'
      timeout: opts.timeout or 60000
      rejectUnauthorized: rejectUnauthorized
      userAgent: userAgent

    debug 'oauth2 options: %j', @_options
    return

  # Public: Retrieve an `access_token`
  #
  # callback - {Function} A function fulfilled with `error, response, body` arguments.
  getAccessToken: (callback) ->
    params =
      grant_type: 'client_credentials'
      scope: "manage_project:#{@_options.config.project_key}"

    payload = _.stringifyQuery(params)
    request_options =
      uri: "#{@_options.protocol}://#{@_options.host}#{@_options.accessTokenUrl}"
      auth:
        user: @_options.config.client_id
        pass: @_options.config.client_secret
      json: true
      method: 'POST'
      body: payload
      headers:
        'Content-Type': 'application/x-www-form-urlencoded'
        'Content-Length': payload.length
        'User-Agent': @_options.userAgent
      timeout: @_options.timeout
      rejectUnauthorized: @_options.rejectUnauthorized

    debug 'access_token request options: %j', request_options
    @_doRequest(request_options, callback)

  # Private: Execute the request using the underling `request` module
  #
  # See {https://github.com/mikeal/request}
  _doRequest: (options, callback) ->
    request options, (e, r, b) ->
      debug('error on request: %j', e) if e
      callback(e, r, b)

module.exports = OAuth2
