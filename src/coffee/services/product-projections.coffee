debug = require('debug')('sphere-client')
_ = require 'underscore'
BaseService = require './base'

# Public: Define a `ProductProjectionService` to interact with the HTTP [`product-projections`](http://dev.sphere.io/http-api-projects-products.html) endpoint.
# A [`ProductProjection`](http://dev.sphere.io/http-api-projects-products.html#product-projection) is a representation
# of a the `current` or `staged` version of a product (**only GET requests**).
#
# _Products are the sellable goods in an e-commerce project on SPHERE.IO.
# This document explains some design concepts of products on SPHERE.IO and describes the available HTTP APIs for working with them._
#
# Examples
#
#   service = client.productProjections
#   service.where('name(en = "Foo")').staged(true).fetch()
class ProductProjectionService extends BaseService

  # Internal: {String} The HTTP endpoint for `ProductProjections`
  @baseResourceEndpoint: '/product-projections'

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

  # Private: Get products Projection default query params
  _getProductsProjectionDefault: ->
    JSON.parse JSON.stringify(
      fuzzy: false
      staged: false
      filter: []
      filterByQuery: []
      filterByFacets: []
      facet: []
      searchKeywords: []
      priceCurrency: false
      priceCountry: false
      priceCustomerGroup: false
      priceChannel: false
    )

  # Private: Reset default query/search params used to build request endpoints
  _setDefaults: ->
    super()
    _.extend @_params.query, @_getProductsProjectionDefault()

    @_params.encoded = @_params.encoded.concat(['filter', 'filter.query', 'filter.facets', 'facets', 'searchKeywords'])
    @_params.plain = @_params.plain.concat(['staged', 'fuzzy', 'priceCurrency', 'priceCountry', 'priceCustomerGroup', 'priceChannel'])

  # Public: Define whether to query for staged or current product projection.
  #
  # staged - {Boolean} `true` to query `staged` products (default), `false` to query `current` (published) products
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.byId('123').staged(false).fetch()
  staged: (staged = true) ->
    @_params.query.staged = staged
    debug 'setting staged: %s', staged
    this

  # Public: Define whether to perform a fuzzy search or not.
  #
  # fuzzy - {Boolean} `true` to do a fuzzy search, `false` to do a more prcise search
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.text('Sapphure', 'en').fuzzy(true).search() // will find product with SAPPHIRE as its name
  fuzzy: (fuzzy = true) ->
    @_params.query.fuzzy = fuzzy
    debug 'setting fuzzy: %s', fuzzy
    this

  # Public: Define the text to analyze and ([full-text](http://dev.sphere.io/http-api-projects-products-search.html#search-text)) search.
  #
  # text - {String} The string to search for
  # language - {String} An ISO language tag, used for search the given text in localized product content
  #
  # Throws an {Error} if `language` is missing
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.text('Red Shirt', 'en').search()
  text: (text, language) ->
    throw new Error 'Language parameter is required for searching' unless language
    @_params.query.text =
      lang: language
      value: encodeURIComponent(text)
    debug 'setting text.%s: %s', language, text
    this

  # Public: Define a [filter](http://dev.sphere.io/http-api-projects-products-search.html#search-filters)
  # used for filtering searched product projections.
  #
  # The `filter` parameter applies a filter to the query results _after_ facets have been calculated.
  # Filter in this scope doesn't influence facet counts.
  #
  # filter - {String} A filter expression
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.filter('variants.price.centAmount:1000').search()
  #
  #   # you can also chain multiple filter expressions
  #   service = client.productProjections
  #   service
  #   .filter('categories.id:"111"')
  #   .filter('variants.price.centAmount:range (0 to 999), (2000 to 10000)')
  #   .filter('variants.attributes.color.key:"red"')
  #   .search()
  filter: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_params.query.filter.push encodedFilter
    debug 'setting filter: %s', filter
    this

  # Public: Define a [filter](http://dev.sphere.io/http-api-projects-products-search.html#search-filters)
  # used for filtering searched product projections.
  #
  # The `filter.query` parameter applies a filter to the query results _before_ facets have been calculated.
  # Filter in this scope does influence facet counts. If facets are not used, this scope should be preferred over `filter`.
  #
  # filter - {String} A filter expression
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.filterByQuery('categories.id:"123"').search()
  #
  #   # you can also chain multiple filter expressions
  #   service = client.productProjections
  #   service
  #   .filterByQuery('variants.price.centAmount:1500')
  #   .filterByQuery('variants.attributes.color.key:"red"')
  #   .search()
  filterByQuery: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_params.query.filterByQuery.push encodedFilter
    debug 'setting filter.query: %s', filter
    this

  # Public: Define a [filter](http://dev.sphere.io/http-api-projects-products-search.html#search-filters)
  # used for filtering searched product projections.
  #
  # The `filter.facets` parameter applies a filter to all facet calculations (but not query results),
  # except for those facets that operate on the exact same field as the filter.
  # This behavior in combination with the `filter` scope enables multi-select faceting.
  #
  # filter - {String} A filter expression
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.filterByFacets('variants.attributes.foo:"bar"').search()
  #
  #   # you can also chain multiple filter expressions
  #   service = client.productProjections
  #   service
  #   .filterByFacets('variants.price.centAmount:1500')
  #   .filterByFacets('variants.attributes.color.key:"red"')
  #   .search()
  filterByFacets: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_params.query.filterByFacets.push encodedFilter
    debug 'setting filter.facets: %s', filter
    this

  # Public: Define a [facet](http://dev.sphere.io/http-api-projects-products-search.html#search-facets)
  # used for calculating statistical counts for searched product projections.
  #
  # facet - {String} A facet expression
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.facet('categories.id:"123"').search()
  #
  #   # you can also chain multiple facet expressions
  #   service = client.productProjections
  #   service
  #   .facet('categories.id:"123"')
  #   .facet('variants.attributes.foo:"bar"')
  #   .facet('variants.attributes.custom-price.currencyCode:1500')
  #   .search()
  facet: (facet) ->
    return this unless facet
    encodedFacet = encodeURIComponent(facet)
    @_params.query.facet.push encodedFacet
    debug 'setting facet: %s', facet
    this

  # Public: Define a [Suggestion](http://dev.sphere.io/http-api-projects-products-search.html#suggest)
  # used for matching tokens for product projections, via a suggest tokenizer.
  # The suggestions can be used to implement a basic auto-complete functionality.
  # The source of data for suggestions is the searchKeyword field in a product.
  #
  # text - {String} The suggested text
  # lang - {String} An ISO language tag, used for search the given text in localized product content
  #
  # Throws an {Error} if `text` or `lang` is missing
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.searchKeywords('Swiss Army Knife', 'en').suggest()
  searchKeywords: (text, lang) ->
    throw new Error 'Suggestion text parameter is required for searching for a suggestion' unless text
    throw new Error 'Language parameter is required for searching for a suggestion' unless lang

    @_params.query.searchKeywords.push {text: encodeURIComponent(text), lang: lang}
    debug 'setting searchKeywords: %s, %s', text, lang
    this

  # Public: Define whether to set [priceSelection](http://dev.commercetools.com/http-api-projects-products.html#price-selection) or not
  # Set the given `priceCurrency` param used for price selection.
  #
  # priceCurrency - The currency code compliant to ISO 4217
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service
  #     .priceCurrency('EUR')
  #     .fetch()
  priceCurrency: (priceCurrency) ->
    throw new Error 'PriceCurrency parameter is required' unless priceCurrency

    @_params.query.priceCurrency = priceCurrency
    this

  # Public: Define whether to set [priceSelection](http://dev.commercetools.com/http-api-projects-products.html#price-selection) or not
  # Set the given `priceCountry` param used for price selection.
  #
  # priceCountry - A two-digit country code as per ISO 3166-1 alpha-2
  #              - Can only be used with priceCurrency parameter
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service
  #     .priceCurrency('EUR')
  #     .priceCountry('GB')
  #     .fetch()
  priceCountry: (priceCountry) ->
    throw new Error 'PriceCountry parameter is required' unless priceCountry

    @_params.query.priceCountry = priceCountry
    this

  # Public: Define whether to set [priceSelection](http://dev.commercetools.com/http-api-projects-products.html#price-selection) or not
  # Set the given `priceCustomerGroup` param used for price selection.
  #
  # priceCustomerGroup - Price customer group UUID
  #                    - Can only be used with priceCurrency parameter
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service
  #     .priceCurrency('EUR')
  #     .priceCustomerGroup('UUID')
  #     .fetch()
  priceCustomerGroup: (priceCustomerGroup) ->
    throw new Error 'PriceCustomerGroup parameter is required' unless priceCustomerGroup

    @_params.query.priceCustomerGroup = priceCustomerGroup
    this

  # Public: Define whether to set [priceSelection](http://dev.commercetools.com/http-api-projects-products.html#price-selection) or not
  # Set the given `priceChannel` param used for price selection.
  #
  # priceChannel - Price channel UUID
  #              - Can only be used with priceCurrency parameter
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service
  #     .priceCurrency('EUR')
  #     .priceChannel('UUID')
  #     .fetch()
  priceChannel: (priceChannel) ->
    throw new Error 'PriceChannel parameter is required' unless priceChannel

    @_params.query.priceChannel = priceChannel
    this

  # Private: Build a query string from (pre)defined params and custom search params
  #
  # Returns the built query string
  _queryString: ->
    {
      staged, fuzzy, text, filter, filterByQuery, filterByFacets, facet, searchKeywords,
      priceCurrency, priceCountry, priceCustomerGroup, priceChannel
    } = _.defaults @_params.query, @_getProductsProjectionDefault()

    customQueryString = []
    customQueryString.push "staged=#{staged}" if staged
    customQueryString.push "fuzzy=#{fuzzy}" if fuzzy
    customQueryString.push "text.#{text.lang}=#{text.value}" if text

    # filter param
    _.each filter, (f) -> customQueryString.push "filter=#{f}"

    # filterByQuery param
    _.each filterByQuery, (f) -> customQueryString.push "filter.query=#{f}"

    # filterByFacets param
    _.each filterByFacets, (f) -> customQueryString.push "filter.facets=#{f}"

    # facet param
    _.each facet, (f) -> customQueryString.push "facet=#{f}"

    # searchKeywords param
    _.each searchKeywords, (keys) ->
      customQueryString.push "searchKeywords.#{keys.lang}=#{keys.text}"

    # priceSelection params
    customQueryString.push "priceCurrency=#{priceCurrency}" if priceCurrency
    customQueryString.push "priceCountry=#{priceCountry}" if priceCountry
    customQueryString.push "priceCustomerGroup=#{priceCustomerGroup}" if priceCustomerGroup
    customQueryString.push "priceChannel=#{priceChannel}" if priceChannel

    _.compact([super()].concat(customQueryString)).join '&'

  # Public: Search `ProductProjections` with all the search parameters
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {Error}
  #
  # Examples
  #
  #   service = client.productProjections
  #   service
  #   .text('Red Shirt')
  #   .sort('createdAt desc')
  #   .filter('variants.attributes.foo:"bar"')
  #   .search()
  search: ->
    @asSearch().fetch()

  # Public: Define to use search instead of query endpoint.
  # Compared to {::search} this allows for further chaining.
  # For example to use {BaseService::process} to deal with product search results in batches.
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.productProjections
  #   service
  #   .asSearch()
  #   .process(...)
  asSearch: ->
    @_currentEndpoint = '/product-projections/search'
    debug 'setting search endpoint: %s', @_currentEndpoint
    this

  ###*
   * Query suggestions based on search keywords (used e.g. for auto-complete functionality)
   * @param  {String} suggestion A suggestion text to search for
   * @param  {String} language An ISO language tag, used for suggestion search for the 'searchKeywords' param
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###

  # Public: Query suggestions based on search keywords (used e.g. for auto-complete functionality)
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {Error}
  #
  # Examples
  #
  #   service = client.productProjections
  #   service.searchKeywords('Swiss Army Knife', 'en').suggest()
  suggest: ->
    @_currentEndpoint = '/product-projections/suggest'
    debug 'setting suggest endpoint: %s', @_currentEndpoint
    @fetch()

  # Public Unsupported: Not supported by the API
  save: -> # noop

  # Public Unsupported: Not supported by the API
  create: -> # noop

  # Public Unsupported: Not supported by the API
  update: ->

  # Public Unsupported: Not supported by the API
  delete: ->

module.exports = ProductProjectionService
