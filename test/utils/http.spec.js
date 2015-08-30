import expect from 'expect'
import httpFn from '../../lib/utils/http'

describe('Utils', () => {

  describe('::http', () => {

    it('should expose a function', () => {
      const http = httpFn({
        Promise: () => {},
        request: {}
      })
      expect(http).toBeA('function')
    })

  })
})
