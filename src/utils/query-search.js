/**
 * Utils `query-search` module. It contains methods to work with
 * products search requests.
 * @module utils/querySearch
 */
import {
  SERVICE_PARAM_QUERY_SEARCH_FACET,
  SERVICE_PARAM_QUERY_SEARCH_FILTER,
  SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_QUERY,
  SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_FACETS,
  SERVICE_PARAM_QUERY_SEARCH_FUZZY,
  SERVICE_PARAM_QUERY_SEARCH_TEXT,
} from '../constants'

/**
 * Set the given `text` param used for full-text search.
 *
 * @param  {string} value - A non-URI encoded string representing a
 * text to search for.
 * @param  {string} lang - An ISO language tag, used for search
 * the given text in localized content.
 * @throws If `value` or `lang` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function text (value, lang) {
  if (!value || !lang)
    throw new Error('Required arguments for `text` are missing')

  const searchText = { lang, value: encodeURIComponent(value) }

  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_SEARCH_TEXT,
    meta: { service: this.type },
    payload: searchText,
  })
  return this
}

/**
 * Define whether to enable the fuzzy search.
 *
 * @return {Object} The instance of the service, can be chained.
 */
export function fuzzy () {
  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_SEARCH_FUZZY,
    meta: { service: this.type },
  })
  return this
}

/**
 * Set the given `facet` filter used for calculating statistical counts.
 *
 * @param  {string} value - A non-URI encoded string representing a
 * facet expression.
 * @throws If `value` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function facet (value) {
  if (!value)
    throw new Error('Required argument for `facet` is missing')

  const encodedFacet = encodeURIComponent(value)

  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_SEARCH_FACET,
    meta: { service: this.type },
    payload: encodedFacet,
  })
  return this
}

/**
 * Set the given `filter` param used for filtering search results.
 *
 * @param  {string} value - A non-URI encoded string representing a
 * filter expression.
 * @throws If `value` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function filter (value) {
  if (!value)
    throw new Error('Required argument for `filter` is missing')

  const encodedFilter = encodeURIComponent(value)

  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_SEARCH_FILTER,
    meta: { service: this.type },
    payload: encodedFilter,
  })
  return this
}

/**
 * Set the given `filter.query` param used for filtering search results.
 *
 * @param  {string} value - A non-URI encoded string representing a
 * filter by query expression.
 * @throws If `value` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function filterByQuery (value) {
  if (!value)
    throw new Error('Required argument for `filterByQuery` is missing')

  const encodedFilter = encodeURIComponent(value)

  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_QUERY,
    meta: { service: this.type },
    payload: encodedFilter,
  })
  return this
}

/**
 * Set the given `filter.facets` param used for filtering search results.
 *
 * @param  {string} value - A non-URI encoded string representing a
 * filter by query expression.
 * @throws If `value` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function filterByFacets (value) {
  if (!value)
    throw new Error('Required argument for `filterByFacets` is missing')

  const encodedFilter = encodeURIComponent(value)

  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_FACETS,
    meta: { service: this.type },
    payload: encodedFilter,
  })
  return this
}
