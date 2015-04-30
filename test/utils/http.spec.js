import http from '../../lib/utils/http'

describe('Utils', () => {

  describe('::http', () => {

    it('should expose crud methods', () => {
      const httpFetch = http({
        Promise: jasmine.createSpy('request'),
        request: {}
      })
      expect(httpFetch.get).toEqual(jasmine.any(Function))
      expect(httpFetch.post).toEqual(jasmine.any(Function))
      expect(httpFetch.delete).toEqual(jasmine.any(Function))
    })

  })
})
