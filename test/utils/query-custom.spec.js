import test from 'tape'
import * as queryCustom from '../../lib/utils/query-custom'

test('Utils::queryCustom', t => {

  let service

  function setup () {
    service = Object.assign({ params: {} }, queryCustom)
  }

  t.test('should set the customQueryString param', t => {
    setup()

    const encodedQuery = encodeURIComponent('foo=bar&text="Hello world"')
    service.byQueryString(encodedQuery)
    t.equal(service.params.customQuery, encodedQuery)
    t.end()
  })

  t.test('should throw if customQueryString is missing', t => {
    setup()

    t.throws(() => service.byQueryString(),
      /Parameter `customQueryString` is missing/)
    t.end()
  })

})
