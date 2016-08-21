import test from 'tape'
import sinon from 'sinon'
import taskQueueFn from '../../src/utils/task-queue'

test('Utils::taskQueue', t => {
  let options

  function setup () {
    options = {
      Promise: Promise, // eslint-disable-line object-shorthand
      request: {
        maxParallel: 20,
      },
    }
  }

  t.test('should expose public getter', t => {
    setup()

    const taskQueue = taskQueueFn(options)
    t.equal(typeof taskQueue.addTask, 'function')
    t.end()
  })

  t.test('should add a task to the queue', t => {
    setup()

    const taskQueue = taskQueueFn(Object.assign({}, options, {
      auth: {
        shouldRetrieveToken (cb) { cb(false) },
      },
    }))

    const _queue = taskQueue.getQueue()
    const spy = sinon.stub(_queue, 'push', payload => payload.resolve('ok'))

    const task = {
      method: 'GET',
      url: 'https://api.sphere.io/foo',
    }
    const taskFn = taskQueue.addTask(task)
    taskFn.then(res => {
      const call = spy.getCall(0).args[0]
      t.equal(typeof call.resolve, 'function')
      t.equal(typeof call.reject, 'function')
      t.deepEqual(call.description, task)
      t.equal(res, 'ok')
      t.end()
    })
    .catch(t.end)
  })

  t.test('should renew access token before it expires', t => {
    const fetchResponseMock = (status, body) => Promise.resolve({
      headers: {},
      status,
      ok: status === 200,
      json: () => Promise.resolve(body),
      text: () => Promise.resolve(JSON.stringify(body)),
    })

    let apiCalls = 0
    const httpMock = (url, fetchOptions) => {
      if (url === 'https://test_client:test_secret@auth.sphere.io/oauth/token') // eslint-disable-line
        return fetchResponseMock(200, {
          access_token: `token${apiCalls}`,
          expires_in: 2 * 60 * 60 - 1, // 1h59m59s
          scope: 'manage_project:test',
          token_type: 'Bearer',
        })

      const { Authorization } = fetchOptions.headers
      const result = Authorization === `Bearer token${apiCalls}` ?
        fetchResponseMock(200, { foo: 'bar' }) :
        fetchResponseMock(401, { error: 'Invalid token' })

      // A token is only valid for one api call.
      // All returned tokens expire in 1h59m59s.
      // The client implementation should request a new token if
      // the token expires in less than 2 hours, ie
      // it should use a new token for every api call.
      apiCalls++

      return result
    }

    options = {
      Promise: Promise, // eslint-disable-line object-shorthand
      auth: {
        credentials: {
          clientId: 'test_client',
          clientSecret: 'test_secret',
          projectKey: 'test_project',
        },
        shouldRetrieveToken (cb) { cb(true) },
        host: 'auth.sphere.io',
      },
      request: {
        maxParallel: 20,
        headers: {},
        host: 'api.sphere.io',
        protocol: 'https',
      },
      httpMock,
    }

    const taskQueue = taskQueueFn(options)

    const task = {
      method: 'GET',
      url: 'https://api.sphere.io/foo',
    }

    taskQueue.addTask(task)
      .then(res => {
        t.deepEqual(res.body, { foo: 'bar' })

        return taskQueue.addTask(task)
          .then(res => {
            t.deepEqual(res.body, { foo: 'bar' })
            t.end()
          })
      })
      .catch(t.end)
  })
})
