debug = require('debug')('spec-integration:inventories')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, InventorySync} = require '../../lib/main'
Config = require('../../config').config

describe 'Integration Inventories Sync', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config
    @sync = new InventorySync

    @client.inventoryEntries().all().fetch()
    .then (result) =>
      stocks = result.body.results
      debug 'Cleaning up all inventory entries'
      Promise.all _.map stocks, (s) => @client.inventoryEntries().byId(s.id).delete(s.version)
    .then -> done()
    .catch (error) -> done(_.prettify(error))

  it 'should update inventory entry', (done) ->
    ie =
      sku: '123'
      quantityOnStock: 3
    ieChanged =
      sku: '123'
      quantityOnStock: 7
    @client.inventoryEntries().create(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      syncedActions = @sync.buildActions(ieChanged, result.body)
      debug 'About to update inventory with synced actions (quantity)'
      @client.inventoryEntries().byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 7
      done()
    .catch (error) -> done(_.prettify(error))

  it 'should add expectedDelivery date', (done) ->
    ie =
      sku: 'x1'
      quantityOnStock: 3
    ieChanged =
      sku: 'x1'
      quantityOnStock: 7
      expectedDelivery: '2000-01-01T01:01:01'
    @client.inventoryEntries().create(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      syncedActions = @sync.buildActions(ieChanged, result.body)
      debug 'About to update inventory with synced actions (expectedDelivery add)'
      @client.inventoryEntries().byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 7
      expect(result.body.expectedDelivery).toBe '2000-01-01T01:01:01.000Z'
      done()
    .catch (error) -> done(_.prettify(error))

  it 'should update expectedDelivery date', (done) ->
    ie =
      sku: 'x2'
      quantityOnStock: 3
      expectedDelivery: '1999-01-01T01:01:01.000Z'
    ieChanged =
      sku: 'x2'
      quantityOnStock: 3
      expectedDelivery: '2000-01-01T01:01:01.000Z'
    @client.inventoryEntries().create(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      syncedActions = @sync.buildActions(ieChanged, result.body)
      debug 'About to update inventory with synced actions (expectedDelivery update)'
      @client.inventoryEntries().byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 3
      expect(result.body.expectedDelivery).toBe '2000-01-01T01:01:01.000Z'
      done()
    .catch (error) -> done(_.prettify(error))

  it 'should remove expectedDelivery date', (done) ->
    ie =
      sku: 'x3'
      quantityOnStock: 3
      expectedDelivery: '2000-01-01T01:01:01.000Z'
    ieChanged =
      sku: 'x3'
      quantityOnStock: 3
    @client.inventoryEntries().create(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      syncedActions = @sync.buildActions(ieChanged, result.body)
      debug 'About to update inventory with synced actions (expectedDelivery remove)'
      @client.inventoryEntries().byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 3
      expect(result.body.expectedDelivery).not.toBeDefined()
      done()
    .catch (error) -> done(_.prettify(error))
