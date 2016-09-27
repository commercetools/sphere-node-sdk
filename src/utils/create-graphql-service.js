import classify from './classify'
import * as withHelpers from './with-helpers'
import {
  TASK,
  HTTP_GRAPHQL_QUERY,
} from '../constants'

const type = 'graphql'
const endpoint = '/graphql'

export default function createGraphQLService (store, PromiseLibrary = Promise) {
  const serviceFeatures = {
    query (body) {
      if (!body)
        throw new Error('Body payload is required for querying ' +
          'GraphQL resources.')

      return new PromiseLibrary((resolve, reject) => {
        try {
          store.dispatch({
            type: TASK,
            meta: {
              source: HTTP_GRAPHQL_QUERY,
              promise: { resolve, reject },
              service: type,
              serviceState: {
                endpoint,
              },
            },
            payload: body,
          })
        } catch (error) {
          reject(error)
        }
      })
    },
  }

  return classify({
    type,
    store,
    ...withHelpers,
    ...serviceFeatures,
  })
}
