{SphereClient, OAuth2, Rest} = require '../lib/main'

describe "exports", ->

  it "SphereClient", ->
    expect(SphereClient).toBeDefined()

  it "OAuth2", ->
    expect(OAuth2).toBeDefined()

  it "Rest", ->
    expect(Rest).toBeDefined()
