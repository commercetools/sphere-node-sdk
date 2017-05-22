_ = require 'underscore'
_.mixin require 'underscore-mixins'
OrderUtils = require '../../../lib/sync/utils/order'

uniqueId = (prefix = '') ->
  "#{prefix}#{new Date().getTime()}"

###
Match different order statuses
###
ORDER =
  id: '123'
  orderState: 'Open'
  paymentState: 'Pending'
  shipmentState: 'Pending'
  lineItems: [
    productId: uniqueId 'p'
    name:
      de: 'foo'
    variant:
      id: 1
    taxRate:
      name: 'myTax'
      amount: 0.10
      includedInPrice: false
      country: 'DE'
    quantity: 1
    price:
      value:
        centAmount: 999
        currencyCode: 'EUR'
  ]
  totalPrice:
    currencyCode: 'EUR'
    centAmount: 999
  returnInfo: [
    returnTrackingId: 'bla blubb'
    returnDate: new Date().toISOString()
    items: [{
      id: uniqueId 'ri'
      quantity: 11
      lineItemId: 1
      comment: 'Product doesnt have enough mojo.'
      shipmentState: 'Advised'
      paymentState: 'Initial'
    }
    {
      id: uniqueId 'ri'
      quantity: 22
      lineItemId: 2
      comment: 'Product too small.'
      shipmentState: 'Advised'
      paymentState: 'Initial'
    }
    {
      id: uniqueId 'ri'
      quantity: 33
      lineItemId: 3
      comment: 'Product too big.'
      shipmentState: 'Advised'
      paymentState: 'Initial'
    }]
  ]
  shippingInfo:
    deliveries: [{
      id: uniqueId 'di'
      items: [{
        lineItemId: 1
        quantity: 1
      }]
      parcels: [{
        id: uniqueId 'pc'
        measurements: {
          heightInMillimeter: 200
          lengthInMillimeter: 200
          widthInMillimeter: 200
          weightInGram: 200
        },
        trackingData: {
          trackingId: '1Z6185W16894827591'
          carrier: 'UPS'
          provider: 'shipcloud.io'
          providerTransaction: '549796981774cd802e9636ded5608bfa1ecce9ad'
          isReturn: true
        }
      }]
    }]

describe 'OrderUtils', ->

  beforeEach ->
    @utils = new OrderUtils
    @order = _.deepClone ORDER

  afterEach ->
    @utils = null
    @order = null

  describe ':: actionsMapStatusValues', ->

    it 'should return required actions for syncing status', ->
      orderChanged = _.deepClone @order
      orderChanged.orderState = 'Complete'
      orderChanged.paymentState = 'Paid'
      orderChanged.shipmentState = 'Ready'

      delta = @utils.diff(@order, orderChanged)
      update = @utils.actionsMapStatusValues(delta, orderChanged)

      expected_update =
        [
          { action: 'changeOrderState', orderState: orderChanged.orderState }
          { action: 'changePaymentState', paymentState: orderChanged.paymentState }
          { action: 'changeShipmentState', shipmentState: orderChanged.shipmentState }
        ]
      expect(update).toEqual expected_update

  describe ':: actionsMapReturnInfo', ->

    it 'should return required actions for syncing returnInfo', ->
      @order = _.deepClone ORDER
      orderChanged = _.deepClone ORDER

      # empty returnInfo list
      @order.returnInfo = []

      delta = @utils.diff(@order, orderChanged)
      update = @utils.actionsMapReturnInfo(delta, orderChanged)

      action = _.deepClone orderChanged.returnInfo[0]
      action.action = 'addReturnInfo'

      expect(update).toEqual [action]

    it 'should return required action for syncing shipmentState (returnInfo)', ->
      orderChanged = _.deepClone @order
      orderChanged.returnInfo[0].items[0].shipmentState = 'Returned'
      orderChanged.returnInfo[0].items[1].shipmentState = 'Unusable'

      delta = @utils.diff(@order, orderChanged)
      update = @utils.actionsMapReturnInfo(delta, orderChanged)
      expectedUpdate =
        [
          {
            action: 'setReturnShipmentState'
            returnItemId: orderChanged.returnInfo[0].items[0].id
            shipmentState: orderChanged.returnInfo[0].items[0].shipmentState
          }
          {
            action: 'setReturnShipmentState'
            returnItemId: orderChanged.returnInfo[0].items[1].id
            shipmentState: orderChanged.returnInfo[0].items[1].shipmentState
          }
        ]
      expect(update).toEqual expectedUpdate

    it 'should return required action for syncing paymentState (returnInfo)', ->
      orderChanged = _.deepClone @order
      orderChanged.returnInfo[0].items[0].paymentState = 'Refunded'
      orderChanged.returnInfo[0].items[1].paymentState = 'NotRefunded'

      delta = @utils.diff(@order, orderChanged)

      update = @utils.actionsMapReturnInfo(delta, orderChanged)
      expectedUpdate =
        [
          {
            action: 'setReturnPaymentState'
            returnItemId: orderChanged.returnInfo[0].items[0].id
            paymentState: orderChanged.returnInfo[0].items[0].paymentState
          }
          {
            action: 'setReturnPaymentState'
            returnItemId: orderChanged.returnInfo[0].items[1].id
            paymentState: orderChanged.returnInfo[0].items[1].paymentState
          }
        ]
      expect(update).toEqual expectedUpdate

    it 'should return required actions for syncing returnInfo and shipmentState', ->
      orderChanged = _.deepClone @order

      # add a 2nd returnInfo
      orderChanged.returnInfo.push
        returnTrackingId: 'bla blubb'
        returnDate: new Date().toISOString()
        items: [{
          id: uniqueId 'ri'
          quantity: 111
          lineItemId: 1
          comment: 'Product doesnt have enough mojo.'
          shipmentState: 'Advised'
          paymentState: 'Initial'
        }
        {
          id: uniqueId 'ri'
          quantity: 222
          lineItemId: 2
          comment: 'Product too small.'
          shipmentState: 'Advised'
          paymentState: 'Initial'
        }
        {
          id: uniqueId 'ri'
          quantity: 333
          lineItemId: 3
          comment: 'Product too big.'
          shipmentState: 'Advised'
          paymentState: 'Initial'
        }]

      # change shipment status of existing returnInfo
      orderChanged.returnInfo[0].items[0].shipmentState = 'Returned'
      orderChanged.returnInfo[0].items[1].shipmentState = 'Unusable'

      delta = @utils.diff(@order, orderChanged)
      update = @utils.actionsMapReturnInfo(delta, orderChanged)

      addAction = _.deepClone orderChanged.returnInfo[1]
      addAction.action = 'addReturnInfo'

      expectedUpdate =
        [
          {
            action: 'setReturnShipmentState'
            returnItemId: orderChanged.returnInfo[0].items[0].id
            shipmentState: orderChanged.returnInfo[0].items[0].shipmentState
          }
          {
            action: 'setReturnShipmentState'
            returnItemId: orderChanged.returnInfo[0].items[1].id
            shipmentState: orderChanged.returnInfo[0].items[1].shipmentState
          }
          addAction
        ]
      expect(update).toEqual expectedUpdate

  describe ':: actionsMapDeliveries', ->

    it 'should return addDelivery action when syncing deliveries', ->
      orderChanged = _.deepClone ORDER

      # empty deliveries list
      delete @order.shippingInfo.deliveries

      delta = @utils.diff(@order, orderChanged)
      update = @utils.actionsMapDeliveries(delta, orderChanged, @order)

      action = _.deepClone(orderChanged.shippingInfo.deliveries[0])
      action.action = "addDelivery"

      expect(update).toEqual [action]

    it 'should return addParcelToDelivery action when syncing parcels (deliveries)', ->
      orderChanged = _.deepClone ORDER

      parcel =
        id: uniqueId 'pc'
        measurements:
          heightInMillimeter: 200
          lengthInMillimeter: 200
          widthInMillimeter: 200
          weightInGram: 200
        trackingData:
          trackingId: '1Z6185W16894827591'
          carrier: 'UPS'
          provider: 'shipcloud.io'
          providerTransaction: '549796981774cd802e9636ded5608bfa1ecce9ad'
          isReturn: true

      # add another parcel
      orderChanged.shippingInfo.deliveries[0].parcels.push parcel

      delta = @utils.diff(@order, orderChanged)
      update = @utils.actionsMapDeliveries(delta, orderChanged, @order)

      expectedUpdate = _.deepClone parcel
      expectedUpdate.action = 'addParcelToDelivery'
      expectedUpdate.deliveryId = orderChanged.shippingInfo.deliveries[0].id

      expect(update).toEqual [expectedUpdate]

    it 'should add delivery when old deliveries are not provided', ->
      newOrder = _.deepClone ORDER
      newDelivery =
        id: uniqueId 'new'
        items: [
          lineItemId: 2
          quantity: 10
        ]
      newOrder.shippingInfo.deliveries = [newDelivery]

      delta = @utils.diff(@order, newOrder)
      update = @utils.actionsMapDeliveries(delta, newOrder, @order)

      action = _.deepClone(newDelivery)
      action.action = "addDelivery"

      expect(update).toEqual [action]

    it 'should add parcel when old parcels are not provided', ->
      newOrder = _.deepClone ORDER
      newParcel =
        id: uniqueId 'newParcel'
        trackingData:
          trackingId: uniqueId 'newTrackingId'
      newOrder.shippingInfo.deliveries[0].parcels = [newParcel]

      delta = @utils.diff(@order, newOrder)
      update = @utils.actionsMapDeliveries(delta, newOrder, @order)

      action = _.deepClone(newParcel)
      action.action = "addParcelToDelivery"
      action.deliveryId = newOrder.shippingInfo.deliveries[0].id
      expect(update).toEqual [action]

    it 'should generate no update actions when there are no changes', ->
      newOrder = _.deepClone ORDER
      delta = @utils.diff(@order, newOrder)
      update = @utils.actionsMapDeliveries(delta, newOrder, @order)
      expect(update.length).toBe 0

    it 'should process new deliveries and parcels in a wrong order', ->
      oldOrder =
        shippingInfo:
          deliveries: [{
            id: 'old-delivery-1'
            createdAt: '2017-05-22T07:33:02.202Z'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 100
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
              quantity: 200
            ]
            parcels: [
              id: 'old-parcel'
              createdAt: '2017-05-22T07:33:02.202Z'
              trackingData:
                trackingId: '447883009643'
                carrier: 'dhl'
                isReturn: false
            ]
          }, {
            id: 'old-delivery-3'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 300
            ]
            parcels: [
              id: 'parcel-300'
            ]
          }]

      newOrder =
        shippingInfo:
          deliveries: [{
            id: 'old-delivery-3'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 300
            ]
            parcels: [
              id: 'parcel-300'
            ]
          }, {
            id: 'new-delivery'
            items: [
              id: '4dc17170-30ad-4b95-9a83-1388b40f5a1e'
              quantity: 100
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
          }, {
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
          }]

      delta = @utils.diff(oldOrder, newOrder)
      actions = @utils.actionsMapDeliveries(delta, newOrder, oldOrder)

      expect(actions.length).toBe 2
      action = actions[0]
      expect(action.action).toBe('addDelivery')
      expect(action.id).toBe('new-delivery')

      action = actions[1]
      expect(action.action).toBe('addParcelToDelivery')
      expect(action.deliveryId).toBe('old-delivery-2')
      expect(action.id).toBe('new-parcel')

