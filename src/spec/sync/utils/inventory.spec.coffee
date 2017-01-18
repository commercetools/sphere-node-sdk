_ = require 'underscore'
_.mixin require 'underscore-mixins'
InventoryUtils = require '../../../lib/sync/utils/inventory'

INVENTORY =
  id: '123'
  sku: '123'
  quantityOnStock: 7

describe 'InventoryUtils', ->

  beforeEach ->
    @utils = new InventoryUtils
    @inventory = _.deepClone INVENTORY

  afterEach ->
    @utils = null

  describe ':: actionsMapQuantity', ->

    it 'should return required actions for syncing quantity', ->
      inventoryChanged = _.deepClone @inventory
      inventoryChanged.quantityOnStock = 10

      delta = @utils.diff(@inventory, inventoryChanged)
      update = @utils.actionsMapQuantity(delta, inventoryChanged)

      expected_update =
        [
          { action: 'changeQuantity', quantity: 10 }
        ]
      expect(update).toEqual expected_update

  xdescribe ':: actionsMapExpectedDelivery', ->