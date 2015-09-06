import expect from 'expect'
import * as queryExpand from '../../lib/utils/query-expand'

describe('Utils', () => {

  describe('::queryExpand', () => {

    let service

    beforeEach(() => {
      service = Object.assign({ params: { expand: [] } }, queryExpand)
    })

    it('should set the expand param', () => {
      service.expand('productType')
      expect(service.params.expand).toEqual([
        encodeURIComponent('productType')
      ])
    })

    it('should throw if expansionPath is missing', () => {
      expect(() => service.expand())
      .toThrow(/Parameter `expansionPath` is missing/)
    })

  })
})
