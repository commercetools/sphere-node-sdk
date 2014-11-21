debug = require('debug')('sphere-client')
_ = require 'underscore'
BaseService = require './base'

###*
 * Creates a new ProductProjectionService.
 * @class ProductProjectionService
###
class ProductProjectionService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a ProductProjections API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/product-projections'

  ###*
   * @private
   * Reset default query/search params
  ###
  _setDefaults: ->
    super()
    _.extend @_params.query,
      staged: false
      filter: []
      filterByQuery: []
      filterByFacets: []
      facet: []
      searchKeywords: []

  ###*
   * Define whether to query for staged or current product projection.
   * @param Boolean [staged] true to query staged products (default). False to query published products
   * @return {ProductProjectionService} Chained instance of this class
  ###
  staged: (staged = true) ->
    @_params.query.staged = staged
    debug 'setting staged: %s', staged
    this

  ###*
   * Define the language tag used for searching product projection.
   * @param {String} language An ISO language tag, used for search, for the 'lang' search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  lang: (language) ->
    throw new Error 'Language parameter is required for searching' unless language
    @_params.query.lang = language
    debug 'setting lang: %s', language
    this

  ###*
   * Define the text to analyze and search.
   * @param {String} [text] A string for the `text` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  text: (text) ->
    return this unless text
    @_params.query.text = text
    debug 'setting text: %s', text
    this

  ###*
   * Define a {Filter} used for filtering searched product projections.
   * @link http://dev.sphere.io/http-api-projects-products-search.html#search-filters
   * @param {String} [filter] A {Filter} string for the `filter` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  filter: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_params.query.filter.push encodedFilter
    debug 'setting filter: %s', filter
    this

  ###*
   * Define a {Filter} (applied to query result) used for filtering searched product projections.
   * @link http://dev.sphere.io/http-api-projects-products-search.html#search-filters
   * @param {String} [filter] A {Filter} string for the `filter.query` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  filterByQuery: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_params.query.filterByQuery.push encodedFilter
    debug 'setting filter.query: %s', filter
    this

  ###*
   * Define a {Filter} (applied to facet calculation) used for filtering searched product projections.
   * @link http://dev.sphere.io/http-api-projects-products-search.html#search-filters
   * @param {String} [filter] A {Filter} string for the `filter.facets` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  filterByFacets: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_params.query.filterByFacets.push encodedFilter
    debug 'setting filter.facets: %s', filter
    this

  ###*
   * Define a {Facet} used for calculating statistical counts for searched product projections.
   * @link http://dev.sphere.io/http-api-projects-products-search.html#search-facets
   * @param {String} [facet] A {Facet} string for the `facet` search parameter.
   * @return {ProductProjectionService} Chained instance of this class
  ###
  facet: (facet) ->
    return this unless facet
    encodedFacet = encodeURIComponent(facet)
    @_params.query.facet.push encodedFacet
    debug 'setting facet: %s', facet
    this

  ###*
   * Define a {Suggestion} used for matching tokens for product projections, via a suggest tokenizer.
   * @link http://dev.sphere.io/http-api-projects-products-search.html#suggest
   * @param {String} [facet] A {Facet} string for the `facet` search parameter.
   * @throws {Error} If text or lang is not defined
   * @return {ProductProjectionService} Chained instance of this class
  ###
  searchKeywords: (text, lang) ->
    throw new Error 'Suggestion text parameter is required for searching for a suggestion' unless text
    throw new Error 'Language parameter is required for searching for a suggestion' unless lang

    @_params.query.searchKeywords.push {text: text, lang: lang}
    debug 'setting searchKeywords: %s, %s', text, lang
    this

  ###*
   * @private
   * Build a query string from (pre)defined params and custom search params.
   * @return {String} the query string
  ###
  _queryString: ->
    {staged, lang, text, filter, filterByQuery, filterByFacets, facet, searchKeywords} = _.defaults @_params.query,
      staged: false
      filter: []
      filterByQuery: []
      filterByFacets: []
      facet: []
      searchKeywords: []

    customQueryString = []
    customQueryString.push "staged=#{staged}" if staged
    customQueryString.push "lang=#{lang}" if lang
    customQueryString.push "text=#{text}" if text

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

    _.compact([super()].concat(customQueryString)).join '&'

  ###*
   * Search product projections with search parameters
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  search: ->
    @_currentEndpoint = '/product-projections/search'
    @fetch()

  ###*
   * Query suggestions based on search keywords (used e.g. for auto-complete functionality)
   * @param  {String} suggestion A suggestion text to search for
   * @param  {String} language An ISO language tag, used for suggestion search for the 'searchKeywords' param
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  suggest: ->
    @_currentEndpoint = '/product-projections/suggest'
    @fetch()


###*
 * The {@link ProductProjectionService} service.
###
module.exports = ProductProjectionService
