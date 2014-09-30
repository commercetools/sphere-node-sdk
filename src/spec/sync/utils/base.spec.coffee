_ = require 'underscore'
BaseUtils = require '../../../lib/sync/utils/base'

describe 'BaseUtils', ->

  beforeEach ->
    @utils = new BaseUtils

  afterEach ->
    @utils = null

  it 'should initialize', ->
    expect(@utils).toBeDefined()

  describe ':: diff', ->

    it 'should return diffed object', ->
      d = @utils.diff({foo: 'bar'}, {foo: 'baz'})
      expect(d).toEqual foo: ['bar', 'baz']

    _.each ['new', 'update', 'delete'], (key) ->
      it "should get delta value for '#{key}' value", ->
        switch key
          when 'new'
            delta = ['bar']
            expect(@utils.getDeltaValue(delta)).toBe 'bar'
          when 'update'
            delta = ['bar', 'qux']
            expect(@utils.getDeltaValue(delta)).toBe 'qux'
          when 'delete'
            delta = ['bar', 0, 0]
            expect(@utils.getDeltaValue(delta)).not.toBeDefined()
