import test from 'tape'
import * as query from '../../lib/utils/query'
import { getDefaultQueryParams } from '../../lib/utils/default-params'

test('Utils::query', t => {

  let service

  function setup () {
    service = Object.assign({ params: getDefaultQueryParams() }, query)
  }

  t.test('should set the where param', t => {
    setup()

    service.where('name(en = "Foo Bar")')
    t.deepEqual(service.params.query.where, [
      encodeURIComponent('name(en = "Foo Bar")')
    ])
    t.end()
  })

  t.test('should throw if predicate is missing', t => {
    setup()

    t.throws(() => service.where(), /Parameter `predicate` is missing/)
    t.end()
  })

  t.test('should set the whereOperator param', t => {
    setup()

    service.whereOperator('or')
    t.equal(service.params.query.operator, 'or')

    service.whereOperator('and')
    t.equal(service.params.query.operator, 'and')
    t.end()
  })

  t.test('should throw if whereOperator is missing', t => {
    setup()

    t.throws(() => service.whereOperator(),
      /Parameter `operator` is missing/)
    t.end()
  })

  t.test('should throw if whereOperator is wrong', t => {
    setup()

    t.throws(() => service.whereOperator('foo'),
      /Parameter `operator` is wrong, either `and` or `or`/)
    t.end()
  })

})
