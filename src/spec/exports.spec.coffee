{SphereClient, OAuth2, Rest, ProductSync, OrderSync, InventorySync, TaskQueue} = require '../lib/main'

describe "exports", ->

  it "SphereClient", -> expect(SphereClient).toBeDefined()

  it "OAuth2", -> expect(OAuth2).toBeDefined()

  it "Rest", -> expect(Rest).toBeDefined()

  it "ProductSync", -> expect(ProductSync).toBeDefined()

  it "OrderSync", -> expect(OrderSync).toBeDefined()

  it "InventorySync", -> expect(InventorySync).toBeDefined()

  it "TaskQueue", -> expect(TaskQueue).toBeDefined()
