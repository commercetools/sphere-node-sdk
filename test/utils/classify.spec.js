import expect from 'expect'
import classify from '../../lib/utils/classify'

describe('Utils', () => {

  describe('::classify', () => {

    it('should freeze non-function property and make it non-enumerable',
      () => {
        const composed = classify(Object.assign({},
          { foo: 'bar' },
          { bar: { a: 1, b: 2 } },
          { getFoo () { return this.foo } },
          { getBar () { return this.bar } }
        ))
        Object.keys(composed).forEach(key => {
          expect(composed[key]).toBeA('function')
        })
        expect(Object.keys(composed).length).toBe(2)
        expect(Object.getOwnPropertyNames(composed).length).toBe(4)
      })

  })
})
