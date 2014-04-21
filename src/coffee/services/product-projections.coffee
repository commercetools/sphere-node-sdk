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

  _setDefaults: ->
    super()
    @_customParams =
      query:
        staged: false
        filter: []
        filterByQuery: []
        filterByFacets: []
        facet: []

  ###*
   * Define to fetch only staged products
   * @param Boolean [staged] true to query staged products (default). False to query published products
   * @return {ProductProjectionService} Chained instance of this class
  ###
  staged: (staged = true) ->
    @_customParams.query.staged = staged
    @_logger.debug @_customParams.query, 'Setting \'staged\' parameter'
    this

  lang: (language) ->
    throw new Error 'Language parameter is required for searching' unless language
    @_customParams.query.lang = language
    @_logger.debug @_customParams.query, 'Setting \'lang\' parameter'
    this

  text: (text) ->
    return this unless text
    @_customParams.query.text = text
    @_logger.debug @_customParams.query, 'Setting \'text\' parameter'
    this

  filter: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_customParams.query.filter.push encodedFilter
    @_logger.debug @_customParams.query, 'Setting \'filter\' parameter'
    this

  filterByQuery: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_customParams.query.filterByQuery.push encodedFilter
    @_logger.debug @_customParams.query, 'Setting \'filter.query\' parameter'
    this

  filterByFacets: (filter) ->
    return this unless filter
    encodedFilter = encodeURIComponent(filter)
    @_customParams.query.filterByFacets.push encodedFilter
    @_logger.debug @_customParams.query, 'Setting \'filter.facets\' parameter'
    this

  facet: (facet) ->
    return this unless facet
    encodedFacet = encodeURIComponent(facet)
    @_customParams.query.facet.push encodedFacet
    @_logger.debug @_customParams.query, 'Setting \'facet\' parameter'
    this

  ###*
   * @private
   * Extend the query string by staged param
   * @return {String} the query string
  ###
  _queryString: ->
    {staged, lang, text, filter, filterByQuery, filterByFacets, facet} = _.defaults @_customParams.query,
      staged: false
      filter: []
      filterByQuery: 'and'
      filterByFacets: []
      facet: []

    # filter param
    filterParam = filter.join '&'

    # filterByQuery param
    filterByQueryParam = filterByQuery.join '&'

    # filterByFacets param
    filterByFacetsParam = filterByFacets.join '&'

    # facet param
    facetParam = facet.join '&'

    customQueryString = []
    customQueryString.push "staged=#{staged}" if staged
    customQueryString.push "lang=#{lang}" if lang
    customQueryString.push "text=#{text}" if text
    customQueryString.push "filter=#{filterParam}" if filterParam
    customQueryString.push "filter.query=#{filterByQueryParam}" if filterByQueryParam
    customQueryString.push "filter.facets=#{filterByFacetsParam}" if filterByFacetsParam
    customQueryString.push "facet=#{facetParam}" if facetParam

    _.compact([super()].concat(customQueryString)).join '&'

  ###*
   * Fetch resource defined by _currentEndpoint with query parameters
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  search: ->
    @_currentEndpoint = '/product-projections/search'
    @fetch()


###*
 * The {@link ProductProjectionService} service.
###
module.exports = ProductProjectionService
