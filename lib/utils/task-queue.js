import * as authUtils from './auth'
import httpFn from './http'

function getAccessToken (options) {
  const { credentials } = options.auth
  const authRequest = authUtils.buildRequest(credentials)
  const http = httpFn(Object.assign({}, options, {
    request: Object.assign({}, options.request, {
      headers: Object.assign({}, options.request.headers, {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': `${authRequest.body.length}`
      })
    })
  }))
  return http.post(authRequest.endpoint, authRequest.body)
}

// TODO: just a simple implementation for now
export default function taskQueue (options) {

  // TODO: validate options
  const { Promise, auth, request } = options
  let paused = false
  let activeCount = 0
  const queue = []

  function processTask (task) {
    activeCount += 1

    task.fn()
      .then(res => {
        task.resolve(res)
        activeCount -= 1
      })
      .catch(e => {
        // TODO: retry-mechanism
        task.reject(e)
      })
  }

  setInterval(() => {
    if (paused) return

    if (activeCount < request.maxParallel && queue.length > 0)
      auth.shouldRetrieveToken(shouldRetrieve => {
        if (shouldRetrieve)
          // TODO: make sure that token is not expired
          if (auth.accessToken)
            // continue
            processTask(queue.shift())
          else {
            // get an accessToken
            paused = true
            getAccessToken(options).then(res => res.json())
              .then(res => {
                options.auth.accessToken = res.access_token
                paused = false
              })
              .catch(e => { throw e })
          }
        // continue
        else processTask(queue.shift())
      })
  }, 100)

  return {
    addTask (taskFn) {
      return new Promise((resolve, reject) => {
        queue.push({ fn: taskFn, resolve, reject })
      })
    }
  }
}
