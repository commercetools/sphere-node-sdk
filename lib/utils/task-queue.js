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
  const queue = []
  let paused = false
  let activeCount = 0
  let interval

  function execTask (task) {
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

  function processTask (task) {
    auth.shouldRetrieveToken(shouldRetrieve => {
      if (shouldRetrieve)
        // TODO: make sure that token is not expired
        if (auth.accessToken)
          // continue
          execTask(task)
        else {
          // get an accessToken
          paused = true
          getAccessToken(options)
            .then(res => {
              // TODO: better error handling!
              if (res.ok)
                res.json().then(result => {
                  options.auth.accessToken = result.access_token
                  paused = false
                  execTask(task)
                })
              else
                if (res.headers.has('content-type') &&
                  new RegExp(/application\/json/)
                    .test(res.headers.get('content-type')))
                  res.json().then(e => { task.reject(e) })
                else
                  res.text().then(e => { task.reject(e) })
            })
            .catch(e => { task.reject(e) })
        }
      // continue
      else execTask(task)
    })
  }

  function tick () {
    if (paused) return

    if (activeCount < request.maxParallel && queue.length > 0)
      processTask(queue.shift())
  }

  interval = setInterval(tick, 200)

  return {
    addTask (taskFn) {
      return new Promise((resolve, reject) => {
        queue.push({ fn: taskFn, resolve, reject })
      })
    },
    resume () { interval = setInterval(tick, 200) },
    destroy () { clearInterval(interval) }
  }
}
