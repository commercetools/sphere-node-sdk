import test from 'tape'
import credentials from '../../credentials'
import SphereClient, {
  createAuthMiddleware,
  createHttpMiddleware,
  createErrorMiddleware,
  createQueueMiddleware,
  createLoggerMiddleware,
} from '../../src'

test('Middlewares', (t) => {
  const options = {
    projectKey: credentials.project_key,
    middlewares: [
      createQueueMiddleware({
        maxConcurrency: 1,
      }),
      createAuthMiddleware({
        clientId: credentials.client_id,
        clientSecret: credentials.client_secret,
      }),
      createHttpMiddleware(),
      createErrorMiddleware(),
      createLoggerMiddleware(),
    ],
  }

  const client = SphereClient.create(options)

  Promise.all([
    client.getService('product-projections').perPage(0).fetch(),
    client.getService('categories').perPage(0).fetch(),
    client.getService('product-types').where('foo=bar').fetch(),
    // client.getService('product-projections').perPage(0).fetch(),
    // client.getService('categories').perPage(0).fetch(),
    // client.getService('product-types').perPage(0).fetch(),
    // client.getService('product-projections').perPage(0).fetch(),
    // client.getService('categories').perPage(0).fetch(),
    // client.getService('product-types').perPage(0).fetch(),
    // client.getService('product-projections').perPage(0).fetch(),
    // client.getService('categories').perPage(0).fetch(),
    // client.getService('product-types').perPage(0).fetch(),
  ])
  .then((result) => {
    console.log('result', result)
    t.end()
  })
  .catch((error) => {
    console.log('error', error)
    t.end()
  })
})
