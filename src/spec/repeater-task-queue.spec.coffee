SphereClient = require '../lib/client'
RepeaterTaskQueue = require '../lib/repeater-task-queue'
Config = require('../config').config
util = require('util')
_ = require 'underscore'
describe 'RepeaterTaskQueue', ->

  repeaterOptions = {
    attempts: 5,
    timeout: 200
  }

  beforeEach ->
    task = new RepeaterTaskQueue { maxParallel: 30 }, { attempts: 5, timeout: 200, timeoutType: 'v' }
    sphereConfig = { config: Config, task }
    @client = new SphereClient sphereConfig


  it 'should finally resolve after four tries', (done) ->

    callsMap = {
      0: { statusCode: 500, message: 'ETIMEDOUT' }
      1: { code: 500, message: 'ETIMEDOUT' }
      2: { code: 789, message: 'ETIMEDOUT' }
      3: { statusCode: 200, message: 'success' }
    }
    callCount = 0
    spyOn(@client._rest, 'GET').andCallFake (resource, callback) ->
      currentCall = callsMap[callCount]
      callCount++
      statusCode = currentCall.statusCode
      message = currentCall.message
      callback(null, { statusCode }, { message })

    @client.products.fetch()
    .then (res) =>
      expect(@client._rest.GET.calls.length).toEqual 4
      expect(res.body.message).toEqual 'success'
      done()
    .catch (err) -> done(err)


  it 'should repeat requests several times for 5xx error codes', (done) ->
    spyOn(@client._rest, 'GET').andCallFake (resource, callback) ->
      callback(null, { statusCode: 500 }, { code: 500 })

    @client.products.fetch()
      .then ->
        done 'Error expected'
      .catch =>
        expect(@client._rest.GET.calls.length).toEqual repeaterOptions.attempts
        done()


  it 'should repeat requests several times for certain error messages', (done) ->
    spyOn(@client._rest, 'GET').andCallFake (resource, callback) ->
      callback(null, { statusCode: 500 }, { message: 'ETIMEDOUT' })

    @client.products.fetch()
      .then ->
        done 'Error expected'
      .catch =>
        expect(@client._rest.GET.calls.length).toEqual repeaterOptions.attempts
        done()


  it 'should not repeat requests for non-5xx errors', (done) ->
    spyOn(@client._rest, 'GET').andCallFake (resource, callback) ->
      callback(null, { statusCode: 400 }, { message: 'something' })

    @client.products.fetch()
    .then ->
      done 'Error expected'
    .catch (err) =>
      expect(err.message).toEqual 'something'
      expect(@client._rest.GET.calls.length).toEqual 1
      done()

  it 'should set default repeater options on empty object', (done) ->
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
    task = new RepeaterTaskQueue {}, {}
    expect(_.isEqual(task.repeaterOptions.retryKeywords, retryKeywords)).toEqual true
    expect(task.repeaterOptions.attempts).toEqual 50
    expect(task.repeaterOptions.timeout).toEqual 200
    expect(task.repeaterOptions.timeoutType).toEqual 'v'
    done()

  it 'should set custom repeater options', (done) ->
    retryKeywords = [
      'test1'
      'test2'
    ]
    task = new RepeaterTaskQueue {}, { attempts: 7, timeout: 211, timeoutType: 'c',  retryKeywords: retryKeywords}
    expect(_.isEqual(task.repeaterOptions.retryKeywords, retryKeywords)).toEqual true
    expect(task.repeaterOptions.attempts).toEqual 7
    expect(task.repeaterOptions.timeout).toEqual 211
    expect(task.repeaterOptions.timeoutType).toEqual 'c'
    done()