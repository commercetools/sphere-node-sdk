import { expect } from 'chai'
import compose from '../../lib/utils/compose'

describe('Utils', () => {

  describe('::compose', () => {

    it('should freeze non-function property and make it non-enumerable', () => {
      const composed = compose(
        { foo: 'bar' },
        { bar: { a: 1, b: 2 } },
        { getFoo () { return this.foo } },
        { getBar () { return this.bar } }
      )
      Object.keys(composed).forEach(key => {
        expect(composed[key]).to.be.a('function')
      })
      expect(Object.keys(composed)).to.have.length.of(2)
      expect(Object.getOwnPropertyNames(composed)).to.have.length.of(4)
    })

  })
})
