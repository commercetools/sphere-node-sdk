_ = require 'underscore'
_.mixin require('sphere-node-utils')._u
SphereClient = require '../../lib/client'
Config = require('../../config').config
{_u} = require('sphere-node-utils')


CHANNEL_KEY = 'OrderXmlFileExport'
ROLE_ORDER_EXPORT = 'OrderExport'
ROLE_INVENTORY_SUPPLY = 'InventorySupply'

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
      done _u.prettify(error)

  afterEach (done) ->
    @client.channels.byId(@channel.id).delete(@channel.version)
    .then (result) =>
      @logger.info "Channel deleted: #{@channel.id}"
      expect(result.statusCode).toBe 200
      done()
    .fail (error) ->
      done _u.prettify(error)

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
      done _u.prettify(error)

  it 'should create a new channel with given role and return it', (done) ->
    key = "channel-#{new Date().getTime()}"
    @client.channels.byKeyOrCreate(key, ROLE_ORDER_EXPORT)
    .then (result) ->
      channels.push result.body
      expect(result.body).toBeDefined()
      expect(result.body.key).toEqual key
      expect(result.body.roles).toEqual [ROLE_ORDER_EXPORT]
      done()
    .fail (error) ->
      done _u.prettify(err)

  it 'should fetch an existing channel, add given role and return it', (done) ->

    @client.channels.byKeyOrCreate(@channel.key, ROLE_ORDER_EXPORT)
    .then (result) =>
      @client.channels.byKeyOrCreate(@channel.key, 'Primary')
      .then (result) ->
      expect(result.body.roles).toEqual [ROLE_INVENTORY_SUPPLY, ROLE_ORDER_EXPORT]
      done()
    .fail (error) ->
      done _u.prettify(err)

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
      done _u.prettify(err)

  it 'should fail if role value is not supported', (done) ->
    @client.channels.byKeyOrCreate(@channel.key, 'undefined-role')
    .then (result) ->
      done 'Role value not supported.'
    .fail (error) ->
      done()
