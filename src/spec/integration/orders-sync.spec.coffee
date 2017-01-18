debug = require('debug')('spec-integration:orders')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
{SphereClient, OrderSync} = require '../../lib/main'
Config = require('../../config').config

describe 'Integration Orders Sync', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config
    @sync = new OrderSync

    # get a tax category required for setting up shippingInfo (simply returning first found)
    @client.taxCategories.create(taxCategoryMock())
    .then (result) =>
      @taxCategory = result.body
      @client.zones.create(zoneMock())
    .then (result) =>
      @zone = result.body
      @client.shippingMethods.create(shippingMethodMock(@zone, @taxCategory))
    .then (result) =>
      @shippingMethod = result.body
      @client.productTypes.create(productTypeMock())
    .then (result) =>
      @productType = result.body
      @client.products.create(productMock(@productType))
    .then (result) =>
      @product = result.body
      @client.orders.import(orderMock(@shippingMethod, @product, @taxCategory))
    .then (result) =>
      @order = result.body
      done()
    .catch (error) -> done(_.prettify(error))

  afterEach (done) ->
    # TODO: delete order (not supported by API yet)
    @client.products.byId(@product.id).delete(@product.version)
    .then (result) =>
      @client.productTypes.byId(@productType.id).delete(@productType.version)
    .then (result) -> done()
    .catch (error) -> done(_.prettify(error))
    .finally =>
      @product = null
      @productType = null
      @order = null

  it 'should sync order statuses', (done) ->
    orderNew = _.deepClone @order

    orderNew.orderState = 'Complete'
    orderNew.paymentState = 'Paid'
    orderNew.shipmentState = 'Ready'

    syncedActions = @sync.buildActions(orderNew, @order)
    debug 'About to update order with synced actions (statuses)'
    @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      orderUpdated = result.body
      expect(orderUpdated).toBeDefined()
      expect(orderUpdated.orderState).toBe orderNew.orderState
      expect(orderUpdated.paymentState).toBe orderNew.paymentState
      expect(orderUpdated.shipmentState).toBe orderNew.shipmentState
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000


  it 'should sync returnInfo', (done) ->
    orderNew = _.deepClone @order

    orderNew.returnInfo.push
      returnTrackingId: '1'
      returnDate: new Date()
      items: [{
        quantity: 1
        lineItemId: @order.lineItems[0].id
        comment: 'Product doesnt have enough mojo.'
        shipmentState: 'Advised'
      }]

    syncedActions = @sync.buildActions(orderNew, @order)
    debug 'About to update order with synced actions (returnInfo)'
    @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      orderUpdated = result.body
      expect(orderUpdated).toBeDefined()
      expect(orderUpdated.returnInfo[0].id).toBe orderNew.returnInfo[0].id
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000

  it 'should sync returnInfo (status)', (done) ->
    orderNew = _.deepClone @order

    orderNew.returnInfo.push
      returnTrackingId: 'bla blubb'
      returnDate: new Date()
      items: [{
        quantity: 1
        lineItemId: @order.lineItems[0].id
        comment: 'Product doesnt have enough mojo.'
        shipmentState: 'Returned'
      }]

    # prepare order: add returnInfo first
    syncedActions = @sync.buildActions(orderNew, @order)
    debug 'About to update order with synced actions (returnInfo added)'
    @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) =>
      orderUpdated = result.body
      @orderNew2 = _.deepClone orderUpdated

      @orderNew2.returnInfo[0].items[0].shipmentState = 'BackInStock'
      @orderNew2.returnInfo[0].items[0].paymentState = 'Refunded'

      # update returnInfo status
      syncedActions = @sync.buildActions(@orderNew2, orderUpdated)
      debug 'About to update order with synced actions (returnInfo status)'
      @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) =>
      expect(result.statusCode).toBe 200
      orderUpdated2 = result.body

      expect(orderUpdated2).toBeDefined()
      expect(orderUpdated2.returnInfo[0].items[0].shipmentState).toEqual @orderNew2.returnInfo[0].items[0].shipmentState
      expect(orderUpdated2.returnInfo[0].items[0].paymentState).toEqual @orderNew2.returnInfo[0].items[0].paymentState
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000

  it 'should sync delivery items', (done) ->

    orderNew = _.deepClone @order

    # add one delivery item
    orderNew.shippingInfo.deliveries = [
      items: [{
         id: orderNew.lineItems[0].id
         quantity: 1
      }]]

    syncedActions = @sync.buildActions(orderNew, @order)
    debug 'About to update order with synced actions (deliveries)'
    @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      orderUpdated = result.body

      expect(orderUpdated).toBeDefined()
      expect(orderUpdated.shippingInfo.deliveries.length).toBe 1
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000

  it 'should sync parcel items of a delivery', (done) ->
    orderNew = _.deepClone @order

    # add one delivery item
    orderNew.shippingInfo.deliveries = [
      items: [{
         id: orderNew.lineItems[0].id
         quantity: 1
      }]]

    syncedActions = @sync.buildActions(orderNew, @order)
    debug 'About to update order with synced actions (delivery added)'
    @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) =>
      expect(result.statusCode).toBe 200
      orderUpdated = result.body

      orderNew2 = _.deepClone orderUpdated

      # add a parcel item
      orderNew2.shippingInfo.deliveries[0].parcels = [{
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

      # sync first parcel
      syncedActions = @sync.buildActions(orderNew2, orderUpdated)
      debug 'About to update order with synced actions (1st parcel)'
      @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) =>
      expect(result.statusCode).toBe 200
      orderUpdated2 = result.body

      orderNew3 = _.deepClone orderUpdated2

      # add a parcel item
      orderNew3.shippingInfo.deliveries[0].parcels.push {}

      # sync a second parcel
      syncedActions = @sync.buildActions(orderNew3, orderUpdated2)
      debug 'About to update order with synced actions (2nd parcel)'
      @client.orders.byId(syncedActions.getUpdateId()).update(syncedActions.getUpdatePayload())
    .then (result) ->
      expect(result.statusCode).toBe 200
      orderUpdated3 = result.body

      expect(orderUpdated3).toBeDefined()
      parcels = _.first(orderUpdated3.shippingInfo.deliveries).parcels
      expect(parcels.length).toBe 2
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000
###
helper methods
###

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

shippingMethodMock = (zone, taxCategory) ->
  name: uniqueId 'sm'
  zoneRates: [{
    zone:
      typeId: 'zone'
      id: zone.id
    shippingRates: [{
      price:
        currencyCode: 'EUR'
        centAmount: 99
      }]
    }]
  isDefault: false
  taxCategory:
    typeId: 'tax-category'
    id: taxCategory.id


zoneMock = ->
  name: uniqueId 'z'

taxCategoryMock = ->
  name: uniqueId 'tc'
  rates: [{
      name: "5%",
      amount: 0.05,
      includedInPrice: false,
      country: "DE",
      id: "jvzkDxzl"
    }]

productTypeMock = ->
  name: uniqueId 'pt'
  description: 'bla'

productMock = (productType) ->
  productType:
    typeId: 'product-type'
    id: productType.id
  name:
    en: uniqueId 'pname'
  slug:
    en: uniqueId 'pslug'
  masterVariant:
    sku: uniqueId 'sku'

orderMock = (shippingMethod, product, taxCategory) ->
  orderState: 'Open'
  paymentState: 'Pending'
  shipmentState: 'Pending'

  lineItems: [ {
    productId: product.id
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
  } ]
  totalPrice:
    currencyCode: 'EUR'
    centAmount: 999
  returnInfo: []
  shippingInfo:
    shippingMethodName: 'UPS'
    price:
      currencyCode: 'EUR'
      centAmount: 99
    shippingRate:
      price:
        currencyCode: 'EUR'
        centAmount: 99
    taxRate: _.first taxCategory.rates
    taxCategory:
      typeId: 'tax-category'
      id: taxCategory.id
    shippingMethod:
      typeId: 'shipping-method'
      id: shippingMethod.id
