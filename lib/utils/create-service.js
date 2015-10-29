import {
  getDefaultQueryParams,
  getDefaultSearchParams
} from './default-params'
import classify from './classify'
import * as defaultFeatures from './features'
import * as withHelpers from './with-helpers'
import * as verbs from './verbs'
import * as query from './query'
import * as queryId from './query-id'
import * as queryExpand from './query-expand'
import * as queryPage from './query-page'
import * as queryProjection from './query-projection'
import * as querySearch from './query-search'
import * as queryCustom from './query-custom'

export default function createService (config) {
  if (!config)
    throw new Error('Cannot create a service without a `config`.')

  const { type, endpoint, features } = config

  if (!type || !endpoint || !(features && features.length > 0))
    throw new Error('Object `config` is missing required parameters.')

  return deps => classify(
    Object.assign({},
      deps, withHelpers,
      {
        type, features, baseEndpoint: endpoint,
        params: getDefaultQueryParams()
      },
      features.reduce((acc, feature) => {
        if (feature === defaultFeatures.query)
          return Object.assign(acc, query, queryPage)

        if (feature === defaultFeatures.queryOne)
          return Object.assign(acc, queryId)

        if (feature === defaultFeatures.queryExpand)
          return Object.assign(acc, queryExpand)

        if (feature === defaultFeatures.queryString)
          return Object.assign(acc, queryCustom)

        if (feature === defaultFeatures.search)
          return Object.assign(acc, querySearch, queryPage, {
            params: getDefaultSearchParams()
          })

        if (feature === defaultFeatures.projection)
          return Object.assign(acc, queryProjection)

        if (feature === defaultFeatures.read)
          return Object.assign(acc, { fetch: verbs.fetch })

        if (feature === defaultFeatures.create)
          return Object.assign(acc, { create: verbs.create })

        if (feature === defaultFeatures.update)
          return Object.assign(acc, { update: verbs.update })

        if (feature === defaultFeatures.delete)
          return Object.assign(acc, { delete: verbs.delete })
      }, {})
    ))
}
