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

    _.each ['new', 'update', 'delete', 'textDiff', 'arrayMove'], (key) ->
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
          when 'textDiff'
            delta = ['@@ -1,8 +1,13 @@\n+2010 \n Camparr%C3%B3\n', 0, 2]
            expect(@utils.getDeltaValue(delta, 'Camparrón \"Pintura de Rubens\", Bodegas Francisco Casas, Morales'))
            .toBe '2010 Camparrón \"Pintura de Rubens\", Bodegas Francisco Casas, Morales'
          when 'arrayMove'
            delta = ['', 1, 3]
            expect(=> @utils.getDeltaValue(delta)).toThrow new Error 'Detected an array move, it should not happen as includeValueOnMove should be set to false'
          when 'arrayMove'
            delta = ['', 0, 4]
            expect(=> @utils.getDeltaValue(delta)).toThrow new Error 'Got unsupported number 4 in delta value'

    it 'should apply a patch', ->
      delta =
        ['@@ -1,8 +1,13 @@\n+2010 \n Camparr%C3%B3\n', 0, 2]
      obj = 'Camparrón \"Pintura de Rubens\", Bodegas Francisco Casas, Morales'
      patched = @utils.patch(obj, delta)
      expect(patched).toEqual '2010 Camparrón \"Pintura de Rubens\", Bodegas Francisco Casas, Morales'
