import {
  FEATURE_READ,
  FEATURE_CREATE,
  FEATURE_UPDATE,
  FEATURE_DELETE,
  FEATURE_QUERY,
  FEATURE_QUERY_ONE,
  FEATURE_QUERY_EXPAND,
  FEATURE_QUERY_STRING,
  FEATURE_SEARCH,
  FEATURE_PROJECTION,
  SERVICE_INIT,
} from '../constants'
import classify from './classify'
import createHttpVerbs from './create-http-verbs'
import * as withHelpers from './with-helpers'
import * as query from './query'
import * as queryId from './query-id'
import * as queryExpand from './query-expand'
import * as queryPage from './query-page'
import * as queryProjection from './query-projection'
import * as querySearch from './query-search'
import * as queryCustom from './query-custom'

export default function createService (config, store, promiseLibrary) {
  // Validation
  if (!config)
    throw new Error('Cannot create a service without a `config`.')

  const { type, endpoint, features } = config

  if (!type || !endpoint || !features)
    throw new Error('Object `config` is missing required parameters.')

  if (!features.length)
    throw new Error('There should be at least 1 feature listed.')

  // Initialize service state
  store.dispatch({
    type: SERVICE_INIT,
    payload: endpoint,
    meta: { service: type },
  })

  // Decorate service
  const verbs = createHttpVerbs(promiseLibrary)
  const serviceFeatures = features.reduce((acc, feature) => {
    if (feature === FEATURE_QUERY)
      return { ...acc, ...query, ...queryPage }

    if (feature === FEATURE_QUERY_ONE)
      return { ...acc, ...queryId }

    if (feature === FEATURE_QUERY_EXPAND)
      return { ...acc, ...queryExpand }

    if (feature === FEATURE_QUERY_STRING)
      return { ...acc, ...queryCustom }

    if (feature === FEATURE_SEARCH)
      return {
        ...acc,
        ...querySearch,
        ...queryPage,
        // params: getDefaultSearchParams(),
      }

    if (feature === FEATURE_PROJECTION)
      return { ...acc, ...queryProjection }

    if (feature === FEATURE_READ)
      return { ...acc, fetch: verbs.fetch }

    if (feature === FEATURE_CREATE)
      return { ...acc, create: verbs.create }

    if (feature === FEATURE_UPDATE)
      return { ...acc, update: verbs.update }

    if (feature === FEATURE_DELETE)
      return { ...acc, delete: verbs.delete }

    return acc
  }, {})

  return classify({
    type,
    features,
    // TODO: might want to inject the store into the utils
    // functions instead of making it public.
    store,
    ...withHelpers,
    ...serviceFeatures,
  })
}
