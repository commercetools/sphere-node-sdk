/**
 * Utils `default-params` module.
 * @module utils/defaultParams
 */
import * as features from './features'

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
  this.params.expand = getDefaultQueryParams().expand

  if (isFeatureEnabled(this.features, (features.queryString)))
    this.params.customQuery = getDefaultQueryParams().customQuery

  if (isFeatureEnabled(this.features, (features.queryOne)))
    this.params.id = getDefaultQueryParams().id

  if (isFeatureEnabled(this.features, (features.query))) {
    this.params.pagination = getDefaultQueryParams().pagination
    this.params.query = getDefaultQueryParams().query
  }

  if (isFeatureEnabled(this.features, (features.search))) {
    this.params.staged = getDefaultSearchParams().staged
    this.params.pagination = getDefaultSearchParams().pagination
    this.params.search = getDefaultSearchParams().search
  }

  if (isFeatureEnabled(this.features, (features.projection)))
    this.params.staged = true
}

function isFeatureEnabled (features, key) {
  return Boolean(~features.indexOf(key))
}
