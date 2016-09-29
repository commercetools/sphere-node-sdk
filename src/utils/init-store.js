import { createStore, compose, applyMiddleware } from 'redux'
import reducers from '../reducers'

/**
 * Initialize the client `store` with the related middlewares.
 * This should be invoked once per client instance.
 *
 * @param  {Object} options - the options passed to the client
 * to setup the store and the middlewares.
 * @return {Object} The redux store.
 */
export default function initStore (options = {}) {
  const {
    projectKey,
    oauth = {
      token: undefined,
      expiresIn: undefined,
    },
    // TODO: document the contract of the middlewares:
    // - the order is important
    // - what are the action types important for the middlewares
    // - when to use `next` and `dispatch`
    middlewares = [],
  } = options

  if (!middlewares.length)
    // TODO: link to middlewares documentation
    throw new Error('No middlewares found.')

  const initialState = {
    request: { projectKey, ...oauth },
  }

  const finalCreateStore = compose(
    applyMiddleware(...middlewares)
  )(createStore)

  return finalCreateStore(reducers, initialState)
}
