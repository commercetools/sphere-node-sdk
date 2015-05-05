import { expect } from 'chai'
import taskQueueFn from '../../lib/utils/task-queue'
import credentials from '../../config'

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
        maxParallel: 20,
        timeout: 20000
      }
    }
  })

  afterEach(() => {
    taskQueue.destroy()
  })

  it('should request a new token before processing the task', done => {
    taskQueue = taskQueueFn(options)
    const task = taskQueue.addTask(() => {
      return new Promise(resolve => {
        resolve('ok')
      })
    })
    task.then(res => {
        expect(options.auth.accessToken).to.be.a('string')
        expect(res).to.equal('ok')
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
    const task = taskQueue.addTask(() => {
      return new Promise(resolve => {
        resolve('ok')
      })
    })
    task.then(() => {
        done('Should have failed')
      })
      .catch(e => {
        expect(e).to.have.property('error', 'invalid_client')
        expect(e).to.have.property('error_description',
          'Please provide valid client credentials using ' +
          'HTTP Basic Authentication.')
        done()
      })
  })

})
