Q = require 'q'
ProductProjectionService = require '../../lib/services/product-projections'

###*
 * Describe service specific implementations
###
describe 'ProductProjectionService', ->
  it 'should query for staged', ->
    service = new ProductProjectionService()
    expect(service.staged()._queryString()).toBe 'limit=100&staged=true'
