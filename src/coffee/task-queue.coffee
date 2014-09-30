_ = require 'underscore'
Promise = require 'bluebird'

###*
 * Creates a new TaskQueue instance
 * @class TaskQueue
###
class TaskQueue

  ###*
   * Initialize the class
   * @constructor
   * @param {Object} [opts] A JSON object containg configuration options
  ###
  constructor: (opts = {}) ->
    {maxParallel} = opts
    @setMaxParallel(maxParallel)
    @_queue = []
    @_activeCount = 0

  ###*
   * Set the maxParallel parameter with a custom number.
   * @param {Number} maxParallel A number between 1 and 100 (default 20)
   * @throws {Error} If number < 1 or > 100
  ###
  setMaxParallel: (maxParallel = 20) ->
    throw new Error 'MaxParallel must be a number between 1 and 100' if _.isNumber(maxParallel) and (maxParallel < 1 or maxParallel > 100)
    @_maxParallel = maxParallel

  ###*
   * Add a new Task to the queue
   * @param {Function} taskFn A {Promise} that will be resolved once the task is executed
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with an error
  ###
  addTask: (taskFn) ->
    new Promise (resolve, reject) =>
      @_queue.push
        fn: taskFn
        resolve: resolve
        reject: reject
      @_maybeExecute()

  ###*
   * @private
   * Start a task by resolving its {Promise}
   * @param {Object} task A Task object containing a function and a deferred
  ###
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

  ###*
   * @private
   * Will recursively check if a new task should be triggered
  ###
  _maybeExecute: ->
    if @_activeCount < @_maxParallel and @_queue.length > 0
      @_startTask @_queue.shift()
      @_maybeExecute()

module.exports = TaskQueue
