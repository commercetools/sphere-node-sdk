_ = require 'underscore'
Q = require 'q'
_.mixin require('sphere-node-utils')._u
SphereClient = require '../../lib/client'
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
    @client = new SphereClient
      config: Config
      logConfig:
        levelStream: 'info'
        levelFile: 'error'
    @logger = @client._logger

    @logger.debug 'Creating a ProductType'
    @client.productTypes.save(newProductType())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @productType = result.body
      @logger.debug 'Creating 50 products'
      Q.all _.map [1..50], => @client.products.save(newProduct(@productType))
    .then (results) =>
      @logger.info "Created #{results.length} products"
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettify(error))
  , 20000 # 20sec

  afterEach (done) ->
    @logger.debug 'Unpublishing all products'
    @client.products.sort('id').where('masterData(published = "true")').process (payload) =>
      Q.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).update(updateUnpublish(product.version))
    .then (results) =>
      @logger.info "Unpublished #{results.length} products"
      @logger.debug 'About to delete all products'
      @client.products.perPage(0).fetch()
    .then (payload) =>
      @logger.debug "Deleting #{payload.body.total} products"
      Q.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).delete(product.version)
    .then (results) =>
      @logger.info "Deleted #{results.length} products"
      @logger.debug 'About to delete all product types'
      @client.productTypes.perPage(0).fetch()
    .then (payload) =>
      @logger.debug "Deleting #{payload.body.total} product types"
      Q.all _.map payload.body.results, (productType) =>
        @client.productTypes.byId(productType.id).delete(productType.version)
    .then (results) =>
      @logger.debug "Deleted #{results.length} product types"
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettify(error))
  , 60000 # 1min

  it 'should publish all products', (done) ->
    @logger.info 'About to publish all products'
    @client.products.sort('id').where('masterData(published = "false")').process (payload) =>
      Q.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).update(updatePublish(product.version))
    .then (results) ->
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettify(error))
  , 60000 # 1min

  it 'should add attribute to product type', (done) ->
    @logger.info 'Creating attribute definitions'
    @client.productTypes.byId(@productType.id).update(updateAttribute(@productType.version))
    .then (result) ->
      expect(result.statusCode).toBe 200
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettify(error))
  , 30000 # 30sec
