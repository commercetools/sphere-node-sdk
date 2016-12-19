{ Repeater } = require 'sphere-node-utils'
Promise = require 'bluebird'
TaskQueue = require './task-queue'
_ = require 'underscore'

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
# Second object contains information about the count of attempts, timeout, timeout type and retry keywords.
# There are 2 types of `timeoutType`:
# - `c`: constant delay
# - `v`: variable delay (grows with attempts count with a random component)
# It's possible to customize default list of handled error messages. To do this just pass new array to `retryKeywords`
#
#  Examples
#
#   task = new RepeaterTaskQueue { maxParallel: 30 }, { attempts: 50, timeout: 200, timeoutType: 'v', retryKeywords: ['test1', 'test2'] }
class RepeaterTaskQueue extends TaskQueue


  constructor: (options, repeaterOptions) ->
    super options
    repeaterOptions = _.defaults repeaterOptions,
      attempts: 50
      timeout: 200
      timeoutType: 'v'
      retryKeywords: retryKeywords
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
    return error?.code?.toString().startsWith('5') or
        error?.statusCode?.toString().startsWith('5') or
        @repeaterOptions.retryKeywords.some (keyword) ->
          JSON.stringify(error).toUpperCase().includes(keyword.toUpperCase())

module.exports = RepeaterTaskQueue
