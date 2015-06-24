_ = require 'underscore'
{ProductTypeSync} = require '../../lib/main'

describe 'ProductTypeSync', ->

  beforeEach ->
    @sync = new ProductTypeSync

  afterEach ->
    @sync = null

  describe ':: buildActions', ->

    it 'should build enum addition actions', ->
      old_pt =
        name: 'my product type'
        version: 3
        attributes: [
          { name: 'size', type: { name: 'enum' }, values: [ 'M', 'L' ] }
        ]
      new_pt =
        name: 'my product type'
        attributes: [
          { name: 'size', type: { name: 'enum' }, values: [ 'M', 'L', 'S' ] }
        ]

      update = @sync.buildActions(new_pt, old_pt).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'addPlainEnumValue', name: 'size', value: 'S' }
        ]
        version: old_pt.version
      expect(update).toEqual expected_update
