import httpFn from '../../lib/utils/http'

describe('Utils', () => {

  describe('::http', () => {

    it('should expose crud methods', () => {
      const http = httpFn({
        Promise: jasmine.createSpy('promise'),
        request: {}
      })
      expect(http.get).toEqual(jasmine.any(Function))
      expect(http.post).toEqual(jasmine.any(Function))
      expect(http.delete).toEqual(jasmine.any(Function))
    })

  })
})
