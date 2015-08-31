import sinon from 'sinon'
import expect from 'expect'
import taskQueueFn from '../../lib/utils/task-queue'
import credentials from '../../config'

describe('Integration - TaskQueue token retrieval', () => {

  let options

  beforeEach(() => {
    options = {
      Promise: Promise,
      auth: {
        credentials: {
          projectKey: credentials.project_key,
          clientId: credentials.client_id,
          clientSecret: credentials.client_secret
        },
        shouldRetrieveToken (cb) { cb(true) }
      },
      request: {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'sphere-node-sdk.2.0'
        },
        maxParallel: 20,
        timeout: 20000
      }
    }
  })

  it('should request a new token before processing the task', done => {
    const taskQueue = taskQueueFn(options)
    const _queue = taskQueue.getQueue()
    const pauseSpy = sinon.spy(_queue, 'pause')
    const resumeSpy = sinon.spy(_queue, 'resume')

    const projectKey = options.auth.credentials.projectKey
    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}/product-projections`
    })

    task.then(({ statusCode }) => {
      expect(pauseSpy.calledOnce).toBe(true)
      expect(resumeSpy.calledOnce).toBe(true)
      expect(options.auth.accessToken).toBeA('string')
      expect(statusCode).toBe(200)
      done()
    })
    .catch(done)
  })

  it('should fail to request a new token if credentials are wrong', done => {
    const taskQueue = taskQueueFn(Object.assign({}, options, {
      auth: Object.assign({}, options.auth, {
        credentials: {
          projectKey: 'foo',
          clientId: '123',
          clientSecret: 'secret'
        }
      })
    }))
    const _queue = taskQueue.getQueue()
    const pauseSpy = sinon.spy(_queue, 'pause')
    const resumeSpy = sinon.spy(_queue, 'resume')

    const projectKey = options.auth.credentials.projectKey
    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}/product-projections`
    })
    task.then(() => done('Should have failed'))
    .catch(e => {
      expect(pauseSpy.calledOnce).toBe(true)
      expect(resumeSpy.called).toBe(false)
      expect(e.body).toEqual({
        statusCode: 401,
        error: 'invalid_client',
        'error_description': 'Please provide valid client credentials ' +
          'using HTTP Basic Authentication.',
        originalRequest: {
          url: 'https://123:secret@auth.sphere.io/oauth/token',
          method: 'POST',
          body: 'grant_type=client_credentials&scope=manage_project:foo'
        }
      })
      done()
    })
  })

})
