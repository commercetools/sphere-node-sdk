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
const initialServiceStateShape = {
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

const initialState = {
  /*
    The primary keys are the service names.
    Each service has its own state slice. This is necessary to ensure
    services are decoupled from each other.
  */
}

const actionHandlers = {
  [SERVICE_INIT]: (state, { payload: { type: serviceName, endpoint } }) => ({
    [serviceName]: { ...initialServiceStateShape, endpoint },
  }),
  [SERVICE_PARAMS_RESET]: (state, { payload: serviceName }) => {
    const { endpoint } = state[serviceName]
    return {
      [serviceName]: { ...initialServiceStateShape, endpoint },
    }
  },

  // Query params
  [SERVICE_PARAM_ID]: forService((state, { payload }) => ({
    id: payload,
  })),
  [SERVICE_PARAM_QUERY_STAGED]: forService((state, { payload }) => ({
    staged: payload,
  })),
  [SERVICE_PARAM_QUERY_EXPAND]: forService((state, { payload }) => ({
    expand: state.expand.concat(payload),
  })),
  [SERVICE_PARAM_QUERY_CUSTOM]: forService((state, { payload }) => ({
    customQuery: payload,
  })),
  [SERVICE_PARAM_QUERY_PAGE]: forService((state, { payload }) => ({
    pagination: { ...state.pagination, page: payload },
  })),
  [SERVICE_PARAM_QUERY_PER_PAGE]: forService((state, { payload }) => ({
    pagination: { ...state.pagination, perPage: payload },
  })),
  [SERVICE_PARAM_QUERY_SORT]: forService((state, { payload }) => ({
    pagination: {
      ...state.pagination,
      sort: state.pagination.sort.concat(payload),
    },
  })),
  [SERVICE_PARAM_QUERY_WHERE]: forService((state, { payload }) => ({
    query: {
      ...state.pagination,
      where: state.query.where.concat(payload),
    },
  })),
  [SERVICE_PARAM_QUERY_WHERE_OPERATOR]: forService((state, { payload }) => ({
    pagination: { ...state.pagination, operator: payload },
  })),

  // Search params
  [SERVICE_PARAM_QUERY_SEARCH_TEXT]: forService((state, { payload }) => ({
    search: { ...state.search, text: payload },
  })),
  [SERVICE_PARAM_QUERY_SEARCH_FUZZY]: forService((state) => ({
    search: { ...state.search, fuzzy: true },
  })),
  [SERVICE_PARAM_QUERY_SEARCH_FACET]: forService((state, { payload }) => ({
    search: { ...state.search, facet: state.search.facet.concat(payload) },
  })),
  [SERVICE_PARAM_QUERY_SEARCH_FILTER]: forService((state, { payload }) => ({
    search: { ...state.search, filter: state.search.filter.concat(payload) },
  })),
  [SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_QUERY]:
  forService((state, { payload }) => ({
    search: {
      ...state.search,
      filterByQuery: state.search.filterByQuery.concat(payload),
    },
  })),
  [SERVICE_PARAM_QUERY_SEARCH_FILTER_BY_FACETS]:
  forService((state, { payload }) => ({
    search: {
      ...state.search,
      filterByFacets: state.search.filterByFacets.concat(payload),
    },
  })),
}

export default createReducer(initialState, actionHandlers)


function forService (reducer) {
  return (state, action) => {
    const serviceName = action.meta.service
    if (!serviceName)
      throw new Error('Missing service name in action.meta for ' +
        `action.type ${serviceName}`)

    const serviceState = state[serviceName]
    const serviceStateSlice = reducer(serviceState, action)
    return { [serviceName]: { ...serviceState, serviceStateSlice } }
  }
}
