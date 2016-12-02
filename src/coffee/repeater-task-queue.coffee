{ Repeater } = require 'sphere-node-utils'
Promise = require 'bluebird'
util = require 'util'
TaskQueue = require './task-queue'

retryKeywords = [
  'ETIMEDOUT'
  'socket hang up'
  'write EPROTO'
  'Retry later'
  'I am the LoadBalancer of'
  'Gateway Timeout'
  'Bad Gateway'
  'EAI_AGAIN'
  'ESOCKETTIMEDOUT'
  'Oops. This shouldn\'t happen'
  'InternalServerError: Undefined'
  'Temporary overloading'
  'read ECONNRESET'
  'getaddrinfo ENOTFOUND'
  'Cannot commit on stream id'
]

class RepeaterTaskQueue extends TaskQueue


  constructor: (options, repeaterOptions) ->
    super options
    @repeaterOptions = repeaterOptions


  _startTask: (task) =>
    @_activeCount += 1
    repeater = new Repeater(@repeaterOptions)
    toRepeat = repeater.execute task.fn, (err) =>
      if @_shouldRetry(err)
        return Promise.resolve()
      else
        Promise.reject err
    toRepeat.then (res) ->
      task.resolve res
      return
    .catch (err) ->
      task.reject err
      return
    .finally =>
      @_activeCount -= 1
      @_maybeExecute()
    .done()


  _shouldRetry: (error) ->
    if error and (error.code and util.inspect(error.code).startsWith('5') or error.statusCode and util.inspect(error.statusCode).startsWith('5'))
      return true
    retryKeywords.find (str) ->
      util.inspect(error, depth: null).toUpperCase().indexOf(str.toUpperCase()) > -1
      return

module.exports = RepeaterTaskQueue
