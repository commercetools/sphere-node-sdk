/**
 * Utils `default-params` module.
 * @module utils/defaultParams
 */

/**
 * Return the default parameters for building a query string.
 *
 * @return {Object}
 */
export function getDefaultQueryParams () {
  return {
    id: null,
    customQuery: null,
    expand: [],
    pagination: {
      page: null,
      perPage: null,
      sort: []
    },
    query: {
      operator: 'and',
      where: []
    }
  }
}

/**
 * Return the default parameters for building a query search string.
 *
 * @return {Object}
 */
export function getDefaultSearchParams () {
  return {
    expand: [],
    staged: true,
    pagination: {
      page: null,
      perPage: null,
      sort: []
    },
    search: {
      facet: [],
      filter: [],
      filterByQuery: [],
      filterByFacets: [],
      text: null
    }
  }
}

/**
 * Set the default parameters given the current service object.
 *
 * @return {void}
 */
export function setDefaultParams () {
  if (this.serviceConfig.hasQueryString)
    this.params.customQuery = getDefaultQueryParams().customQuery

  if (this.serviceConfig.hasQueryOne)
    this.params.id = getDefaultQueryParams().id

  if (this.serviceConfig.hasQuery) {
    this.params.expand = getDefaultQueryParams().expand
    this.params.pagination = getDefaultQueryParams().pagination
    this.params.query = getDefaultQueryParams().query
  }

  if (this.serviceConfig.hasSearch) {
    this.params.expand = getDefaultSearchParams().expand
    this.params.staged = getDefaultSearchParams().staged
    this.params.pagination = getDefaultSearchParams().pagination
    this.params.search = getDefaultSearchParams().search
  }

  if (this.serviceConfig.hasProjection)
    this.params.staged = true
}
