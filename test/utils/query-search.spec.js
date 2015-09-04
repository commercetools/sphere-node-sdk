import expect from 'expect'
import * as querySearch from '../../lib/utils/query-search'
import { getDefaultSearchParams } from '../../lib/utils/default-params'

describe('Utils', () => {

  describe('::querySearch', () => {

    let service

    beforeEach(() => {
      service = Object.assign({ params: getDefaultSearchParams() }, querySearch)
    })

    it('should set the text param', () => {
      service.text('Foo Bar', 'en')
      expect(service.params.search.text).toEqual({
        lang: 'en',
        value: encodeURIComponent('Foo Bar')
      })
    })

    it('should throw if text params are missing', () => {
      expect(() => service.text()).toThrow(/Parameter `text` is missing/)
      expect(() => service.text('Foo Bar'))
      .toThrow(/Parameter `lang` is missing/)
    })

    it('should set the facet param', () => {
      service.facet('categories.id:"123"')
      expect(service.params.search.facet).toEqual([
        encodeURIComponent('categories.id:"123"')
      ])
    })

    it('should throw if facet is missing', () => {
      expect(() => service.facet()).toThrow(/Parameter `facet` is missing/)
    })

    it('should set the filter param', () => {
      service.filter('categories.id:"123"')
      expect(service.params.search.filter).toEqual([
        encodeURIComponent('categories.id:"123"')
      ])
    })

    it('should throw if filter is missing', () => {
      expect(() => service.filter()).toThrow(/Parameter `filter` is missing/)
    })

    it('should set the filterByQuery param', () => {
      service.filterByQuery('categories.id:"123"')
      expect(service.params.search.filterByQuery).toEqual([
        encodeURIComponent('categories.id:"123"')
      ])
    })

    it('should throw if filterByQuery is missing', () => {
      expect(() => service.filterByQuery())
      .toThrow(/Parameter `filterByQuery` is missing/)
    })

    it('should set the filterByFacets param', () => {
      service.filterByFacets('categories.id:"123"')
      expect(service.params.search.filterByFacets).toEqual([
        encodeURIComponent('categories.id:"123"')
      ])
    })

    it('should throw if filterByFacets is missing', () => {
      expect(() => service.filterByFacets())
      .toThrow(/Parameter `filterByFacets` is missing/)
    })

  })
})
