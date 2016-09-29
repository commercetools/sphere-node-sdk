import test from 'tape'
import createService from 'utils/create-service'
import initStore from 'utils/init-store'
import SphereClient from 'index.js'

const {
  FEATURE_READ,
  FEATURE_CREATE,
  FEATURE_UPDATE,
  FEATURE_DELETE,
  FEATURE_QUERY,
  FEATURE_QUERY_ONE,
  FEATURE_QUERY_EXPAND,
  FEATURE_QUERY_STRING,
  FEATURE_SEARCH,
  FEATURE_PROJECTION,
} = SphereClient.constants

const fakeMiddleware = () => next => action => next(action)
const store = initStore({
  projectKey: 'test',
  oauth: {
    token: 'foo',
    expiresIn: 100,
  },
  middlewares: [fakeMiddleware],
})

test('Utils::createService', (t) => {
  t.test('should create a fully service', (t) => {
    const service = createService({
      type: 'foo',
      endpoint: '/foo',
      features: [
        FEATURE_READ,
        FEATURE_CREATE,
        FEATURE_UPDATE,
        FEATURE_DELETE,
        FEATURE_QUERY,
        FEATURE_QUERY_ONE,
        FEATURE_QUERY_EXPAND,
        FEATURE_QUERY_STRING,
        FEATURE_SEARCH,
        FEATURE_PROJECTION,
      ],
    }, store)

    t.equal(service.type, 'foo', 'has type')
    t.deepEqual(service.features,
      [
        FEATURE_READ,
        FEATURE_CREATE,
        FEATURE_UPDATE,
        FEATURE_DELETE,
        FEATURE_QUERY,
        FEATURE_QUERY_ONE,
        FEATURE_QUERY_EXPAND,
        FEATURE_QUERY_STRING,
        FEATURE_SEARCH,
        FEATURE_PROJECTION,
      ],
      'has features list'
    )
    t.deepEqual(service.store, store, 'has reference to store')

    // Helpers
    t.equal(typeof service.withProject, 'function', 'has withProject')
    t.equal(typeof service.withToken, 'function', 'has withToken')

    // Feature (read)
    t.equal(typeof service.fetch, 'function', 'has fetch')

    // Feature (create)
    t.equal(typeof service.create, 'function', 'has create')

    // Feature (update)
    t.equal(typeof service.update, 'function', 'has update')

    // Feature (delete)
    t.equal(typeof service.delete, 'function', 'has delete')

    // Feature (query)
    t.equal(typeof service.where, 'function', 'has where')
    t.equal(typeof service.whereOperator, 'function', 'has whereOperator')
    t.equal(typeof service.sort, 'function', 'has sort')
    t.equal(typeof service.page, 'function', 'has page')
    t.equal(typeof service.perPage, 'function', 'has perPage')

    // Feature (query one)
    t.equal(typeof service.byId, 'function', 'has byId')

    // Feature (query expand)
    t.equal(typeof service.expand, 'function', 'has expand')

    // Feature (query string)
    t.equal(typeof service.byQueryString, 'function', 'has byQueryString')

    // Feature (search)
    t.equal(typeof service.text, 'function', 'has text')
    t.equal(typeof service.fuzzy, 'function', 'has fuzzy')
    t.equal(typeof service.facet, 'function', 'has facet')
    t.equal(typeof service.filter, 'function', 'has filter')
    t.equal(typeof service.filterByQuery, 'function', 'has filterByQuery')
    t.equal(typeof service.filterByFacets, 'function', 'has filterByFacets')

    // Feature (projection)
    t.equal(typeof service.staged, 'function', 'has staged')

    t.end()
  })

  t.test('should throw if config is missing', (t) => {
    t.throws(() => createService(),
      /Cannot create a service without a `config`/)
    t.end()
  })

  t.test('should throw if config parameters are missing', (t) => {
    // Missing type, endpoint, features
    t.throws(() => createService({}),
     /Object `config` is missing required parameters/)

    // Missing endpoint, features
    t.throws(() => createService({ type: 'foo' }),
     /Object `config` is missing required parameters/)

    // Missing features
    t.throws(() => createService({ type: 'foo', endpoint: '/foo' }),
      /Object `config` is missing required parameters/)

    t.throws(() => createService({
      type: 'foo', endpoint: '/foo', features: [] }),
      /There should be at least 1 feature listed/)
    t.end()
  })
})
