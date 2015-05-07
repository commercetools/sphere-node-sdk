import chai, { expect } from 'chai'
import sinon from 'sinon'
import sinonChai from 'sinon-chai'
import taskQueueFn from '../../lib/utils/task-queue'
import * as constants from '../../lib/utils/constants'

chai.use(sinonChai)

describe('Utils', () => {

  describe('::taskQueue', () => {

    let options

    beforeEach(() => {
      options = {
        Promise: Promise,
        request: {
          maxParallel: 20
        }
      }
    })

    it('should expose public getter', () => {
      const taskQueue = taskQueueFn(options)
      expect(taskQueue.addTask).to.be.a('function')
    })

    it('should add a task to the queue', done => {
      const taskQueue = taskQueueFn(Object.assign({}, options, {
        auth: {
          shouldRetrieveToken (cb) { cb(false) }
        }
      }))

      const _queue = taskQueue.getQueue()
      const spy = sinon.stub(_queue, 'push', payload => {
        return payload.resolve('ok')
      })

      const task = taskQueue.addTask({
        method: constants.get,
        url: 'https://api.sphere.io/foo'
      })
      task.then(res => {
          expect(spy.getCall(0).args[0]).to.have.property('fn').that.is.a('function')
          expect(spy.getCall(0).args[0]).to.have.property('resolve').that.is.a('function')
          expect(spy.getCall(0).args[0]).to.have.property('reject').that.is.a('function')
          expect(res).to.equal('ok')
          done()
        })
        .catch(done)
    })

  })
})
