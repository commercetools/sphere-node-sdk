debug = require('debug')('spec-integration:graphql')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, Errors} = require '../../lib/main'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

# 'InventorySupply' is provided by default
newChannel = ->
  key: uniqueId 'c'

describe 'Integration GraphQL', ->

  beforeEach ->
    @client = new SphereClient
      config: Config
      stats:
        includeHeaders: true

  it 'should query a channel', (done) ->
    Promise.all [
      @client.channels.save(newChannel()),
      @client.channels.save(newChannel())
    ]
    .then ([ch1, ch2]) =>
      @client.graphql.query
        query: """
query Sphere {
  channels(where: "key in (\\"#{ch1.body.key}\\", \\"#{ch2.body.key}\\")") {
    total,
    results {
      ...ChannelKey
    }
  },
  channel1: channel(id: "#{ch1.body.id}") {
    ...ChannelKey
  },
  channel2: channel(id: "#{ch2.body.id}") {
    ...ChannelKey
  }
}

fragment ChannelKey on Channel {
  id, key
}
        """
      .then (result) =>
        expect(result.body.data.channels).toBeDefined()
        expect(result.body.data.channels.total).toBe 2
        expect(result.body.data.channels.results).toBeDefined()
        expect(_.keys(result.body.data.channel1).length).toBe 2
        expect(result.body.data.channel1.id).toBe ch1.body.id
        expect(_.keys(result.body.data.channel2).length).toBe 2
        expect(result.body.data.channel2.id).toBe ch2.body.id

        expect(result.statusCode).toBe 200
        done()
    .catch (error) -> done _.prettify(error)

  it 'should fail if query is not valid', (done) ->
    @client.graphql.query
      query: """
query Sphere {
  foo { bar }
}
      """
    .then (result) ->
      debug 'result', result.body
      done('Query should have failed')
    .catch (error) ->
      expect(error instanceof Errors.GraphQLError).toBe true
      expect(error.message).toBe 'GraphQL error'
      done()
