import test from 'tape'
import createGraphQLService from 'utils/create-graphql-service'
import initStore from 'utils/init-store'

const fakeMiddleware = () => next => action => next(action)
const store = initStore({
  projectKey: 'test',
  oauth: {
    token: 'foo',
    expiresIn: 100,
  },
  middlewares: [fakeMiddleware],
})

test('Utils::createGraphQLService', (t) => {
  t.test('should create a fully service', (t) => {
    const service = createGraphQLService(store)

    t.equal(service.type, 'graphql', 'has type')
    t.deepEqual(service.store, store, 'has reference to store')

    // Helpers
    t.equal(typeof service.withProject, 'function', 'has withProject')
    t.equal(typeof service.withToken, 'function', 'has withToken')

    // Feature (query)
    t.equal(typeof service.query, 'function', 'has query')

    t.end()
  })
})
