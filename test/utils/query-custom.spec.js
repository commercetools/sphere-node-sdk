import expect from 'expect'
import * as queryCustom from '../../lib/utils/query-custom'

describe('Utils', () => {

  describe('::queryCustom', () => {

    let service

    beforeEach(() => {
      service = Object.assign({ params: {} }, queryCustom)
    })

    it('should set the customQueryString param', () => {
      const encodedQuery = encodeURIComponent('foo=bar&text="Hello world"')
      service.byQueryString(encodedQuery)
      expect(service.params.customQuery).toEqual(encodedQuery)
    })

    it('should throw if customQueryString is missing', () => {
      expect(() => service.byQueryString())
      .toThrow(/Parameter `customQueryString` is missing/)
    })

  })
})
