import { expect } from 'chai'
import sinon from 'sinon'
import httpFn from '../../lib/utils/http'

describe('Utils', () => {

  describe('::http', () => {

    it('should expose a function', () => {
      const http = httpFn({
        Promise: sinon.stub(),
        request: {}
      })
      expect(http).to.be.a('function')
    })

  })
})
