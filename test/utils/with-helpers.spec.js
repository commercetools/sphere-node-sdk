import expect from 'expect'
import * as withHelpers from '../../lib/utils/with-helpers'

describe('Utils', () => {

  describe('::with', () => {

    let service

    beforeEach(() => {
      service = Object.assign({
        auth: { credentials: {} },
        request: { headers: { 'Content-Type': 'application/json' } }
      }, withHelpers)
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

    it('should set the new credentials header', () => {
      service.withCredentials({ projectKey: 'foo' })
      expect(service.auth.credentials).toEqual({
        projectKey: 'foo'
      })
    })

    it('should throw if credentials is missing', () => {
      expect(() => service.withCredentials())
      .toThrow(/Credentials object is missing/)
    })

  })
})
