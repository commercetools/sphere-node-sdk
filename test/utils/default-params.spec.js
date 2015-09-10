import test from 'tape'
import { setDefaultParams } from '../../lib/utils/default-params'

test('Utils::defaultParams', t => {
  let defaultServiceConfig

  function setup () {
    defaultServiceConfig = {
      hasRead: false,
      hasCreate: false,
      hasUpdate: false,
      hasDelete: false,
      hasQuery: false,
      hasQueryOne: false,
      hasSearch: false,
      hasProjection: false
    }
  }

  t.test('should set default params for a normal endpoint', t => {
    setup()

    const serviceConfig = Object.assign({}, defaultServiceConfig, {
      hasQuery: true,
      hasQueryOne: true
    })
    const params = {}
    setDefaultParams.call({ serviceConfig, params })
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
    setup()

    const serviceConfig = Object.assign({}, defaultServiceConfig, {
      hasQuery: true,
      hasQueryOne: true,
      hasProjection: true
    })
    const params = {}
    setDefaultParams.call({ serviceConfig, params })
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
    setup()

    const serviceConfig = Object.assign({}, defaultServiceConfig, {
      hasSearch: true,
      hasProjection: true
    })
    const params = {}
    setDefaultParams.call({ serviceConfig, params })
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
        text: null
      }
    })
    t.end()
  })

})
