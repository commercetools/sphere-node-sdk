/* @flow */

// Reducers: request
export type RequestState = {
  projectKey: ?string;
  token: ?string;
  expiresIn: ?string;
}
export type RequestStateDraft = {
  projectKey?: string;
  token?: string;
  expiresIn?: string;
}

// Reducers: service
type QueryPaginationParams = {
  page: ?number;
  perPage: ?number;
  sort: Array<string>;
}

type QueryPredicateParams = {
  operator: string;
  where: Array<string>;
}

type SearchParams = {
  facet: Array<string>;
  filter: Array<string>;
  filterByQuery: Array<string>;
  filterByFacets: Array<string>;
  fuzzy: ?boolean;
  text: ?string;
}

export type ServiceState = {
  endpoint: ?string;
  id: ?string;
  customQuery: ?string;
  // Query params
  expand: Array<string>;
  pagination: QueryPaginationParams;
  query: QueryPredicateParams;
  // Search params
  search: SearchParams;
}
export type AllServicesState = {
  [key: string]: ServiceState;
}


// Actions: standard
export type Action = {
  type: string;
  payload: any;
  // TODO: specify meta fields
  meta: Object;
}

// Actions: service
export type ServiceAction = {
  type: string;
  payload: any;
  meta: {
    service: string;
  };
}

// Utils
export type Reducer<T, U> = (state: T, action: U) => T;
export type ActionHandlers<T, U> = {
  [key: string]: Reducer<T, U>;
}
