_ = require 'underscore'
_.mixin require('sphere-node-utils')._u
SphereClient = require '../../lib/client'
Config = require('../../config').config

CHANNEL_KEY = 'OrderXmlFileExport'
ROLE_ORDER_EXPORT = 'OrderExport'
ROLE_INVENTORY_SUPPLY = 'InventorySupply'
ROLE_PRIMARY = 'Primary'

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newChannel = ->
  key: uniqueId 'c'

updateChannel = (version) ->
  version: version
  actions: [
    {action: 'changeName', name: {en: 'A Channel'}}
    {action: 'changeDescription', description: {en: 'This is a Channel'}}
    {action: 'setRoles', roles: [ROLE_INVENTORY_SUPPLY, ROLE_ORDER_EXPORT]}
  ]

describe 'Integration Channels', ->

  channels = []

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
    .fail (error) ->
      done _.prettify(error)

  afterEach (done) ->
    @client.channels.byId(@channel.id).delete(@channel.version)
    .then (result) =>
      @logger.info "Channel deleted: #{@channel.id}"
      expect(result.statusCode).toBe 200
      done()
    .fail (error) ->
      done _.prettify(error)

  it 'should update a channel', (done) ->
    @client.channels.byId(@channel.id).update(updateChannel(@channel.version))
    .then (result) =>
      expect(result.statusCode).toBe 200
      @channel = result.body
      expect(@channel.name).toEqual {en: 'A Channel'}
      expect(@channel.description).toEqual {en: 'This is a Channel'}
      expect(@channel.roles).toEqual [ROLE_INVENTORY_SUPPLY, ROLE_ORDER_EXPORT]
      done()
    .fail (error) ->
      done _.prettify(error)

  it 'should fail if key is not defined', (done) ->
    @client.channels.byKeyOrCreate(undefined, ROLE_ORDER_EXPORT)
    .then (result) ->
      done 'Error must be thrown if key is not defined'
    .fail (error) ->
      expect(error.message).toBeDefined()
      expect(error.message).toEqual 'Key is required.'
      done()

  it 'should fail if role is not defined', (done) ->
    @client.channels.byKeyOrCreate('key', undefined)
    .then (result) ->
      console.log 1
      done 'Error must be thrown if role is not defined'
    .fail (error) ->
      console.log 2
      expect(error.message).toBeDefined()
      expect(error.message).toEqual 'Role is required.'
      done()

  it 'should create a new channel with given role and return it', (done) ->
    key = uniqueId "channel"
    @client.channels.byKeyOrCreate(key, ROLE_ORDER_EXPORT)
    .then (result) ->
      channels.push result.body
      expect(result.body).toBeDefined()
      expect(result.body.key).toEqual key
      expect(result.body.roles).toEqual [ROLE_ORDER_EXPORT]
      done()
    .fail (error) ->
      done _.prettify(err)

  it 'should fetch an existing channel, add given role and return it', (done) ->

    @client.channels.byKeyOrCreate(@channel.key, ROLE_ORDER_EXPORT)
    .then (result) =>
      @client.channels.byKeyOrCreate(@channel.key, ROLE_PRIMARY)
      .then (result) ->
      expect(result.body.roles).toEqual [ROLE_INVENTORY_SUPPLY, ROLE_ORDER_EXPORT]
      done()
    .fail (error) ->
      done _.prettify(err)

  it 'should fetch an existing channel and return it', (done) ->

    @client.channels.byId(@channel.id).update(updateChannel(@channel.version))
    .then (result) =>
      @channel = result.body
      @client.channels.byKeyOrCreate(@channel.key, ROLE_ORDER_EXPORT)
    .then (result) =>
      expect(result.body).toBeDefined()
      expect(result.body.id).toEqual @channel.id
      expect(result.body.roles).toEqual @channel.roles
      done()
    .fail (error) ->
      done _.prettify(err)

  it 'should fail if role value is not supported', (done) ->
    @client.channels.byKeyOrCreate(@channel.key, 'undefined-role')
    .then (result) ->
      done 'Role value not supported.'
    .fail (error) ->
      done()
