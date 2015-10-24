import * as features from './utils/features'

export default {
  categories: {
    type: 'categories',
    endpoint: '/categories',
    features: [
      features.read,
      features.create,
      features.update,
      features.delete,
      features.query,
      features.queryOne,
      features.queryExpand,
      features.queryString
    ]
  },
  channels: {
    type: 'channels',
    endpoint: '/channels',
    features: [
      features.read,
      features.create,
      features.update,
      features.delete,
      features.query,
      features.queryOne,
      features.queryExpand,
      features.queryString
    ]
  },
  productProjections: {
    type: 'product-projections',
    endpoint: '/product-projections',
    features: [
      features.read,
      features.query,
      features.queryOne,
      features.queryExpand,
      features.queryString,
      features.projection
    ]
  },
  productProjectionsSearch: {
    type: 'product-projections-search',
    endpoint: '/product-projections/search',
    features: [
      features.read,
      features.search,
      features.queryOne,
      features.queryExpand,
      features.queryString,
      features.projection
    ]
  },
  products: {
    type: 'products',
    endpoint: '/products',
    features: [
      features.read,
      features.create,
      features.update,
      features.delete,
      features.query,
      features.queryOne,
      features.queryExpand,
      features.queryString
    ]
  },
  productTypes: {
    type: 'product-types',
    endpoint: '/product-types',
    features: [
      features.read,
      features.create,
      features.update,
      features.delete,
      features.query,
      features.queryOne,
      features.queryString
    ]
  }
}
