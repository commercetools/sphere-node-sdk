Q = require 'q'
TaskQueue = require '../lib/task-queue'

describe 'TaskQueue', ->

  beforeEach ->
    @task = new TaskQueue

  it 'should define default values', ->
    expect(@task._maxParallel).toBe 20
    expect(@task._queue).toEqual []
    expect(@task._activeCount).toBe 0

  it 'should pass custom options', ->
    task = new TaskQueue maxParallel: 50
    expect(task._maxParallel).toBe 50

  it 'should set maxParallel', ->
    @task.setMaxParallel 10
    expect(@task._maxParallel).toBe 10

  it 'should throw if maxParallel is < 1', ->
    expect(=> @task.setMaxParallel(0)).toThrow new Error 'MaxParallel must be a number between 1 and 100'

  it 'should throw if maxParallel is > 100', ->
    expect(=> @task.setMaxParallel(101)).toThrow new Error 'MaxParallel must be a number between 1 and 100'

  it 'should add a task to the queue and return a promise', ->
    spyOn(@task, '_maybeExecute')
    promise = @task.addTask Q()
    expect(Q.isPromise(promise)).toBe true
    expect(@task._queue.length).toBe 1
    expect(@task._maybeExecute).toHaveBeenCalled()

  it 'should start and resolve a task', (done) ->
    callMe = ->
      d = Q.defer()
      setTimeout ->
        d.resolve true
      , 500
      d.promise
    @task.addTask callMe
    .then (result) ->
      expect(result).toBe true
      done()
    .fail (error) -> done(error)