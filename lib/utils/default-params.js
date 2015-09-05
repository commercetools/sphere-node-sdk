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
export function setDefaultParams (type, params) {
  if (type === 'product-projections-search') {
    params.expand = getDefaultSearchParams().expand
    params.staged = getDefaultSearchParams().staged
    params.pagination = getDefaultSearchParams().pagination
    params.search = getDefaultSearchParams().search
    return
  }

  if (type === 'product-projections')
    params.staged = true

  params.id = getDefaultQueryParams().id,
  params.expand = getDefaultQueryParams().expand
  params.pagination = getDefaultQueryParams().pagination
  params.query = getDefaultQueryParams().query
}
