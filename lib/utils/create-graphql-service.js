import classify from './classify'
import buildAbsoluteUrl from './build-absolute-url'
import * as withHelpers from './with-helpers'

export default function createGraphQLService () {

  return deps => classify(
    Object.assign({},
      deps, withHelpers,
      {
        type: 'graphql', baseEndpoint: '/graphql',
        query (body) {
          if (!body)
            throw new Error('Body payload is required for querying ' +
              'GraphQL resources.')

          const url = buildAbsoluteUrl(this.options, this.baseEndpoint)
          return this.queue.addTask({ method: 'POST', url, body })
        }

      }
    ))
}
