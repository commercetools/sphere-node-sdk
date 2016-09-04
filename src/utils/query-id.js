/**
 * Utils `query-id` module.
 * @module utils/queryId
 */
import { SERVICE_PARAM_ID } from '../constants'

/**
 * Set the given `id` to the internal state of the service instance.
 *
 * @param  {string} id - A resource `UUID`
 * @throws If `id` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function byId (id) {
  if (!id)
    throw new Error('Required argument for `byId` is missing')

  // this.params.id = id
  this.store.dispatch({
    type: SERVICE_PARAM_ID,
    meta: { service: this.type },
    payload: id,
  })
  return this
}
