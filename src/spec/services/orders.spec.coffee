Q = require 'q'
OrderService = require '../../lib/services/orders'

###*
 * Describe service specific implementations
###
describe 'OrderService', ->

  beforeEach ->
    @service = new OrderService

  it 'should call \'save\' after setting import endpoint', ->
    spyOn(@service, 'save')
    @service.import foo: 'bar'
    expect(@service.save).toHaveBeenCalledWith foo: 'bar'
    expect(@service._currentEndpoint).toBe '/orders/import'
