_ = require 'underscore'
Q = require 'q'
_.mixin require('sphere-node-utils')._u
SphereClient = require '../../lib/client'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newState = ->
  key: uniqueId 's'
  type: 'LineItemState'

updateState = (version) ->
  version: version
  actions: [
    {action: 'setName', name: {en: 'A State'}}
    {action: 'setDescription', description: {en: 'This is a State'}}
  ]


describe 'Integration Channels', ->

  beforeEach (done) ->
    @client = new SphereClient
      config: Config
      logConfig:
        levelStream: 'info'
        levelFile: 'error'
    @logger = @client._logger

    @client.states.save(newState())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @state = result.body
      @logger.info @state, 'New state created'
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettifyError(error))

  afterEach (done) ->
    @client.states.byId(@state.id).delete(@state.version)
    .then (result) =>
      @logger.info "State deleted: #{@state.id}"
      expect(result.statusCode).toBe 200
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettifyError(error))

  it 'should update a state', (done) ->
    @client.states.byId(@state.id).update(updateState(@state.version))
    .then (result) =>
      expect(result.statusCode).toBe 200
      @state = result.body
      expect(@state.name).toEqual {en: 'A State'}
      expect(@state.description).toEqual {en: 'This is a State'}
      done()
    .fail (error) =>
      @logger.error error
      done(_.prettifyError(error))

  it 'should create some states and use them as transitions references', (done) ->
    Q.all _.map [1..51], => @client.states.save(newState())
    .then (results) =>
      mainState = _.head(results).body
      otherStates = _.tail results
      transitions = _.map otherStates, (r) ->
        id: r.body.id
        typeId: 'state'
      @client.states.byId(mainState.id).update
        version: mainState.version
        actions: [
          {action: 'setTransitions', transitions: transitions}
        ]
      .then (result) =>
        expect(result.statusCode).toBe 200
        mainState = result.body
        expect(mainState.transitions.length).toBe 50

        # delete states
        @client.states.byId(mainState.id).delete(mainState.version)
      .then (result) =>
        Q.all _.map otherStates, (r) => @client.states.byId(r.body.id).delete(r.body.version)
      .then (results) ->
        done()
    .fail (error) =>
      @logger.error error
      done(_.prettifyError(error))
  , 20000 # 20sec
