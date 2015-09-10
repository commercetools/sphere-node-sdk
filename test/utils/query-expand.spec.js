import test from 'tape'
import * as queryExpand from '../../lib/utils/query-expand'

test('Utils::queryExpand', t => {

  let service

  function setup () {
    service = Object.assign({ params: { expand: [] } }, queryExpand)
  }

  t.test('should set the expand param', t => {
    setup()

    service.expand('productType')
    t.deepEqual(service.params.expand, [
      encodeURIComponent('productType')
    ])
    t.end()
  })

  t.test('should throw if expansionPath is missing', t => {
    setup()

    t.throws(() => service.expand(),
      /Parameter `expansionPath` is missing/)
    t.end()
  })

})
