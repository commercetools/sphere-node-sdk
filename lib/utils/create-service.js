import {
  getDefaultQueryParams,
  getDefaultSearchParams
} from './default-params'
import classify from './classify'
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
  // TODO: validate config
  const { type, endpoint, options } = config
  const {
    hasRead,
    hasCreate,
    hasUpdate,
    hasDelete,
    hasQuery,
    hasQueryOne,
    hasQueryExpand,
    hasSearch,
    hasProjection,
    hasQueryString
  } = options

  return deps => classify(
    Object.assign({},
      deps, withHelpers,
      hasQuery ? (query, queryPage) : null,
      hasQueryOne ? queryId : null,
      hasQueryExpand ? queryExpand : null,
      hasSearch ? (querySearch, queryPage) : null,
      hasProjection ? queryProjection : null,
      hasQueryString ? queryCustom : null,
      hasRead ? { fetch: verbs.fetch } : null,
      hasCreate ? { create: verbs.create } : null,
      hasUpdate ? { update: verbs.update } : null,
      hasDelete ? { delete: verbs.delete } : null,
      {
        type, baseEndpoint: endpoint, serviceConfig: options,
        params: hasSearch ? getDefaultSearchParams() : getDefaultQueryParams()
      }
    ))
}
