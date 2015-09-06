// TODO: simplify true/false configuration
export default {
  categories: {
    type: 'categories',
    endpoint: '/categories',
    options: {
      hasRead: true,
      hasCreate: true,
      hasUpdate: true,
      hasDelete: true,
      hasQuery: true,
      hasQueryOne: true,
      hasQueryExpand: true,
      hasSearch: false,
      hasProjection: false,
      hasQueryString: true
    }
  },
  productProjections: {
    type: 'product-projections',
    endpoint: '/product-projections',
    options: {
      hasRead: true,
      hasCreate: false,
      hasUpdate: false,
      hasDelete: false,
      hasQuery: true,
      hasQueryOne: true,
      hasQueryExpand: true,
      hasSearch: false,
      hasProjection: true,
      hasQueryString: true
    }
  },
  productProjectionsSearch: {
    type: 'product-projections-search',
    endpoint: '/product-projections/search',
    options: {
      hasRead: true,
      hasCreate: false,
      hasUpdate: false,
      hasDelete: false,
      hasQuery: false,
      hasQueryOne: true,
      hasQueryExpand: true,
      hasSearch: true,
      hasProjection: true,
      hasQueryString: true
    }
  },
  products: {
    type: 'products',
    endpoint: '/products',
    options: {
      hasRead: true,
      hasCreate: true,
      hasUpdate: true,
      hasDelete: true,
      hasQuery: true,
      hasQueryOne: true,
      hasQueryExpand: true,
      hasSearch: false,
      hasProjection: false,
      hasQueryString: true
    }
  },
  productTypes: {
    type: 'product-types',
    endpoint: '/product-types',
    options: {
      hasRead: true,
      hasCreate: true,
      hasUpdate: true,
      hasDelete: true,
      hasQuery: true,
      hasQueryOne: true,
      hasQueryExpand: false,
      hasSearch: false,
      hasProjection: false,
      hasQueryString: true
    }
  }
}
