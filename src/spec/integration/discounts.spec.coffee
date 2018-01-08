debug = require('debug')('spec-integration:cart-discounts')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient} = require '../../lib/main'
Config = require('../../config').config

orderCount = 1

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newCartDiscount = ->
  orderCount++

  name:
    en: uniqueId 'n'
  value:
    type: 'absolute'
    money: [{currencyCode: 'EUR', centAmount: 1000}]
  cartPredicate: 'totalPrice > "800.00 EUR"'
  target:
    type: 'lineItems'
    predicate: 'variant.id = 1'
  sortOrder: "0.#{_.reduce [1..orderCount], ((m, i) -> '' + m + i), '2'}"
  isActive: false
  requiresDiscountCode: true

newDiscountCode = (cartDiscountId) ->
  code: uniqueId 'c'
  cartDiscounts: [
    {typeId: 'cart-discount', id: cartDiscountId}
  ]

describe 'Integration Cart Discounts', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config

    @client.cartDiscounts.save(newCartDiscount())
    .then (result) =>
      expect(result.statusCode).toBe 201
      discount = result.body
      @cartDiscountId = discount.id
      debug 'New cart discount created: %j', discount
      done()
    .catch (error) -> done _.prettify(error.body)

  afterEach (done) ->
    @client.discountCodes.all().fetch()
    .then (result) =>
      codes = result.body.results
      debug 'Cleaning up all discount codes'
      Promise.all _.map codes, (c) => @client.discountCodes.byId(c.id).delete(c.version)

      @client.cartDiscounts.all().fetch()
    .then (result) =>
      discounts = result.body.results
      debug 'Cleaning up all cart discounts'
      Promise.all _.map discounts, (d) => @client.cartDiscounts.byId(d.id).delete(d.version)
    .then -> done()
    .catch (error) -> done(_.prettify(error))

  it 'should update a cart discount', (done) ->
    @client.cartDiscounts.byId(@cartDiscountId).fetch()
    .then (result) =>
      expect(result.statusCode).toBe 200
      @client.cartDiscounts.byId(@cartDiscountId).update
        version: result.body.version
        actions: [
          {action: 'setValidUntil', validUntil: '2024-12-15T09:55:12+0100'}
        ]
    .then (result) ->
      expect(result.statusCode).toBe 200
      expect(result.body.validUntil).toBe '2024-12-15T08:55:12.000Z'
      done()
    .catch (error) -> done _.prettify(error.body)

  it 'should create a discount code and apply it to a cart', (done) ->
    @client.discountCodes.save(newDiscountCode(@cartDiscountId))
    .then (result) =>
      expect(result.statusCode).toBe 201
      debug 'discount code created: %j', result.body

      # now let's try to delete the cart discount
      # it should fail since it's referenced from a discount code
      @client.cartDiscounts.byId(@cartDiscountId).fetch()
    .then (result) =>
      debug 'About to delete cart discount'
      @client.cartDiscounts.byId(result.body.id).delete(result.body.version)
      .then -> done('Cart discount deletion should be rejected')
      .catch (e) ->
        expect(e.message).toBe 'Can not delete a cart-discount while it is referenced by at least one discount-code.'
        done()
    .catch (error) -> done(_.prettify(error))
