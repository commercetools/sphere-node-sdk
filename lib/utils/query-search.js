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
 * @return {Object} The instance of the service, can be chained.
 */
export function text (text, lang) {
  if (!text)
    throw new Error('Parameter `text` is required for searching')
  if (!lang)
    throw new Error('Parameter `lang` is required for searching')

  this.params.search.text = { lang, value: encodeURIComponent(text) }
  return this
}

/**
 * Set the given `facet` filter used for calculating statistical counts.
 *
 * @param  {string} facet - A non-URI encoded string representing a
 * facet expression.
 * @return {Object} The instance of the service, can be chained.
 */
export function facet (facet) {
  // TODO: throw if facet is missing?
  if (facet) {
    const encodedFacet = encodeURIComponent(facet)
    this.params.search.facet.push(encodedFacet)
  }
  return this
}

/**
 * Set the given `filter` param used for filtering search results.
 *
 * @param  {string} filter - A non-URI encoded string representing a
 * filter expression.
 * @return {Object} The instance of the service, can be chained.
 */
export function filter (filter) {
  // TODO: throw if filter is missing?
  if (filter) {
    const encodedFilter = encodeURIComponent(filter)
    this.params.search.filter.push(encodedFilter)
  }
  return this
}

/**
 * Set the given `filter.query` param used for filtering search results.
 *
 * @param  {string} filter - A non-URI encoded string representing a
 * filter by query expression.
 * @return {Object} The instance of the service, can be chained.
 */
export function filterByQuery (filter) {
  // TODO: throw if filter is missing?
  if (filter) {
    const encodedFilter = encodeURIComponent(filter)
    this.params.search.filterByQuery.push(encodedFilter)
  }
  return this
}

/**
 * Set the given `filter.facets` param used for filtering search results.
 *
 * @param  {string} filter - A non-URI encoded string representing a
 * filter by query expression.
 * @return {Object} The instance of the service, can be chained.
 */
export function filterByFacets (filter) {
  // TODO: throw if filter is missing?
  if (filter) {
    const encodedFilter = encodeURIComponent(filter)
    this.params.search.filterByFacets.push(encodedFilter)
  }
  return this
}
