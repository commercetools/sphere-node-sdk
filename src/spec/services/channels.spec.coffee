Q = require 'q'
_ = require 'underscore'
_.mixin require('underscore-mixins')
ChannelService = require '../../lib/services/channels'

###*
 * Describe service specific implementations
###
describe 'ChannelService', ->

  beforeEach ->
    @loggerMock =
      trace: ->
      debug: ->
      info: ->
      warn: ->
      error: ->
      fatal: ->
    @channels = new ChannelService
      _rest: null
      _task: null
      _logger: @loggerMock
      _stats:
        includeHeaders: false

  it 'should fail if key is not defined', ->
    expect(=> @channels.ensure(undefined, 'role'))
      .toThrow new Error 'Key is required.'

  it 'should fail if role is not defined', ->
    expect(=> @channels.ensure('key', undefined))
      .toThrow new Error 'Role is required.'

  it 'should just return the channel if roles haven\'t changed', (done) ->
    spyOn(@channels, '_save')
    spyOn(@channels, '_get').andReturn Q
      statusCode: 200
      body:
        total: 1
        results: [
          id: '123'
          key: 'a-unique-key'
          roles: ['foo', 'bar', 'qux']
        ]
    @channels.ensure('a-unique-key', ['foo', 'bar', 'qux'])
    .then (result) =>
      expect(@channels._save).not.toHaveBeenCalled()
      done()
    .fail (error) -> done(_.prettify error)

  it 'should flatten the roles when creating the payload', (done) ->
    spyOn(@channels, 'update')
    spyOn(@channels, '_get').andReturn Q
      statusCode: 200
      body:
        total: 1
        results: [
          id: '123'
          version: 2
          key: 'a-unique-key'
          roles: ['foo', 'bar']
        ]
    @channels.ensure('a-unique-key', 'qux')
    .then (result) =>
      expected_update =
        version: 2
        actions: [
          { action: 'addRoles', roles: ['qux'] }
        ]
      expect(@channels.update).toHaveBeenCalledWith expected_update
      done()
    .fail (error) -> done(_.prettify error)
