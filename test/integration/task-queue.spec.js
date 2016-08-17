import test from 'tape'
import sinon from 'sinon'
import credentials from '../../credentials'
import taskQueueFn from '../../src/utils/task-queue'

test('Integration - TaskQueue token retrieval', t => {
  let options

  function setup () {
    options = {
      Promise: Promise, // eslint-disable-line object-shorthand
      auth: {
        credentials: {
          projectKey: credentials.project_key,
          clientId: credentials.client_id,
          clientSecret: credentials.client_secret,
        },
        shouldRetrieveToken (cb) { cb(true) },
        host: 'auth.sphere.io',
      },
      request: {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'sphere-node-sdk',
        },
        maxParallel: 20,
        timeout: 20000,
      },
    }
  }

  t.test('should request a new token before processing the task', t => {
    setup()

    const taskQueue = taskQueueFn(options)
    const _queue = taskQueue.getQueue()
    const pauseSpy = sinon.spy(_queue, 'pause')
    const resumeSpy = sinon.spy(_queue, 'resume')

    const projectKey = options.auth.credentials.projectKey
    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}/product-projections`,
    })

    task.then(({ statusCode }) => {
      t.true(pauseSpy.calledOnce)
      t.true(resumeSpy.calledOnce)
      t.equal(typeof options.auth.accessToken, 'string')
      t.equal(statusCode, 200)
      t.end()
    })
    .catch(t.end)
  })

  t.test('should fail to request a new token if credentials are wrong', t => {
    setup()

    const taskQueue = taskQueueFn(Object.assign({}, options, {
      auth: Object.assign({}, options.auth, {
        credentials: {
          projectKey: 'foo',
          clientId: '123',
          clientSecret: 'secret',
        },
      }),
    }))
    const _queue = taskQueue.getQueue()
    const pauseSpy = sinon.spy(_queue, 'pause')
    const resumeSpy = sinon.spy(_queue, 'resume')

    const projectKey = options.auth.credentials.projectKey
    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}/product-projections`,
    })
    task.then(() => t.end('Should have failed'))
    .catch(e => {
      t.true(pauseSpy.calledOnce)
      t.false(resumeSpy.called)
      t.equal(e.body.statusCode, 401)
      t.equal(e.body.error, 'invalid_client')
      t.equal(e.body.error_description, 'Please provide valid client ' +
        'credentials using HTTP Basic Authentication.')
      t.deepEqual(e.body.originalRequest, {
        url: 'https://123:secret@auth.sphere.io/oauth/token',
        method: 'POST',
        body: 'grant_type=client_credentials&scope=manage_project:foo',
      })
      t.ok(e.body.headers)
      t.end()
    })
    .catch(t.end)
  })
})
