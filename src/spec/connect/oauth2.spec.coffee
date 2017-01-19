_ = require 'underscore'
{OAuth2} = require '../../lib/main'
Config = require('../../config').config

describe 'OAuth2', ->

  it 'should initialize with default options', ->
    oa = new OAuth2 config: Config
    expect(oa).toBeDefined()
    expect(oa._options.host).toBe 'auth.sphere.io'
    expect(oa._options.protocol).toBe 'https'
    expect(oa._options.accessTokenUrl).toBe '/oauth/token'
    expect(oa._options.timeout).toBe 60000
    expect(oa._options.rejectUnauthorized).toBe true

  it 'should throw error if no credentials are given', ->
    oa = -> new OAuth2
    expect(oa).toThrow new Error 'Missing credentials'

  _.each ['client_id', 'client_secret', 'project_key'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config)
      delete opt[key]
      oa = -> new OAuth2 config: opt
      expect(oa).toThrow new Error "Missing '#{key}'"

  it "should pass 'host' option", ->
    oa = new OAuth2
      config: Config
      host: 'example.com'
    expect(oa._options.host).toBe 'example.com'

  it "should pass 'protocol' option", ->
    oa = new OAuth2
      config: Config
      protocol: 'http'
    expect(oa._options.protocol).toBe 'http'

  it 'should pass \'accessTokenUrl\' option', ->
    oa = new OAuth2
      config: Config
      accessTokenUrl: '/foo/bar'
    expect(oa._options.accessTokenUrl).toBe '/foo/bar'

  it 'should pass \'timeout\' option', ->
    oa = new OAuth2
      config: Config
      timeout: 100
    expect(oa._options.timeout).toBe 100

  it 'should pass \'rejectUnauthorized\' option', ->
    oa = new OAuth2
      config: Config
      rejectUnauthorized: false
    expect(oa._options.rejectUnauthorized).toBe false

  it 'should not fail to log if request times out', (done) ->
    oa = new OAuth2
      config: Config
      timeout: 1
    callMe = -> done()
    expect(-> oa.getAccessToken(callMe)).not.toThrow()
