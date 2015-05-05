import { expect } from 'chai'
import sinon from 'sinon'
import httpFn from '../../lib/utils/http'

describe('Utils', () => {

  describe('::http', () => {

    it('should expose crud methods', () => {
      const http = httpFn({
        Promise: sinon.stub(),
        request: {}
      })
      expect(http.get).to.be.a('function')
      expect(http.post).to.be.a('function')
      expect(http.delete).to.be.a('function')
    })

  })
})
