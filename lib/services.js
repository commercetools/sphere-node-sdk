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
      hasSearch: false,
      hasProjection: false
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
      hasSearch: false,
      hasProjection: true
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
      hasSearch: true,
      hasProjection: true
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
      hasSearch: false,
      hasProjection: false
    }
  }
}
