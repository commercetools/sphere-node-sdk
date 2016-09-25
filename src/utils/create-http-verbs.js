import {
  TASK,
  HTTP_FETCH,
  HTTP_CREATE,
  HTTP_UPDATE,
  HTTP_DELETE,
  SERVICE_PARAMS_RESET,
} from '../constants'

export default function createHttpVerbs (promiseLibrary) {
  const Promise = promiseLibrary
  return {
    /**
     * Fetch a resource defined by the `service` with all related
     * query parameters.
     *
     * @return {Promise} A `task` promise that will eventually be resolved.
     *
     * @example
     *
     * ```js
     * service = client.productProjections
     * service.where('name(en = "Foo")').sort('createdAt desc').fetch()
     * .then()
     * .catch()
     * ```
     */
    fetch () {
      const { type, store } = this
      const { service: { [type]: serviceState } } = store.getState()

      store.dispatch({ type: SERVICE_PARAMS_RESET, meta: { service: type } })
      return new Promise((resolve, reject) => {
        try {
          store.dispatch({
            type: TASK,
            meta: {
              source: HTTP_FETCH,
              promise: { resolve, reject },
              service: type,
              serviceState,
            },
          })
        } catch (error) {
          reject(error)
        }
      })
    },

    /**
     * Create a resource defined by the `service`.
     *
     * @param  {Object} body - The payload described by the related
     * API resource.
     * @throws If `body` is missing.
     * @return {Promise} A `task` promise that will eventually be resolved.
     *
     * @example
     *
     * ```js
     * service = client.products
     * service.create({
     *   name: { en: 'Foo' },
     *   slug: { en: 'foo' },
     *   productType: { id: '123', typeId: 'product-type'}
     * })
     * .then()
     * .catch()
     * ```
     */
    create (body) {
      if (!body)
        throw new Error('Body payload is required for creating a resource')

      const { type, store } = this
      const { service: { [type]: serviceState } } = store.getState()

      store.dispatch({ type: SERVICE_PARAMS_RESET, payload: type })
      return new Promise((resolve, reject) => {
        try {
          store.dispatch({
            type: TASK,
            meta: {
              source: HTTP_CREATE,
              promise: { resolve, reject },
              service: type,
              serviceState,
            },
            payload: body,
          })
        } catch (error) {
          reject(error)
        }
      })
    },

    /**
     * Update a resource defined by the `service`.
     *
     * @param  {Object} body - The payload described by the related
     * API resource.
     * @throws If `body` and `id` are missing.
     * @return {Promise} A `task` promise that will eventually be resolved.
     *
     * @example
     *
     * ```js
     * service = client.products.byId('123')
     * service.update({
     *   version: 1,
     *   actions: [{ action: 'setName', name: { en: 'Foo' }}]
     * })
     * .then()
     * .catch()
     * ```
     */
    update (body) {
      if (!body)
        throw new Error('Body payload is required for updating a resource.')

      const { type, store } = this
      const { service: { [type]: serviceState } } = store.getState()

      if (!serviceState.id)
        throw new Error('Missing required `id` param for updating a ' +
          'resource. You can set it by chaining ' +
          '`.byId(<id>).update({})`')

      store.dispatch({ type: SERVICE_PARAMS_RESET, payload: type })
      return new Promise((resolve, reject) => {
        try {
          store.dispatch({
            type: TASK,
            meta: {
              source: HTTP_UPDATE,
              promise: { resolve, reject },
              service: type,
              serviceState,
            },
            payload: body,
          })
        } catch (error) {
          reject(error)
        }
      })
    },

    /**
     * Delete a resource defined by the `service`.
     *
     * @param  {number} version - The current version of the resource.
     * @throws If `version` and `id` are missing.
     * @return {Promise} A `task` promise that will eventually be resolved.
     *
     * @example
     *
     * ```js
     * service = client.products.byId('123')
     * service.delete(1)
     * .then()
     * .catch()
     * ```
     */
    delete (version) {
      if (!version)
        throw new Error('Version number is required for deleting a resource.')

      const { type, store } = this
      const { service: { [type]: serviceState } } = store.getState()

      if (!serviceState.id)
        throw new Error('Missing required `id` param for deleting a ' +
          'resource. You can set it by chaining ' +
          '`.byId(<id>).delete(<version>)`')

      store.dispatch({ type: SERVICE_PARAMS_RESET, payload: type })
      return new Promise((resolve, reject) => {
        try {
          store.dispatch({
            type: TASK,
            meta: {
              source: HTTP_DELETE,
              promise: { resolve, reject },
              service: type,
              serviceState,
            },
            payload: version,
          })
        } catch (error) {
          reject(error)
        }
      })
    },
  }
}
