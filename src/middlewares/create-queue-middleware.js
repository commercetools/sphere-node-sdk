/* @flow */
import type {
  Middleware,
  Dispatch,
} from 'redux'
import { TASK } from '../constants'

// Note: this middleware should go before any other middleware that handle
// the `TASK` action.

// TODO: define queueMiddleware type with options

export default function createQueueMiddleware (options: Object): Middleware {
  const {
    maxConcurrency = 20,
  } = options || {}

  return function queueMiddleware (/* middlewareAPI */) {
    const queue = []
    let runningCount = 0

    // This function is called when a previous task has been resolved. If there
    // are any other pending tasks, dispatch them and check for other pending
    // tasks after those have been resolved.
    // Note: it's necessary that middlewares after the queue middleware
    // return a promise, so that it's clear when to dequeue new pending tasks.
    function dequeue (next: Dispatch) {
      runningCount--

      if (queue.length && runningCount <= maxConcurrency) {
        const nextAction = queue.shift()
        runningCount++
        // TODO: not sure this is the best way of doing this.
        // It seems very fragile.
        return next(nextAction).then(() => dequeue(next))
      }

      return null
    }

    return next => action => {
      if (action.type === TASK) {
        queue.push(action)

        // If possible, run the tasks straight away.
        if (runningCount <= maxConcurrency) {
          const nextAction = queue.shift()
          runningCount++

          return next(nextAction).then(() => dequeue(next))
        }

        return null
      }

      // // If a previous running tasks has been completed, remove it from
      // // the queue and check another pending task can be run.
      // if (action.type === TASK_SUCCESS || action.type === TASK_ERROR) {
      //   runningCount--
      //   const result = next(action)

      //   if (queue.length && runningCount <= maxConcurrency) {
      //     const nextAction = queue.shift()
      //     runningCount++
      //     return next(nextAction)
      //   }

      //   return result
      // }

      return next(action)
    }
  }
}
