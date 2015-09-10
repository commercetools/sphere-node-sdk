import test from 'tape'
import * as queryId from '../../lib/utils/query-id'

test('Utils::queryId', t => {

  let service

  function setup () {
    service = Object.assign({ params: {} }, queryId)
  }

  t.test('should set the id param', t => {
    setup()

    service.byId('123')
    t.equal(service.params.id, '123')
    t.end()
  })

  t.test('should throw if id is missing', t => {
    t.throws(() => service.byId(), /Parameter `id` is missing/)
    t.end()
  })

})
