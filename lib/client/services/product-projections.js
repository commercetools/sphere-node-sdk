import * as commons from './commons'

const { base, query } = commons

export default Object.freeze(Object.assign({}, base, query, {
  baseEndpoint: '/product-projections'
}))
