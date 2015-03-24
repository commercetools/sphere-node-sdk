_ = require 'underscore'
Promise = require 'bluebird'

# Public: A `TaskQueue` allows to queue `tasks` (that return `Promises`) which will be executed in parallel
# until a `max limit`, meaning that new tasks will not be triggered until the previous ones are resolved.
#
# Examples
#
#   callMe = ->
#     new Promise (resolve, reject) ->
#       setTimeout ->
#         resolve true
#       , 5000
#   task = new TaskQueue maxParallel: 50 # default 20
#   task.addTask callMe
#   .then (result) -> # result == true
#   .catch (error) ->
class TaskQueue

  # Public: Initialize the `TaskQueue`
  #
  # options - An {Object} to configure the service
  #   :maxParallel - {Number} The limit to how many parallel tasks can run
  constructor: (options = {}) ->
    {maxParallel} = options
    @setMaxParallel(maxParallel)
    @_queue = []
    @_activeCount = 0

  # Public: Set the `maxParallel` parameter
  #
  # Throws an {Error} if `maxParallel` is not between `1` and `100`
  setMaxParallel: (maxParallel = 20) ->
    throw new Error 'MaxParallel must be a number between 1 and 100' if _.isNumber(maxParallel) and (maxParallel < 1 or maxParallel > 100)
    @_maxParallel = maxParallel

  # Public: Add a new `task` to the queue
  #
  # taskFn - {Function} The function that will be resolved once the task is executed
  #
  # Returns a {Promise}
  #
  # Examples
  #
  #   queue = new TaskQueue
  #   task = ->
  #     new Promise (resolve, reject) ->
  #       resolve 'ok'
  #   queue.addTask task
  addTask: (taskFn) ->
    new Promise (resolve, reject) =>
      @_queue.push
        fn: taskFn
        resolve: resolve
        reject: reject
      @_maybeExecute()

  # Private: Start a task by resolving its {Promise}
  _startTask: (task) ->
    @_activeCount += 1

    task.fn()
    .then (res) ->
      task.resolve res
    .catch (error) ->
      task.reject error
    .finally =>
      @_activeCount -= 1
      @_maybeExecute()
    .done()

  # Private: Will recursively check if a new task should be triggered
  _maybeExecute: ->
    if @_activeCount < @_maxParallel and @_queue.length > 0
      @_startTask @_queue.shift()
      @_maybeExecute()

module.exports = TaskQueue
