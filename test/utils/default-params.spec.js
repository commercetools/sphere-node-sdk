import expect from 'expect'
import { setDefaultParams } from '../../lib/utils/default-params'

describe('Utils', () => {

  describe('::defaultParams', () => {

    it('should set default params for a normal endpoint', () => {
      const params = {}
      setDefaultParams('foo', params)
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
      const params = {}
      setDefaultParams('product-projections', params)
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
      const params = {}
      setDefaultParams('product-projections-search', params)
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
