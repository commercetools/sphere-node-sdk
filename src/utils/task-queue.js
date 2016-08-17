import async from 'async'
import httpFn from './http'
import * as authUtils from './auth'
import handleResponse from './handle-response'

/**
 * Given `SphereClient` options, initialize a `queue` to programmatically
 * process requests generated from the `SphereClient` services.
 * Features:
 * - the `queue` has a concurrency limit (`maxParallel`).
 * - if the `accessToken` needs to be retrieved, the `queue` will block
 *   until the token is available
 * - failed requests will be automatically re-scheduled (can be configured)
 *
 * @example
 *
 * ```js
 * const url = 'https://api.sphere.io/foo/bar'
 * const task1 = queue.addTask({ method: 'GET', url })
 * const task2 = queue.addTask({ method: 'POST', url, body: {...} })
 * Promise.all([task1, task2]).then()
 * ```
 *
 * @param  {Object} options
 * @return {Object} An object with a `addTask` function.
 */
export default options => {
  // TODO: validate options
  const { Promise, auth, request } = options
  const http = httpFn(options)

  /**
   * Execute the given task and call the `cb` when done.
   *
   * @param  {Object}   task - It contains `fn`, `resolve`, `reject` which are
   * used to resolve and wrap the Promise.
   * @param  {Function} cb
   */
  function execTask (task, cb) {
    return handleResponse(http, task.description)
    .then(res => {
      task.resolve(res)
      cb()
    })
    .catch(err => {
      task.reject(err)
      cb(err)
    })
  }

  // TODO: make sure access token is retrieved
  // before the queue starts to process the tasks.
  const queue = async.queue((task, cb) => {
    auth.shouldRetrieveToken(shouldRetrieve => {
      if (shouldRetrieve)
        if (auth.accessToken) execTask(task, cb)
        else {
          queue.pause()

          authUtils.getAccessToken(options)
          .then(({ body }) => {
            // TODO: use a setter
            options.auth.accessToken = body.access_token // eslint-disable-line
            execTask(task, cb)
            queue.resume()
          })
          .catch(error => {
            // TODO: also resume the queue??
            task.reject(error)
            cb(error)
          })
        }
      else execTask(task, cb)
    })
  }, request.maxParallel)


  const taskQueue = {
    addTask (description) {
      return new Promise((resolve, reject) => {
        queue.push({ resolve, reject, description })
      })
    },
  }

  if (process.env.NODE_ENV === 'test')
    taskQueue.getQueue = () => queue

  return taskQueue
}
