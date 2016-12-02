{ Repeater } = require 'sphere-node-utils'
Promise = require 'bluebird'
util = require 'util'
TaskQueue = require './task-queue'

# Response messages which will be handled by `RepeaterTaskQueue`
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

# Public: A `RepeaterTaskQueue` adds request repeater on particular response errors
#
# `RepeaterTaskQueue` receives two objects as parameter.
# First object overriding `maxParallel` value of `TaskQueue`
# Second object contains information about the count of attempts, timeout and timeout type.
# There are 2 types of `timeoutType`:
# - `c`: constant delay
# - `v`: variable delay (grows with attempts count with a random component)
#
#   task = new RepeaterTaskQueue { maxParallel: 30 }, { attempts: 50, timeout: 200, timeoutType: 'v' }
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
