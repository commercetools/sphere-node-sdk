import test from 'tape'
import classify from '../../src/utils/classify'

test('Utils::classify', t => {
  t.test('should freeze non-function property and make it non-enumerable',
    t => {
      const composed = classify(Object.assign({},
        { foo: 'bar' },
        { bar: { a: 1, b: 2 } },
        { getFoo () { return this.foo } },
        { getBar () { return this.bar } }
      ))
      Object.keys(composed).forEach(key => {
        t.equal(typeof composed[key], 'function')
      })
      t.equal(Object.keys(composed).length, 2)
      t.equal(Object.getOwnPropertyNames(composed).length, 4)
      t.end()
    })
})
