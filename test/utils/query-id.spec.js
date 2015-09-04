import expect from 'expect'
import * as queryId from '../../lib/utils/query-id'

describe('Utils', () => {

  describe('::queryId', () => {

    let service

    beforeEach(() => {
      service = Object.assign({ params: {} }, queryId)
    })

    it('should set the id param', () => {
      service.byId('123')
      expect(service.params.id).toBe('123')
    })

    it('should throw if id is missing', () => {
      expect(() => service.byId()).toThrow(/Parameter `id` is missing/)
    })

  })
})
