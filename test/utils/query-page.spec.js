import test from 'tape'
import * as queryPage from '../../lib/utils/query-page'
import { getDefaultQueryParams } from '../../lib/utils/default-params'

test('Utils::queryPage', t => {
  let service

  function setup () {
    service = Object.assign({ params: getDefaultQueryParams() }, queryPage)
  }

  t.test('should set the sort param (asc)', t => {
    setup()

    service.sort('createdAt')
    t.deepEqual(service.params.pagination.sort, [
      encodeURIComponent('createdAt asc'),
    ])
    t.end()
  })

  t.test('should set the sort param (desc)', t => {
    setup()

    service.sort('createdAt', false)
    t.deepEqual(service.params.pagination.sort, [
      encodeURIComponent('createdAt desc'),
    ])
    t.end()
  })

  t.test('should throw if sortPath is missing', t => {
    setup()

    t.throws(() => service.sort(),
      /Required argument for `sort` is missing/)
    t.end()
  })

  t.test('should set the page param', t => {
    setup()

    service.page(5)
    t.equal(service.params.pagination.page, 5)
    t.end()
  })

  t.test('should throw if page is missing', t => {
    setup()

    t.throws(() => service.page(),
      /Required argument for `page` is missing/)
    t.end()
  })

  t.test('should throw if page is a number < 1', t => {
    setup()

    t.throws(() => service.page(0),
      /Required argument for `page` must be a number >= 1/)
    t.end()
  })

  t.test('should set the perPage param', t => {
    setup()

    service.perPage(40)
    t.equal(service.params.pagination.perPage, 40)

    service.perPage(0)
    t.equal(service.params.pagination.perPage, 0)

    t.end()
  })

  t.test('should throw if perPage is missing', t => {
    setup()

    t.throws(() => service.perPage(),
      /Required argument for `perPage` is missing/)
    t.end()
  })

  t.test('should throw if perPage is a number < 1', t => {
    setup()

    t.throws(() => service.perPage(-1),
      /Required argument for `perPage` must be a number >= 0/)
    t.end()
  })
})
