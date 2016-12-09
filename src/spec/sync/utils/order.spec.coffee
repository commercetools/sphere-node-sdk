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
    id: 'watwatwat'
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
    state: [
      {
        quantity: 3,
        state: {
          typeId: 'state',
          id: 'HL3'
        }
      },
      {
        quantity: 1,
        state: {
          typeId: 'state',
          id: 'PBJ'
        }
      }
    ]
    price:
      value:
        centAmount: 999
        currencyCode: 'EUR'
  ]
  customLineItems: [ {
    id: 'hello'
    name:
      nl: '53 65 6c 77 79 6e'
    quantity: 4
    money:
      currencyCode: 'CHF'
      centAmount: 2938
    slug: 'het is een slak'
    state: [
      {
        quantity: 3,
        state: {
          typeId: 'state'
          id: '67 72 65 65 74 73'
        }
      },
      {
        quantity: 1,
        state: {
          typeId: 'state'
          id: '79 6f 75'
        }
      }
    ]
  } ]
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

    it 'should return required actions for syncing deliveries', ->

      orderChanged = _.deepClone ORDER

      # empty deliveries list
      @order.shippingInfo.deliveries = []

      delta = @utils.diff(@order, orderChanged)
      update = @utils.actionsMapDeliveries(delta, orderChanged)

      action = _.deepClone(orderChanged.shippingInfo.deliveries[0])
      action.action = "addDelivery"

      expect(update).toEqual [action]

    it 'should return required action for syncing parcels (deliveries)', ->

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
      update = @utils.actionsMapDeliveries(delta, orderChanged)

      expectedUpdate = _.deepClone parcel
      expectedUpdate.action = 'addParcelToDelivery'
      expectedUpdate.deliveryId = orderChanged.shippingInfo.deliveries[0].id

      expect(update).toEqual [expectedUpdate]
      
  describe ':: actionsMapLineItems', ->

    it 'should return required actions for syncing lineItem state', ->
      orderChanged = _.deepClone @order
      orderChanged.lineItems[0].state = [
        {
          quantity: 1,
          fromState: {
            typeId: 'state',
            id: 'HL3'
          },
          toState: {
            typeId: 'state',
            id: 'PBJ'
          },
        }
      ]

      delta = @utils.diff(@order, orderChanged)
      actions = @utils.actionsMapLineItems(delta, orderChanged)

      expectedActions =  [
          {
              action: 'transitionLineItemState',
              lineItemId: 'watwatwat',
              quantity: 1,
              fromState: {
                  typeId: 'state',
                  id: 'HL3'
              },
              toState: {
                  typeId: 'state',
                  id: 'PBJ'
              }
          }
      ]

      expect(actions).toEqual expectedActions

    it 'should return required actions for syncing lineItem state with actualTransitionDate', ->
      orderChanged = _.deepClone @order
      orderChanged.lineItems[0].state = [
        {
          quantity: 1,
          fromState: {
            typeId: 'state',
            id: 'HL3'
          },
          toState: {
            typeId: 'state',
            id: 'PBJ'
          },
          actualTransitionDate: '2000NEIN'
        }
      ]

      delta = @utils.diff(@order, orderChanged)
      actions = @utils.actionsMapLineItems(delta, orderChanged)

      expectedActions =  [
          {
              action: 'transitionLineItemState',
              lineItemId: 'watwatwat',
              quantity: 1,
              fromState: {
                  typeId: 'state',
                  id: 'HL3'
              },
              toState: {
                  typeId: 'state',
                  id: 'PBJ'
              },
              actualTransitionDate: '2000NEIN'
          }
      ]

      expect(actions).toEqual expectedActions

    it 'should ignore data without from or to state', ->
      orderChanged = _.deepClone @order

      delta = @utils.diff(@order, orderChanged)
      actions = @utils.actionsMapLineItems(delta, orderChanged)

      expectedActions =  []

      expect(actions).toEqual expectedActions

  describe ':: actionsMapCustomLineItems', ->

    it 'should return required actions for syncing customLineItem state', ->
      orderChanged = _.deepClone @order
      orderChanged.customLineItems[0].state = [
        {
          quantity: 1,
          fromState: {
            typeId: 'state',
            id: 'HL3'
          },
          toState: {
            typeId: 'state',
            id: 'PBJ'
          },
        }
      ]

      delta = @utils.diff(@order, orderChanged)
      actions = @utils.actionsMapCustomLineItems(delta, orderChanged)

      expectedActions =  [
          {
              action: 'transitionCustomLineItemState',
              customLineItemId: 'hello',
              quantity: 1,
              fromState: {
                  typeId: 'state',
                  id: 'HL3'
              },
              toState: {
                  typeId: 'state',
                  id: 'PBJ'
              }
          }
      ]

      expect(actions).toEqual expectedActions

    it 'should return required actions for syncing customLineItem state with actualTransitionDate', ->
      orderChanged = _.deepClone @order
      orderChanged.lineItems[0].state = [
        {
          quantity: 1,
          fromState: {
            typeId: 'state',
            id: 'HL3'
          },
          toState: {
            typeId: 'state',
            id: 'PBJ'
          },
          actualTransitionDate: '2000NEIN'
        }
      ]

      delta = @utils.diff(@order, orderChanged)
      actions = @utils.actionsMapLineItems(delta, orderChanged)

      expectedActions =  [
          {
              action: 'transitionLineItemState',
              lineItemId: 'watwatwat',
              quantity: 1,
              fromState: {
                  typeId: 'state',
                  id: 'HL3'
              },
              toState: {
                  typeId: 'state',
                  id: 'PBJ'
              },
              actualTransitionDate: '2000NEIN'
          }
      ]

      expect(actions).toEqual expectedActions

    it 'should ignore data without from or to state', ->
      orderChanged = _.deepClone @order

      delta = @utils.diff(@order, orderChanged)
      actions = @utils.actionsMapLineItems(delta, orderChanged)

      expectedActions =  []

      expect(actions).toEqual expectedActions
