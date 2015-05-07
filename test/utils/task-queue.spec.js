import chai, { expect } from 'chai'
import sinon from 'sinon'
import sinonChai from 'sinon-chai'
import Dispatcher from '../../lib/client/dispatcher'
import taskQueueFn from '../../lib/utils/task-queue'

chai.use(sinonChai)

describe('Utils', () => {

  describe('::taskQueue', () => {

    let options, dispatcher

    beforeEach(() => {
      dispatcher = new Dispatcher()
      options = {
        Promise: Promise,
        request: {
          maxParallel: 20
        }
      }
    })

    it('should expose public getter', () => {
      const taskQueue = taskQueueFn(dispatcher, options)
      expect(taskQueue.addTask).to.be.a('function')
    })

    it('should add a task to the queue', done => {
      const spy = sinon.stub(dispatcher, 'dispatch', (event, payload) => {
        payload.resolve('ok')
      })
      const taskQueue = taskQueueFn(dispatcher, Object.assign({}, options, {
        auth: {
          shouldRetrieveToken (cb) { cb(false) }
        }
      }))

      const task = taskQueue.addTask({
        method: 'GET',
        url: 'https://api.sphere.io/foo'
      })
      task.then(res => {
          expect(spy.getCall(0).args[0]).to.equal('enqueue')
          expect(spy.getCall(0).args[1]).to.have.property('fn').that.is.a('function')
          expect(spy.getCall(0).args[1]).to.have.property('resolve').that.is.a('function')
          expect(spy.getCall(0).args[1]).to.have.property('reject').that.is.a('function')
          expect(dispatcher.dispatch).to.have.been.calledOnce
          expect(res).to.equal('ok')
          done()
        })
        .catch(done)
    })

  })
})
