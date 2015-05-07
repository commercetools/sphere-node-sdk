import httpFn from './http'
import * as authUtils from './auth'
import * as events from './events'
import * as constants from './constants'

export default (dispatcher, options) => {

  // TODO: validate options
  const { Promise, auth, request } = options
  const http = httpFn(options)
  const queue = []
  let activeCount = 0

  dispatcher.addListener(events.enqueue, task => {
    queue.push(task)
    dispatcher.dispatch(events.pull)
  })

  dispatcher.addListener(events.pull, () => {
    // if the queue is full, the next task will be 'pulled'
    // once an active one finishes
    if (activeCount < request.maxParallel && queue.length > 0) {
      const taskToProcess = queue.shift()

      auth.shouldRetrieveToken(shouldRetrieve => {
        if (shouldRetrieve)
          // TODO: make sure that token is not expired
          if (auth.accessToken)
            dispatcher.dispatch(events.exec, taskToProcess)
          else {
            // get an accessToken
            dispatcher.pause()
            // will be propagated when dispatcher resumes
            dispatcher.dispatch(events.exec, taskToProcess)
            authUtils.getAccessToken(options)
              .then(result => {
                options.auth.accessToken = result.access_token
                dispatcher.resume()
              })
              .catch(error => taskToProcess.reject(error))
          }
        else
          dispatcher.dispatch(events.exec, taskToProcess)
      })

    }
  })

  dispatcher.addListener(events.exec, task => {
    activeCount += 1

    task.fn()
      .then(res => {
        task.resolve(res)
        activeCount -= 1
        dispatcher.dispatch(events.pull)
      })
      .catch(e => {
        // TODO: retry-mechanism
        task.reject(e)
        dispatcher.dispatch(events.pull)
      })
  })

  return {
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
        dispatcher.dispatch(events.enqueue, { fn: taskFn, resolve, reject })
      })
    }
  }

}
