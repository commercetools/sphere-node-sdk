/* @flow */
import type {
  Action,
  Reducer,
  ActionHandlers,
} from '../types'

export default function createReducer<T> (
  initialState: T,
  actionHandlers: ActionHandlers<T, Action>
) : Reducer<T, Action> {
  return (state: T, action: Action) : T => {
    let newState = state
    if (!newState) newState = initialState

    if (!action || !action.type) return newState

    const actionType: string = action.type
    const reduce = actionHandlers[actionType]
    if (!reduce) return newState

    return {
      ...newState,
      ...reduce(newState, action),
    }
  }
}
