{OrderSync} = require '../../lib/main'

OLD_ORDER =
  id: '123'
  orderState: 'Open'
  paymentState: 'Pending'
  shipmentState: 'Pending'
  version: 2

NEW_ORDER =
  id: '123'
  orderState: 'Complete'
  paymentState: 'Paid'
  shipmentState: 'Ready'
  version: 1

describe 'OrderSync', ->

  beforeEach ->
    @sync = new OrderSync

  afterEach ->
    @sync = null

  describe ':: config', ->

    it 'should build white/black-listed actions update', ->
      opts = [
        {type: 'status', group: 'white'}
        {type: 'returnInfo', group: 'black'}
      ]
      spyOn(@sync._utils, 'actionsMapReturnInfo').andReturn [{action: 'addReturnInfo', returnTrackingId: '1234', items: []}]
      update = @sync.config(opts).buildActions(NEW_ORDER, OLD_ORDER).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'changeOrderState', orderState: 'Complete' }
          { action: 'changePaymentState', paymentState: 'Paid' }
          { action: 'changeShipmentState', shipmentState: 'Ready' }
        ]
        version: OLD_ORDER.version
      expect(update).toEqual expected_update

  describe ':: buildActions', ->

    it 'should build the action update', ->
      update = @sync.buildActions(NEW_ORDER, OLD_ORDER).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'changeOrderState', orderState: 'Complete' }
          { action: 'changePaymentState', paymentState: 'Paid' }
          { action: 'changeShipmentState', shipmentState: 'Ready' }
        ]
        version: OLD_ORDER.version
      expect(update).toEqual expected_update
