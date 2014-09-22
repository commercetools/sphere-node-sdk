_ = require 'underscore'

###*
 * A Logger wrapper that provides standard log functions mapped to a given object.
 * @example
 *   winston = require('winston')
 *   sphereClientLogger = new Logger
 *     debug: (opts, msg) -> winston.log 'debug', msg, opts
 *     info: (opts, msg) -> winston.log 'info', msg, opts
 *     warn: (opts, msg) -> winston.log 'warn', msg, opts
 *     error: (opts, msg) -> winston.log 'error', msg, opts
###
module.exports = class

  ###*
   * @constructor
   * Initialize Logger and supply default log implementation
   * @param  {Object} logger A JSON object with log functions to be mapped
  ###
  constructor: (logger = {}) ->
    @_logger = _.defaults logger,
      debug: -> #noop
      info: -> #noop
      warn: -> #noop
      error: -> #noop

  ###*
   * @private
   * A wrapper to internally map log messages to given log function
   * @param  {String} type The log level type
   * @param  {Object} opts An optional JSON object
   * @param  {String} msg The log message
  ###
  _wrapOptions: (type, opts, msg) ->
    if not msg and _.isString opts
      msg = opts
      opts = {}
    wrappedData =
      log_source: 'sphere-node-client'
      data: opts
    @_logger[type](wrappedData, msg)

  ###*
   * @public
  ###
  debug: (opts, msg) -> @_wrapOptions 'debug', opts, msg

  ###*
   * @public
  ###
  info: (opts, msg) -> @_wrapOptions 'info', opts, msg

  ###*
   * @public
  ###
  warn: (opts, msg) -> @_wrapOptions 'warn', opts, msg

  ###*
   * @public
  ###
  error: (opts, msg) -> @_wrapOptions 'error', opts, msg
