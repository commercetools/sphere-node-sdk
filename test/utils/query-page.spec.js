import expect from 'expect'
import * as queryPage from '../../lib/utils/query-page'
import { getDefaultQueryParams } from '../../lib/utils/default-params'

describe('Utils', () => {

  describe('::queryPage', () => {

    let service

    beforeEach(() => {
      service = Object.assign({ params: getDefaultQueryParams() }, queryPage)
    })

    it('should set the sort param (asc)', () => {
      service.sort('createdAt')
      expect(service.params.pagination.sort).toEqual([
        encodeURIComponent('createdAt asc')
      ])
    })

    it('should set the sort param (desc)', () => {
      service.sort('createdAt', false)
      expect(service.params.pagination.sort).toEqual([
        encodeURIComponent('createdAt desc')
      ])
    })

    it('should throw if sortPath is missing', () => {
      expect(() => service.sort()).toThrow(/Parameter `sortPath` is missing/)
    })

    it('should set the page param', () => {
      service.page(5)
      expect(service.params.pagination.page).toBe(5)
    })

    it('should throw if page is missing', () => {
      expect(() => service.page()).toThrow(/Parameter `page` is missing/)
    })

    it('should throw if page is a number < 1', () => {
      expect(() => service.page(0)).toThrow(/Parameter `page` must be a number >= 1/)
    })

    it('should set the perPage param', () => {
      service.perPage(40)
      expect(service.params.pagination.perPage).toBe(40)
    })

    it('should throw if perPage is missing', () => {
      expect(() => service.perPage()).toThrow(/Parameter `perPage` is missing/)
    })

    it('should throw if perPage is a number < 1', () => {
      expect(() => service.perPage(-1)).toThrow(/Parameter `perPage` must be a number >= 0/)
    })

  })
})
