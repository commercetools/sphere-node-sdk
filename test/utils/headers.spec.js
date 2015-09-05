import expect from 'expect'
import * as headers from '../../lib/utils/headers'

describe('Utils', () => {

  describe('::headers', () => {

    let service

    beforeEach(() => {
      service = Object.assign({
        request: { headers: { 'Content-Type': 'application/json' } }
      }, headers)
    })

    it('should set the given header', () => {
      service.withHeader('Authorization', 'supersecret')
      expect(service.request.headers).toEqual({
        'Authorization': 'supersecret',
        'Content-Type': 'application/json'
      })
    })

    it('should throw if key or value are missing', () => {
      expect(() => service.withHeader())
      .toThrow(/Missing required header arguments/)

      expect(() => service.withHeader('foo'))
      .toThrow(/Missing required header arguments/)
    })

  })
})
