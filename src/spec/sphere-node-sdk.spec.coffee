"use strict"

sphere_node_sdk = require('../lib/sphere-node-sdk.js')

describe "Awesome", ->

  beforeEach (done)->
    # setup here
    done()

  it "should print", ->
    expect(sphere_node_sdk.awesome()).toBe "awesome"
