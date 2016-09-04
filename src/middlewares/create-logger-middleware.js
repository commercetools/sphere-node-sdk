// import createLogger from 'redux-logger'

export default function createLoggerMiddleware (/* options = {} */) {
  return (/* middlewareAPI */) => next => action => {
    if (
      action.type !== 'SERVICE_INIT'
    )
      console.log(action)
    return next(action)
  }
}
