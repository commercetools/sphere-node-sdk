import sinon from 'sinon'
import expect from 'expect'
import taskQueueFn from '../../lib/utils/task-queue'

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
      expect(taskQueue.addTask).toBeA('function')
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

      const task = {
        method: 'GET',
        url: 'https://api.sphere.io/foo'
      }
      const taskFn = taskQueue.addTask(task)
      taskFn.then(res => {
        const call = spy.getCall(0).args[0]
        expect(call.resolve).toBeA('function')
        expect(call.reject).toBeA('function')
        expect(call.description).toEqual(task)
        expect(res).toEqual('ok')
        done()
      })
      .catch(done)
    })

  })
})
