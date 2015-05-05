import { expect } from 'chai'
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
        maxParallel: 20,
        timeout: 20000
      }
    }
  })

  it('should request a new token before processing the task', done => {
    const taskQueue = taskQueueFn(options)
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

})
