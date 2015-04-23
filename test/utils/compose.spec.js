import * as utils from '../../lib/utils'

describe('Utils', () => {

  describe('::compose', () => {

    it('should freeze non-function property and make it non-enumerable', () => {
      const composed = utils.compose(
        { foo: 'bar' },
        { bar: { a: 1, b: 2 } },
        { getFoo () { return this.foo } },
        { getBar () { return this.bar } }
      )
      Object.keys(composed).forEach(key => {
        expect(typeof composed[key]).toBe('function')
      })
      expect(Object.keys(composed).length).toBe(2)
      expect(Object.getOwnPropertyNames(composed).length).toBe(4)
    })

  })
})
