import chai, { expect } from 'chai'
import sinon from 'sinon'
import sinonChai from 'sinon-chai'
import taskQueueFn from '../../lib/utils/task-queue'
import credentials from '../../config'

chai.use(sinonChai)

describe('Integration - TaskQueue token retrieval', () => {

  let options, taskQueue

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
        headers: {},
        maxParallel: 20,
        timeout: 20000
      }
    }
  })

  it('should request a new token before processing the task', done => {
    taskQueue = taskQueueFn(options)
    const _queue = taskQueue.getQueue()
    sinon.spy(_queue, 'pause')
    sinon.spy(_queue, 'resume')

    const projectKey = options.auth.credentials.projectKey
    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}/product-projections`
    })

    task.then(res => {
      expect(_queue.pause).to.have.been.calledOnce
      expect(_queue.resume).to.have.been.calledOnce
      expect(options.auth.accessToken).to.be.a('string')
      expect(res).to.have.property('ok', true)
      done()
    })
    .catch(done)
  })

  it('should fail to request a new token if credentials are wrong', done => {
    taskQueue = taskQueueFn(Object.assign({}, options, {
      auth: Object.assign({}, options.auth, {
        credentials: {
          projectKey: 'foo',
          clientId: '123',
          clientSecret: 'secret'
        }
      })
    }))
    const _queue = taskQueue.getQueue()
    sinon.spy(_queue, 'pause')
    sinon.spy(_queue, 'resume')

    const projectKey = options.auth.credentials.projectKey
    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}/product-projections`
    })
    task.then(() => {
      done('Should have failed')
    })
    .catch(e => {
      expect(_queue.pause).to.have.been.calledOnce
      expect(_queue.resume).not.to.have.been.called
      expect(e).to.have.property('error', 'invalid_client')
      expect(e).to.have.property('error_description',
        'Please provide valid client credentials using ' +
        'HTTP Basic Authentication.')
      done()
    })
  })

})
