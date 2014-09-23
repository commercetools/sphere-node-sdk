InventorySync = require '../../lib/sync/inventory-sync'

describe 'InventorySync', ->

  beforeEach ->
    @sync = new InventorySync

  afterEach ->
    @sync = null

  describe ':: config', ->

    it 'should build white/black-listed actions update', ->
      opts = [
        {type: 'quantity', group: 'white'}
        {type: 'expectedDelivery', group: 'black'}
      ]
      newInventory =
        id: '123'
        quantityOnStock: 2
        version: 1
      oldInventory =
        id: '123'
        quantityOnStock: 10
        version: 1
      spyOn(@sync._utils, 'actionsMapExpectedDelivery').andReturn [{action: 'setExpectedDelivery', expectedDelivery: "2001-09-11T14:00:00.000Z"}]
      update = @sync.config(opts).buildActions(newInventory, oldInventory).get()
      expected_update =
        actions: [
          { action: 'removeQuantity', quantity: 8 }
        ]
        version: oldInventory.version
      expect(update).toEqual expected_update

  describe ':: buildActions', ->

    it 'no differences', ->
      ie =
        id: 'abc'
        sku: '123'
        quantityOnStock: 7
      update = @sync.buildActions(ie, ie).get()
      expect(update).toBeUndefined()
      updateId = @sync.buildActions(ie, ie).get('updateId')
      expect(updateId).toBe 'abc'

    it 'more quantity', ->
      ieNew =
        sku: '123'
        quantityOnStock: 77
      ieOld =
        sku: '123'
        quantityOnStock: 9
      update = @sync.buildActions(ieNew, ieOld).get()
      expect(update).toBeDefined()
      expect(update.actions[0].action).toBe 'addQuantity'
      expect(update.actions[0].quantity).toBe 68

    it 'less quantity', ->
      ieNew =
        sku: '123'
        quantityOnStock: 7
      ieOld =
        sku: '123'
        quantityOnStock: 9
      update = @sync.buildActions(ieNew, ieOld).get()
      expect(update).toBeDefined()
      expect(update.actions[0].action).toBe 'removeQuantity'
      expect(update.actions[0].quantity).toBe 2

    it 'should add expectedDelivery', ->
      ieNew =
        sku: 'xyz'
        quantityOnStock: 9
        expectedDelivery: '2014-01-01T01:02:03'
      ieOld =
        sku: 'xyz'
        quantityOnStock: 9
      update = @sync.buildActions(ieNew, ieOld).get()
      expect(update).toBeDefined()
      expect(update.actions[0].action).toBe 'setExpectedDelivery'
      expect(update.actions[0].expectedDelivery).toBe '2014-01-01T01:02:03'

    it 'should update expectedDelivery', ->
      ieNew =
        sku: 'abc'
        quantityOnStock: 0
        expectedDelivery: '2000'
      ieOld =
        sku: 'abc'
        quantityOnStock: 0
        expectedDelivery: '1999'
      update = @sync.buildActions(ieNew, ieOld).get()
      expect(update).toBeDefined()
      expect(update.actions[0].action).toBe 'setExpectedDelivery'
      expect(update.actions[0].expectedDelivery).toBe '2000'

    it 'should remove expectedDelivery', ->
      ieNew =
        sku: 'abc'
        quantityOnStock: 0
      ieOld =
        sku: 'abc'
        quantityOnStock: 0
        expectedDelivery: '1999'
      update = @sync.buildActions(ieNew, ieOld).get()
      expect(update).toBeDefined()
      expect(update.actions[0].action).toBe 'setExpectedDelivery'
      expect(update.actions[0].expectedDelivery).toBeUndefined()
