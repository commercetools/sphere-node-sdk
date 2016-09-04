/* @flow */
import type {
  Reducer,
  ActionHandlers,
  ServiceAction,
  ServiceState,
  AllServicesState,
} from '../types'
import createReducer from '../utils/create-reducer'
import {
  SERVICE_INIT,
  SERVICE_PARAMS_RESET,

  SERVICE_PARAM_ID,

  SERVICE_PARAM_QUERY_STAGED,
  SERVICE_PARAM_QUERY_EXPAND,
  SERVICE_PARAM_QUERY_PAGE,
  SERVICE_PARAM_QUERY_PER_PAGE,
  SERVICE_PARAM_QUERY_SORT,
  SERVICE_PARAM_QUERY_WHERE,
  SERVICE_PARAM_QUERY_WHERE_OPERATOR,

  SERVICE_PARAM_QUERY_SEARCH_FACET,
  SERVICE_PARAM_QUERY_SEARCH_FILTER,
  SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_QUERY,
  SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_FACETS,
  SERVICE_PARAM_QUERY_SEARCH_FUZZY,
  SERVICE_PARAM_QUERY_SEARCH_TEXT,
  SERVICE_PARAM_QUERY_CUSTOM,
} from '../constants'

// TODO: let service definitions define their shape and reducer?
const initialServiceStateShape: ServiceState = {
  endpoint: null,
  id: null,
  customQuery: null,
  // Query params
  expand: [],
  pagination: {
    page: null,
    perPage: null,
    sort: [],
  },
  query: {
    operator: 'and',
    where: [],
  },
  // Search params
  search: {
    facet: [],
    filter: [],
    filterByQuery: [],
    filterByFacets: [],
    fuzzy: false,
    text: null,
  },
}

const initialState: AllServicesState = {
  /*
    The primary keys are the service names.
    Each service has its own state slice. This is necessary to ensure
    services are decoupled from each other.
  */
}

const actionHandlers: ActionHandlers<AllServicesState, ServiceAction> = {
  [SERVICE_INIT]: (
    state: AllServicesState,
    action: ServiceAction
  ): AllServicesState => {
    const endpoint = action.payload
    const serviceName = action.meta.service
    return { [serviceName]: { ...initialServiceStateShape, endpoint } }
  },
  [SERVICE_PARAMS_RESET]: (
    state: AllServicesState,
    action: ServiceAction
  ): AllServicesState => {
    const serviceName = action.meta.service
    const { endpoint } = state[serviceName]
    return { [serviceName]: { ...initialServiceStateShape, endpoint } }
  },

  // Query params
  [SERVICE_PARAM_ID]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({ ...state, id: action.payload })
  ),
  [SERVICE_PARAM_QUERY_STAGED]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({ ...state, staged: action.payload })
  ),
  [SERVICE_PARAM_QUERY_EXPAND]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      expand: state.expand.concat(action.payload),
    })
  ),
  [SERVICE_PARAM_QUERY_CUSTOM]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({ ...state, customQuery: action.payload })
  ),
  [SERVICE_PARAM_QUERY_PAGE]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      pagination: { ...state.pagination, page: action.payload },
    })
  ),
  [SERVICE_PARAM_QUERY_PER_PAGE]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      pagination: { ...state.pagination, perPage: action.payload },
    })
  ),
  [SERVICE_PARAM_QUERY_SORT]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      pagination: {
        ...state.pagination,
        sort: state.pagination.sort.concat(action.payload),
      },
    })
  ),
  [SERVICE_PARAM_QUERY_WHERE]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      query: {
        ...state.query,
        where: state.query.where.concat(action.payload),
      },
    })
  ),
  [SERVICE_PARAM_QUERY_WHERE_OPERATOR]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      query: { ...state.query, operator: action.payload },
    })
  ),

  // Search params
  [SERVICE_PARAM_QUERY_SEARCH_TEXT]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      search: { ...state.search, text: action.payload },
    })
  ),
  [SERVICE_PARAM_QUERY_SEARCH_FUZZY]: forService(
    (state: ServiceState): ServiceState => ({
      ...state,
      search: { ...state.search, fuzzy: true },
    })
  ),
  [SERVICE_PARAM_QUERY_SEARCH_FACET]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      search: {
        ...state.search,
        facet: state.search.facet.concat(action.payload),
      },
    })
  ),
  [SERVICE_PARAM_QUERY_SEARCH_FILTER]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      search: {
        ...state.search,
        filter: state.search.filter.concat(action.payload),
      },
    })
  ),
  [SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_QUERY]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      search: {
        ...state.search,
        filterByQuery: state.search.filterByQuery.concat(action.payload),
      },
    })
  ),
  [SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_FACETS]: forService(
    (
      state: ServiceState,
      action: ServiceAction
    ): ServiceState => ({
      ...state,
      search: {
        ...state.search,
        filterByFacets: state.search.filterByFacets.concat(action.payload),
      },
    })
  ),
}

export default createReducer(initialState, actionHandlers)


function forService (
  reducer: Reducer<ServiceState, ServiceAction>
): Reducer<AllServicesState, ServiceAction> {
  return (state: AllServicesState, action: ServiceAction): AllServicesState => {
    const serviceName: ?string = action.meta.service
    if (!serviceName)
      throw new Error('Missing service name in action.meta for ' +
        `action.type ${action.type}`)

    const serviceState = state[serviceName]
    const serviceStateSlice = reducer(serviceState, action)
    return { [serviceName]: { ...serviceState, serviceStateSlice } }
  }
}
