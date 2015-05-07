import chai, { expect } from 'chai'
import sinon from 'sinon'
import sinonChai from 'sinon-chai'
import Dispatcher from '../../lib/client/dispatcher'
import taskQueueFn from '../../lib/utils/task-queue'
import credentials from '../../config'

chai.use(sinonChai)

describe('Integration - TaskQueue token retrieval', () => {

  let options, taskQueue, dispatcher

  beforeEach(() => {
    dispatcher = new Dispatcher()
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
    sinon.spy(dispatcher, 'pause')
    sinon.spy(dispatcher, 'resume')
    taskQueue = taskQueueFn(dispatcher, options)

    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${options.auth.credentials.projectKey}/product-projections`
    })

    task.then(res => {
        expect(dispatcher.pause).to.have.been.calledOnce
        expect(dispatcher.resume).to.have.been.calledOnce
        expect(options.auth.accessToken).to.be.a('string')
        expect(res).to.have.property('ok', true)
        done()
      })
      .catch(done)
  })

  it('should fail to request a new token if credentials are wrong', done => {
    sinon.spy(dispatcher, 'pause')
    sinon.spy(dispatcher, 'resume')
    taskQueue = taskQueueFn(dispatcher, Object.assign({}, options, {
      auth: Object.assign({}, options.auth, {
        credentials: {
          projectKey: 'foo',
          clientId: '123',
          clientSecret: 'secret'
        }
      })
    }))

    const task = taskQueue.addTask({
      method: 'GET',
      url: `https://api.sphere.io/${options.auth.credentials.projectKey}/product-projections`
    })
    task.then(() => {
        done('Should have failed')
      })
      .catch(e => {
        expect(dispatcher.pause).to.have.been.calledOnce
        expect(dispatcher.resume).not.to.have.been.called
        expect(e).to.have.property('error', 'invalid_client')
        expect(e).to.have.property('error_description',
          'Please provide valid client credentials using ' +
          'HTTP Basic Authentication.')
        done()
      })
  })

})
