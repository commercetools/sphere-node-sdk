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

    it 'should add new delivery and parcel', () ->
      oldOrder =
        shippingInfo:
          deliveries: [{
            id: 'old-delivery-1'
            createdAt: '2017-05-22T07:33:02.202Z'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 9001
            ]
            parcels: [
              id: 'parcel-123'
              trackingData:
                trackingId: '1111'
                carrier: 'PPL'
                isReturn: true
            ]
          }, {
            id: 'old-delivery-2'
            createdAt: '2017-05-22T07:33:02.202Z'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 9001
            ]
            parcels: [
              id: 'old-parcel'
              createdAt: '2017-05-22T07:33:02.202Z'
              trackingData:
                trackingId: '447883009643'
                carrier: 'dhl'
                isReturn: false
            ]
          }]

      newOrder =
        shippingInfo:
          deliveries: [{
            id: 'old-delivery-1'
            createdAt: '2017-05-22T07:33:02.202Z'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 9001
            ]
            parcels: [
              id: 'parcel-123'
              trackingData:
                trackingId: '1111'
                carrier: 'PPL'
                isReturn: true
            ]
          }, {
            id: 'new-delivery'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 100
            ]
            parcels: [
              id: 'new-delivery-parcel'
              trackingData:
                trackingId: '123456789'
                carrier: 'TEST'
                provider: 'provider 1'
                providerTransaction: 'provider transaction 1'
                isReturn: false
              measurements:
                lengthInMillimeter: 100
                heightInMillimeter: 200
                widthInMillimeter: 200
                weightInGram: 500
            ]
          }, {
            id: 'old-delivery-2'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 9001
            ]
            parcels: [{
              id: 'new-parcel'
              trackingData:
                trackingId: '123456789'
                carrier: 'DHL'
                provider: 'provider'
                providerTransaction: 'transaction provider'
                isReturn: false
              measurements:
                lengthInMillimeter: 100
                heightInMillimeter: 200
                widthInMillimeter: 200
                weightInGram: 500
            }, {
              id: 'old-parcel'
              createdAt: '2017-05-22T07:33:02.202Z'
              trackingData:
                trackingId: '447883009643'
                carrier: 'dhl'
                isReturn: false
            }]
          }]

      update = @sync.buildActions(newOrder, oldOrder).getUpdatePayload()
      expect(update.actions.length).toBe 2

      action = update.actions[0]
      expect(action.action).toBe('addDelivery')
      expect(action.id).toBe('new-delivery')

      action = update.actions[1]
      expect(action.action).toBe('addParcelToDelivery')
      expect(action.deliveryId).toBe('old-delivery-2')
      expect(action.id).toBe('new-parcel')
    , 60000
