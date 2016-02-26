/**
 * Utils `query-search` module. It contains methods to work with
 * products search requests.
 * @module utils/querySearch
 */

/**
 * Set the given `text` param used for full-text search.
 *
 * @param  {string} text - A non-URI encoded string representing a
 * text to search for.
 * @param  {string} lang - An ISO language tag, used for search
 * the given text in localized content.
 * @throws If `text` is missing.
 * @throws If `lang` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function text (text, lang) {
  if (!text)
    throw new Error('Parameter `text` is missing')
  if (!lang)
    throw new Error('Parameter `lang` is missing')

  this.params.search.text = { lang, value: encodeURIComponent(text) }
  return this
}

/**
 * Define whether to enable the fuzzy search.
 *
 * @param  {boolean} staged - Either `true` (default) or `false`.
 * @return {Object} The instance of the service, can be chained.
 */
export function fuzzy () {
  this.params.search.fuzzy = true
  return this
}

/**
 * Set the given `facet` filter used for calculating statistical counts.
 *
 * @param  {string} facet - A non-URI encoded string representing a
 * facet expression.
 * @throws If `facet` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function facet (facet) {
  if (!facet)
    throw new Error('Parameter `facet` is missing')

  const encodedFacet = encodeURIComponent(facet)
  this.params.search.facet.push(encodedFacet)
  return this
}

/**
 * Set the given `filter` param used for filtering search results.
 *
 * @param  {string} filter - A non-URI encoded string representing a
 * filter expression.
 * @throws If `filter` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function filter (filter) {
  if (!filter)
    throw new Error('Parameter `filter` is missing')

  const encodedFilter = encodeURIComponent(filter)
  this.params.search.filter.push(encodedFilter)
  return this
}

/**
 * Set the given `filter.query` param used for filtering search results.
 *
 * @param  {string} filter - A non-URI encoded string representing a
 * filter by query expression.
 * @throws If `filterByQuery` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function filterByQuery (filterByQuery) {
  if (!filterByQuery)
    throw new Error('Parameter `filterByQuery` is missing')

  const encodedFilter = encodeURIComponent(filterByQuery)
  this.params.search.filterByQuery.push(encodedFilter)
  return this
}

/**
 * Set the given `filter.facets` param used for filtering search results.
 *
 * @param  {string} filter - A non-URI encoded string representing a
 * filter by query expression.
 * @throws If `filterByFacets` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function filterByFacets (filterByFacets) {
  if (!filterByFacets)
    throw new Error('Parameter `filterByFacets` is missing')

  const encodedFilter = encodeURIComponent(filterByFacets)
  this.params.search.filterByFacets.push(encodedFilter)
  return this
}
