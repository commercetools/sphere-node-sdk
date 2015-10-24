import test from 'tape'
import createService from '../../lib/utils/create-service'

const fakeService = {
  type: 'test',
  endpoint: '/test',
  features: [
    'read',
    'create',
    'update',
    'delete',
    'query',
    'queryOne',
    'queryExpand',
    'queryString',
    'search',
    'projection'
  ]
}

test('Utils::createService', t => {

  t.test('should create a fully service', t => {
    const service = createService(fakeService)({})

    t.ok(service.withCredentials)
    t.ok(service.withHeader)
    t.ok(service.where)
    t.ok(service.whereOperator)
    t.ok(service.sort)
    t.ok(service.page)
    t.ok(service.perPage)
    t.ok(service.byId)
    t.ok(service.expand)
    t.ok(service.text)
    t.ok(service.facet)
    t.ok(service.filter)
    t.ok(service.filterByQuery)
    t.ok(service.filterByFacets)
    t.ok(service.staged)
    t.ok(service.byQueryString)
    t.ok(service.fetch)
    t.ok(service.create)
    t.ok(service.update)
    t.ok(service.delete)
    t.end()
  })

  t.test('should throw if config is missing', t => {
    t.throws(() => createService(),
      /Cannot create a service without a `config`/)
    t.end()
  })

  t.test('should throw if config parameters are missing', t => {
    t.throws(() => createService({ type: 'foo' }),
     /Object `config` is missing required parameters/)

    t.throws(() => createService({ type: 'foo', endpoint: '/foo' }),
      /Object `config` is missing required parameters/)

    t.throws(() => createService({
      type: 'foo', endpoint: '/foo', options: {} }),
      /Object `config` is missing required parameters/)
    t.end()
  })
})
