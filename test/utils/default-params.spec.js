import test from 'tape'
import * as features from '../../lib/utils/features'
import { setDefaultParams } from '../../lib/utils/default-params'

test('Utils::defaultParams', t => {

  t.test('should set default params for a normal endpoint', t => {
    const serviceFeatures = [ features.query, features.queryOne ]
    const params = {}
    setDefaultParams.call({ features: serviceFeatures, params })
    t.deepEqual(params, {
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
    })
    t.end()
  })

  t.test('should set default params for product-projections', t => {
    const serviceFeatures = [
      features.query, features.queryOne, features.projection
    ]
    const params = {}
    setDefaultParams.call({ features: serviceFeatures, params })
    t.deepEqual(params, {
      id: null,
      expand: [],
      staged: true,
      pagination: {
        page: null,
        perPage: null,
        sort: []
      },
      query: {
        operator: 'and',
        where: []
      }
    })
    t.end()
  })

  t.test('should set default params for product-projections-search', t => {
    const serviceFeatures = [ features.search, features.projection ]
    const params = {}
    setDefaultParams.call({ features: serviceFeatures, params })
    t.deepEqual(params, {
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
        fuzzy: false,
        text: null
      }
    })
    t.end()
  })

})
