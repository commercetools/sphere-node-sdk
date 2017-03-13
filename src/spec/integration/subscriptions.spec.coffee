{SphereClient} = require '../../lib/main'
Config = require('../../config').config
ironConfig = require('../../config').ironConfig
Promise = require 'bluebird'
debug = require('debug')('spec-integration:products')

newSubscription =
  key: 'testKey'
  destination:
    type: 'IronMQ'
    uri: "#{ironConfig.iron_mq_url}/3/projects/#{ironConfig.iron_project_id}/queues/test-queue/webhook?oauth=#{ironConfig.iron_token}"
  messages: [
    resourceTypeId: 'inventory-entry'
    types: ['InventoryEntryDeleted']
  ]

describe 'Integration Subscriptions', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config
    done()

  afterEach (done) ->
    debug 'Removing all subscriptions'
    @client.subscriptions.all().fetch()
    .then (response) =>
      Promise.map(response.body.results, (sub) =>
        @client.subscriptions.byId(sub.id).delete(sub.version)
      )
    .then () ->
      done()

  it 'should create subscription', (done) ->
    @client.subscriptions.save(newSubscription)
    .then (response) =>
      expect(response.statusCode).toBe 201
      expect(response.body.id).toBeDefined()
      done()
  , 20000

  it 'should update message subscriptions', (done) ->
    @client.subscriptions.save(newSubscription)
    .then (response) =>
      @client.subscriptions.byId(response.body.id).update(
        version: response.body.version
        actions: [
          action:'setMessages'
          messages: [
            resourceTypeId: 'cart'
          ]
        ]

      )
    .then (response) ->
      expect(response.statusCode).toBe 200
      expect(response.body.messages.length).toBe 1
      expect(response.body.messages[0].resourceTypeId).toBe 'cart'
      expect(response.body.messages[0].types.length).toBe 0
      done()
  , 20000

  it 'should delete subscription by key', (done) ->
    newSubscriptionKey = newSubscription.key
    @client.subscriptions.save(newSubscription)
      .then (response) =>
        @client.subscriptions.byKey(newSubscriptionKey).delete(response.body.version)
      .then () =>
        @client.subscriptions.where("key=\"#{newSubscriptionKey}\"").fetch()
      .then (response) =>
        expect(response.body.total).toBe 0
        done()
