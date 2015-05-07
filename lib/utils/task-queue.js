import async from 'async'
import httpFn from './http'
import * as authUtils from './auth'
import * as events from './events'
import * as constants from './constants'

export default options => {

  // TODO: validate options
  const { Promise, auth, request } = options
  const http = httpFn(options)

  function execTask (task, cb) {
    task.fn()
      .then(res => {
        task.resolve(res)
        cb()
      })
      .catch(err => {
        task.reject(err)
        cb(err)
      })
  }

  const queue = async.queue((task, cb) => {
    auth.shouldRetrieveToken(shouldRetrieve => {
      if (shouldRetrieve)
        if (auth.accessToken) execTask(task, cb)
        else {
          queue.pause()
          authUtils.getAccessToken(options)
            .then(result => {
              options.auth.accessToken = result.access_token
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
    addTask (payload) {
      return new Promise((resolve, reject) => {
        // TODO: validate options
        const { method, url, body } = payload
        const taskFn = () => {
          switch (method) {
            case constants.get:
              return http.get(url)
            case constants.post:
              return http.post(url, body)
            case constants.delete:
              return http.delete(url)
          }
        }

        queue.push({ fn: taskFn, resolve, reject })
      })
    }
  }

  if (process.env.NODE_ENV === 'test')
    taskQueue.getQueue = () => { return queue }

  return taskQueue

}
