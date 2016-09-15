/* @flow */
import type {
  Action,
  RequestState,
  ActionHandlers,
} from '../types'
import createReducer from '../utils/create-reducer'
import {
  REQUEST_TOKEN,
  REQUEST_PROJECT_KEY,
} from '../constants'

const initialState: RequestState = {
  projectKey: null,
  token: null,
  expiresIn: null,
}

const actionHandlers: ActionHandlers<RequestState, Action> = {
  [REQUEST_TOKEN]: (
    state: RequestState,
    action: Action
  ): RequestState => ({
    ...state,
    token: action.payload.token,
    expiresIn: action.payload.expiresIn,
  }),
  [REQUEST_PROJECT_KEY]: (
    state: RequestState,
    action: Action
  ): RequestState => ({
    ...state,
    projectKey: action.payload,
  }),
}

export default createReducer(initialState, actionHandlers)
