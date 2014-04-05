_ = require 'underscore'
_.mixin require('sphere-node-utils')._u
SphereClient = require '../../lib/client'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newChannel = ->
  key: uniqueId 'c'

updateChannel = (version) ->
  version: version
  actions: [
    {action: 'changeName', name: {en: 'A Channel'}}
    {action: 'changeDescription', description: {en: 'This is a Channel'}}
    {action: 'setRoles', roles: ['InventorySupply', 'OrderImport']}
  ]

describe 'Integration Channels', ->

  beforeEach (done) ->
    @client = new SphereClient
      config: Config
      logConfig:
        levelStream: 'info'
        levelFile: 'error'
    @logger = @client._logger

    @client.channels.save(newChannel())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @channel = result.body
      @logger.info @channel, 'New channel created'
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettifyError(error))

  afterEach (done) ->
    @client.channels.byId(@channel.id).delete(@channel.version)
    .then (result) =>
      @logger.info "Channel deleted: #{@channel.id}"
      expect(result.statusCode).toBe 200
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettifyError(error))

  it 'should update a channel', (done) ->
    @client.channels.byId(@channel.id).update(updateChannel(@channel.version))
    .then (result) =>
      expect(result.statusCode).toBe 200
      @channel = result.body
      expect(@channel.name).toEqual {en: 'A Channel'}
      expect(@channel.description).toEqual {en: 'This is a Channel'}
      expect(@channel.roles).toEqual ['InventorySupply', 'OrderImport']
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettifyError(error))
