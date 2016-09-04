import createReducer from '../utils/create-reducer'
import {
  REQUEST_TOKEN,
  REQUEST_PROJECT_KEY,
} from '../constants'

const initialState = {
  projectKey: null,
  token: null,
  expiresIn: null,
}

const actionHandlers = {
  [REQUEST_TOKEN]: (state, { payload }) => ({
    token: payload['access_token'],
    expiresIn: payload['expires_in'],
  }),
  [REQUEST_PROJECT_KEY]: (state, { payload }) => ({ projectKey: payload }),
}

export default createReducer(initialState, actionHandlers)
