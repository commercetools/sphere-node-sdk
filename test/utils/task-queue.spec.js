import { expect } from 'chai'
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
      expect(taskQueue.addTask).to.be.a('function')
    })

    it('should add a task to the queue', done => {
      const taskQueue = taskQueueFn(Object.assign({}, options, {
        auth: {
          shouldRetrieveToken (cb) { cb(false) }
        }
      }))
      const task = taskQueue.addTask(() => {
        return new Promise(resolve => {
          resolve('ok')
        })
      })
      task.then(res => {
          expect(res).to.equal('ok')
          done()
        })
        .catch(done)
    })

  })
})
