import expect from 'expect'
import { setDefaultParams } from '../../lib/utils/default-params'

describe('Utils', () => {

  describe('::defaultParams', () => {
    let defaultServiceConfig

    beforeEach(() => {
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
    })

    it('should set default params for a normal endpoint', () => {
      const serviceConfig = Object.assign({}, defaultServiceConfig, {
        hasQuery: true,
        hasQueryOne: true
      })
      const params = {}
      setDefaultParams.call({ serviceConfig, params })
      expect(params).toEqual({
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
    })

    it('should set default params for product-projections', () => {
      const serviceConfig = Object.assign({}, defaultServiceConfig, {
        hasQuery: true,
        hasQueryOne: true,
        hasProjection: true
      })
      const params = {}
      setDefaultParams.call({ serviceConfig, params })
      expect(params).toEqual({
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
    })

    it('should set default params for product-projections-search', () => {
      const serviceConfig = Object.assign({}, defaultServiceConfig, {
        hasSearch: true,
        hasProjection: true
      })
      const params = {}
      setDefaultParams.call({ serviceConfig, params })
      expect(params).toEqual({
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
    })

  })
})
