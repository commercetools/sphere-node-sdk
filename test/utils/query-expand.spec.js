import test from 'tape'
import * as queryExpand from '../../src/utils/query-expand'

test('Utils::queryExpand', t => {
  let service

  function setup () {
    service = Object.assign({ params: { expand: [] } }, queryExpand)
  }

  t.test('should set the expand param', t => {
    setup()

    service.expand('productType')
    t.deepEqual(service.params.expand, [
      encodeURIComponent('productType'),
    ])
    t.end()
  })

  t.test('should throw if expansionPath is missing', t => {
    setup()

    t.throws(() => service.expand(),
      /Required argument for `expand` is missing/)
    t.end()
  })
})
