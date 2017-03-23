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
  masterVariant:
    sku: uniqueId 'sku-'

newProductWithSearchKeywords = (pType) ->
  _.extend newProduct(pType),
    searchKeywords:
      en: [
        {text: 'Multi tool'}
        {text: 'Swiss Army Knife', suggestTokenizer: {type: 'whitespace'}}
      ]
      de: [
        {text: 'Schweizer Messer', suggestTokenizer: {type: 'custom', inputs: ['schweizer messer', 'offiziersmesser', 'sackmesser']}}
      ]

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
    .catch (error) -> done(_.prettify(error))
  , 60000 # 1min

  it 'should publish all products', (done) ->
    debug 'About to publish all products'
    @client.products.sort('id')
    .where('masterData(published = "false")')
    .where('masterData(hasStagedChanges = "true")')
    .whereOperator('or')
    .process (payload) =>
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

  it 'should use reference expansion when creating and updating a product', (done) ->
    @client.products.expand('productType').create newProduct(@productType)
    .then (result) =>
      expect(result.body.productType.hasOwnProperty('obj')).toBe(true)
      @client.products.expand('productType').byId(result.body.id).update updatePublish(result.body.version)
    .then (result) ->
      expect(result.body.productType.hasOwnProperty('obj')).toBe(true)
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000 # 60sec

  # it 'should search for suggestions', (done) ->
  #   debug 'Creating products with search keywords'
  #   Promise.all _.map [1..5], => @client.products.save(newProductWithSearchKeywords(@productType))
  #
  #   _suggest = (text, lang, expectedResult) =>
  #     new Promise (resolve, reject) =>
  #       debug 'searching for %s', text
  #       @client.productProjections
  #       .staged(true)
  #       .searchKeywords(text, lang)
  #       .suggest()
  #       .then (result) ->
  #         expect(result.statusCode).toBe 200
  #         expect(result.body["searchKeywords.#{lang}"]).toEqual expectedResult
  #         resolve()
  #       .catch (e) -> reject e
  #
  #   # let's wait a bit to give ES time to create the index
  #   setTimeout ->
  #     Promise.all [
  #       _suggest('multi', 'en', [text: 'Multi tool'])
  #       _suggest('tool', 'en', [])
  #       _suggest('kni', 'en', [text: 'Swiss Army Knife'])
  #       _suggest('offiz', 'de', [text: 'Schweizer Messer'])
  #     ]
  #     .then -> done()
  #     .catch (error) -> done(_.prettify(error))
  #   , 5000 # 5sec
  # , 30000 # 30sec
  #
  # it "should query using 'byQueryString'", (done) ->
  #   slugToLookFor = 'this-is-what-we-are-looking-for'
  #   # let's create a special product that we can securely query for
  #   @client.products.save(_.extend newProduct(@productType), {slug: {en: slugToLookFor}, masterVariant: {sku: '01234'}})
  #
  #   # let's wait a bit to give ES time to create the index
  #   setTimeout =>
  #     # query for limit
  #     @client.productProjections.byQueryString('limit=3&staged=true', true).fetch()
  #     .then (result) =>
  #       expect(result.body.count).toBe 3
  #
  #       # query for slug
  #       @client.productProjections.byQueryString("where=slug(en = \"#{slugToLookFor}\")&staged=true", false).fetch()
  #     .then (result) =>
  #       expect(result.body.count).toBe 1
  #       expect(result.body.results[0].slug.en).toBe slugToLookFor
  #
  #       # search for sku
  #       @client.productProjections.byQueryString("text.en=01234&staged=true", false).search()
  #     .then (result) ->
  #       expect(result.body.count).toBe 1
  #       expect(result.body.results[0].slug.en).toBe slugToLookFor
  #       done()
  #     .catch (error) -> done(_.prettify(error))
  #   , 5000 # 5sec
  # , 20000 # 20sec
  #
  # it 'should uses search endpoint', (done) ->
  #   slugToLookFor = 'this-is-what-we-are-looking-for'
  #   # let's create a special product that we can securely search for
  #   @client.products.save(_.extend newProduct(@productType), {slug: {en: slugToLookFor}})
  #
  #   # let's wait a bit to give ES time to create the index
  #   setTimeout =>
  #     @client.productProjections.text('sku', 'en').staged(true).perPage(80).search()
  #     .then (result) =>
  #       expect(result.body.count).toBeGreaterThan 50
  #       expect(result.body.results.length).toBeGreaterThan 50
  #
  #       @client.productProjections.text(slugToLookFor, 'en').staged(true).search()
  #     .then (result) ->
  #       expect(result.body.count).toBe 1
  #       expect(result.body.results[0].slug.en).toBe slugToLookFor
  #       done()
  #     .catch (error) -> done(_.prettify(error))
  #   , 5000 # 5sec
  # , 20000 # 20sec
  #
  # it 'should search with full-text for special characters', (done) ->
  #   specialChar = 'äöüß'
  #   @client.products.save(_.extend newProduct(@productType), {name: {en: specialChar}})
  #
  #   # let's wait a bit to give ES time to create the index
  #   setTimeout =>
  #     @client.productProjections
  #     .text(specialChar, 'en')
  #     .staged(true)
  #     .perPage(1)
  #     .search()
  #     .then (result) =>
  #       expect(result.body.count).toBe 1
  #       expect(result.body.results[0].name.en).toBe specialChar
  #       done()
  #     .catch (error) -> done(_.prettify(error))
  #   , 5000 # 5sec
  # , 20000 # 20sec
