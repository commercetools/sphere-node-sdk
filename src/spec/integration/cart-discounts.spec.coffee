debug = require('debug')('spec-integration:cart-discounts')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient} = require '../../lib/main'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newCartDiscount = ->
  name:
    en: uniqueId 'n'
  value:
    type: 'absolute'
    money: [{currencyCode: 'EUR', centAmount: 1000}]
  cartPredicate: 'totalPrice > "800.00 EUR"'
  target:
    type: 'lineItems'
    predicate: 'variant.id = 1'
  sortOrder: '0.1'

describe 'Integration Cart Discounts', ->

  beforeEach ->
    @client = new SphereClient config: Config

  afterEach (done) ->
    @client.cartDiscounts.all().fetch()
    .then (result) =>
      discounts = result.body.results
      debug 'Cleaning up all cart discounts'
      Promise.all _.map discounts, (d) => @client.cartDiscounts.byId(d.id).delete(d.version)
    .then -> done()
    .catch (error) -> done(_.prettify(error))

  it 'should create a cart discount', (done) ->
    @client.cartDiscounts.save(newCartDiscount())
    .then (result) ->
      expect(result.statusCode).toBe 201
      discount = result.body
      debug 'New cart discount created: %j', discount
      done()
    .catch (error) -> done _.prettify(error.body)
