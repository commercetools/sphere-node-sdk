{SphereClient, OAuth2, Rest, ProductSync, OrderSync, InventorySync, TaskQueue, Errors} = require '../lib/main'

describe 'exports', ->

  it 'SphereClient', -> expect(SphereClient).toBeDefined()

  it 'OAuth2', -> expect(OAuth2).toBeDefined()

  it 'Rest', -> expect(Rest).toBeDefined()

  it 'ProductSync', -> expect(ProductSync).toBeDefined()

  it 'OrderSync', -> expect(OrderSync).toBeDefined()

  it 'InventorySync', -> expect(InventorySync).toBeDefined()

  it 'TaskQueue', -> expect(TaskQueue).toBeDefined()

  it 'Errors', ->
    expect(Errors).toBeDefined()
    expect(Errors.HttpError).toBeDefined()
    expect(Errors.SphereError).toBeDefined()
    expect(Errors.SphereHttpError.BadRequest).toBeDefined()
    expect(Errors.SphereHttpError.NotFound).toBeDefined()
    expect(Errors.SphereHttpError.ConcurrentModification).toBeDefined()
    expect(Errors.SphereHttpError.InternalServerError).toBeDefined()
    expect(Errors.SphereHttpError.ServiceUnavailable).toBeDefined()
