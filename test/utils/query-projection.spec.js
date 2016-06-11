import test from 'tape'
import * as queryProjection from '../../lib/utils/query-projection'

test('Utils::queryProjection', t => {
  let service

  function setup () {
    service = Object.assign({ params: {} }, queryProjection)
  }

  t.test('should set the staged param', t => {
    setup()

    service.staged()
    t.true(service.params.staged)

    service.staged(false)
    t.false(service.params.staged)

    service.staged(true)
    t.true(service.params.staged)
    t.end()
  })
})
