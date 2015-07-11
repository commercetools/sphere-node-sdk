debug = require('debug')('spec-integration:products')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, ProductSync} = require '../../lib/main'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newProductType = ->
  name: 'Clothing'
  description: 'A sample product type'

newProduct = (pType) ->
  name:
    en: uniqueId 'product'
  slug:
    en: uniqueId 'slug'
  productType:
    id: pType.id
    typeId: 'product-type'

updateUnpublish = (version) ->
  version: version
  actions: [
    {action: "unpublish"}
  ]

describe 'Integration Products Sync', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config
    @sync = new ProductSync

    debug 'Creating a ProductType'
    @client.productTypes.save(newProductType())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @productType = result.body
      done()
    .catch (error) -> done(_.prettify(error))

  afterEach (done) ->
    debug 'Unpublishing all products'
    @client.products.sort('id').where('masterData(published = "true")').process (payload) =>
      Promise.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).update(updateUnpublish(product.version))
    .then (results) =>
      debug "Unpublished #{results.length} products"
      debug 'About to delete all products'
      @client.products.all().fetch()
    .then (payload) =>
      debug "Deleting #{payload.body.total} products"
      Promise.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).delete(product.version)
    .then (results) =>
      debug "Deleted #{results.length} products"
      debug 'About to delete all product types'
      @client.productTypes.all().fetch()
    .then (payload) =>
      debug "Deleting #{payload.body.total} product types"
      Promise.all _.map payload.body.results, (productType) =>
        @client.productTypes.byId(productType.id).delete(productType.version)
    .then (results) ->
      debug "Deleted #{results.length} product types"
      done()
    .catch (error) -> done(_.prettify(error.body))
  , 60000 # 1min

  it 'should create and sync product', (done) ->
    pName = uniqueId('Foo')
    pSlug = uniqueId('foo')
    OLD_PROD =
      productType:
        id: @productType.id
        typeId: 'product-type'
      name: {en: pName}
      slug: {en: pSlug}
      description: {en: 'A foo product'}
      metaTitle: {en: 'The Foo'}
      metaDescription: {en: 'The Foo product'}
      masterVariant:
        sku: 'v0'
        prices: [
          {value: {centAmount: 1000, currencyCode: 'EUR'}, country: 'DE'}
        ]
      variants: [
        {
          sku: 'v1'
          prices: [
            {value: {centAmount: 2000, currencyCode: 'USD'}}
          ]
        }
      ]

    NEW_PROD =
      productType:
        id: @productType.id
        typeId: 'product-type'
      name: {de: pName}
      slug: {de: pSlug}
      description: {de: 'A foo product'}
      metaTitle: {de: 'The Foo'}
      metaDescription: {de: 'The Foo product'}
      masterVariant:
        id: 1
        sku: 'v0'
        prices: [
          {value: {centAmount: 1500, currencyCode: 'EUR'}, country: 'DE'}
          {value: {centAmount: 1500, currencyCode: 'EUR'}, country: 'IT'}
        ]
      variants: [
        {
          id: 2
          sku: 'v1'
          prices: [
            {value: {centAmount: 2000, currencyCode: 'USD'}}
          ]
        },
        {
          sku: 'v2'
          prices: [
            {value: {centAmount: 3000, currencyCode: 'EUR'}, country: 'FR'}
          ]
        }
      ]

    debug 'Create initial product to be synced'
    @client.products.create(OLD_PROD)
    .then (result) =>
      debug 'Fetch projection of created product'
      @client.productProjections.byId(result.body.id).staged(true).fetch()
    .then (result) =>
      syncedActions = @sync.buildActions(NEW_PROD, result.body)
      expect(syncedActions.shouldUpdate()).toBe true
      updatePayload = syncedActions.getUpdatePayload()
      debug 'About to update product with synced actions'
      @client.products.byId(syncedActions.getUpdateId()).update(updatePayload)
    .then (result) =>
      debug 'Fetch projection of updated product'
      @client.productProjections.byId(result.body.id).staged(true).fetch()
    .then (result) ->
      updated = result.body
      expect(updated.name).toEqual {de: pName}
      expect(updated.slug).toEqual {de: pSlug}
      expect(updated.description).toEqual {de: 'A foo product'}
      expect(updated.metaTitle).toEqual {de: 'The Foo'}
      expect(updated.metaDescription).toEqual {de: 'The Foo product'}
      expect(updated.masterVariant.prices[0].value.centAmount).toBe 1500
      expect(updated.masterVariant.prices[1].value.centAmount).toBe 1500
      expect(updated.masterVariant.prices[1].country).toBe 'IT'
      expect(updated.variants[0].sku).toBe 'v1'
      expect(updated.variants[0].prices[0].value.centAmount).toBe 2000
      expect(updated.variants[1].sku).toBe 'v2'
      expect(updated.variants[1].prices[0].value.centAmount).toBe 3000
      expect(updated.variants[1].prices[0].country).toBe 'FR'
      done()
    .catch (error) -> done(_.prettify(error))
  , 10000 # 10sec
