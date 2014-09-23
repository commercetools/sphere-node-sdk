_ = require 'underscore'
Q = require 'q'
InventorySync = require '../../../lib/sync/inventory-sync'
# order = require '../../models/order.json'

xdescribe 'Integration test :: Inventories', ->

  beforeEach (done) ->
    @sync = new InventorySync
      config: Config.staging
      logConfig:
        levelStream: 'error'
        levelFile: 'error'

    @sync._client.inventoryEntries.perPage(0).fetch()
    .then (result) =>
      stocks = result.body.results
      if stocks.length is 0
        Q()
      else
        dels = []
        for s in stocks
          dels.push @sync._client.inventoryEntries.byId(s.id).delete(s.version)
        Q.all(dels)
    .then (v) -> done()
    .fail (error) ->
      if error.statusCode is 404
        done()
      else
        done(error)

  it 'should update inventory entry', (done) ->
    ie =
      sku: '123'
      quantityOnStock: 3
    ieChanged =
      sku: '123'
      quantityOnStock: 7
    @sync._client.inventoryEntries.save(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      @sync.buildActions(ieChanged, result.body).update()
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 7
      done()
    .fail (error) -> done(error)

  it 'should add expectedDelivery date', (done) ->
    ie =
      sku: 'x1'
      quantityOnStock: 3
    ieChanged =
      sku: 'x1'
      quantityOnStock: 7
      expectedDelivery: '2000-01-01T01:01:01'
    @sync._client.inventoryEntries.save(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      @sync.buildActions(ieChanged, result.body).update()
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 7
      expect(result.body.expectedDelivery).toBe '2000-01-01T01:01:01.000Z'
      done()
    .fail (error) -> done(error)

  it 'should update expectedDelivery date', (done) ->
    ie =
      sku: 'x2'
      quantityOnStock: 3
      expectedDelivery: '1999-01-01T01:01:01.000Z'
    ieChanged =
      sku: 'x2'
      quantityOnStock: 3
      expectedDelivery: '2000-01-01T01:01:01.000Z'
    @sync._client.inventoryEntries.save(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      @sync.buildActions(ieChanged, result.body).update()
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 3
      expect(result.body.expectedDelivery).toBe '2000-01-01T01:01:01.000Z'
      done()
    .fail (error) -> done(error)

  it 'should remove expectedDelivery date', (done) ->
    ie =
      sku: 'x3'
      quantityOnStock: 3
      expectedDelivery: '2000-01-01T01:01:01.000Z'
    ieChanged =
      sku: 'x3'
      quantityOnStock: 3
    @sync._client.inventoryEntries.save(ie)
    .then (result) =>
      expect(result.statusCode).toBe 201
      @sync.buildActions(ieChanged, result.body).update()
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.quantityOnStock).toBe 3
      expect(result.body.expectedDelivery).not.toBeDefined()
      done()
    .fail (error) -> done(error)
