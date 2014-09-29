debug = require('debug')('spec-integration:products')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient} = require '../../lib/main'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newProductType = ->
  name: 'Clothing'
  description: 'A sample product type'

updateAttribute = (version) ->
  version: version
  actions: [
    {
      action: "addAttributeDefinition"
      attribute:
        type:
          name: "enum"
          values: [{key: "red", label: "Red"}, {key: "blue", label: "Blue"}]
        name: "color"
        label:
          en: "Color"
        attributeConstraint: "CombinationUnique"
        isRequired: true
        isSearchable: false
    },
    {
      action: "addAttributeDefinition"
      attribute:
        type:
          name: "enum"
          values: [{key: "M", label: "Medium"}, {key: "L", label: "Large"}]
        name: "size"
        label:
          en: "Size"
        attributeConstraint: "CombinationUnique"
        isRequired: true
        isSearchable: false
    }
  ]

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

updatePublish = (version) ->
  version: version
  actions: [
    {action: "publish"}
  ]

describe 'Integration Products', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config

    debug 'Creating a ProductType'
    @client.productTypes.save(newProductType())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @productType = result.body
      debug 'Creating 50 products'
      Promise.all _.map [1..50], => @client.products.save(newProduct(@productType))
    .then (results) ->
      debug "Created #{results.length} products"
      done()
    .catch (error) -> done(_.prettify(error))
  , 20000 # 20sec

  afterEach (done) ->
    debug 'Unpublishing all products'
    @client.products.sort('id').where('masterData(published = "true")').process (payload) =>
      Promise.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).update(updateUnpublish(product.version))
    .then (results) =>
      debug "Unpublished #{results.length} products"
      debug 'About to delete all products'
      @client.products.perPage(0).fetch()
    .then (payload) =>
      debug "Deleting #{payload.body.total} products"
      Promise.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).delete(product.version)
    .then (results) =>
      debug "Deleted #{results.length} products"
      debug 'About to delete all product types'
      @client.productTypes.perPage(0).fetch()
    .then (payload) =>
      debug "Deleting #{payload.body.total} product types"
      Promise.all _.map payload.body.results, (productType) =>
        @client.productTypes.byId(productType.id).delete(productType.version)
    .then (results) ->
      debug "Deleted #{results.length} product types"
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000 # 1min

  it 'should publish all products', (done) ->
    debug 'About to publish all products'
    @client.products.sort('id').where('masterData(published = "false")').process (payload) =>
      Promise.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).update(updatePublish(product.version))
    .then (results) -> done()
    .catch (error) -> done(_.prettify(error))
  , 60000 # 1min

  it 'should add attribute to product type', (done) ->
    debug 'Creating attribute definitions'
    @client.productTypes.byId(@productType.id).update(updateAttribute(@productType.version))
    .then (result) ->
      expect(result.statusCode).toBe 200
      done()
    .catch (error) -> done(_.prettify(error))
  , 30000 # 30sec
