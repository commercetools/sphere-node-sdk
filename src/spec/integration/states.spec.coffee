debug = require('debug')('spec-integration:states')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient} = require '../../lib/main'
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


describe 'Integration States', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config

    @client.states.save(newState())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @state = result.body
      debug 'New state created: %j', @state
      done()
    .catch (error) -> done _.prettify(error)

  afterEach (done) ->
    @client.states.byId(@state.id).delete(@state.version)
    .then (result) =>
      debug "State deleted: #{@state.id}"
      expect(result.statusCode).toBe 200
      done()
    .catch (error) -> done _.prettify(error)

  it 'should update a state', (done) ->
    @client.states.byId(@state.id).update(updateState(@state.version))
    .then (result) =>
      expect(result.statusCode).toBe 200
      @state = result.body
      expect(@state.name).toEqual {en: 'A State'}
      expect(@state.description).toEqual {en: 'This is a State'}
      done()
    .catch (error) -> done _.prettify(error)

  it 'should create some states and use them as transitions references', (done) ->
    Promise.all _.map [1..51], => @client.states.save(newState())
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
        Promise.all _.map otherStates, (r) => @client.states.byId(r.body.id).delete(r.body.version)
      .then (results) ->
        done()
    .catch (error) -> done _.prettify(error)
  , 20000 # 20sec
