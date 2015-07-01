_ = require 'underscore'
_.mixin require 'underscore-mixins'
ProductTypeUtils = require '../../../lib/sync/utils/product-type'

describe 'ProductTypeUtils', ->
  beforeEach ->
    @utils = new ProductTypeUtils()

  afterEach ->
    @utils = null

  describe 'actionsForEnumValues', ->
    it 'should not create any action when there is no difference', ->
      pt =
        name: 'those products'
        version: 3
        attributes: [
          { name: 'size', type: { name: 'enum' }, values: [ 'M', 'L' ] }
        ]

      delta = @utils.diff pt, pt
      update = @utils.actionsForEnumValues delta, pt

      expect(update).toEqual []

    it 'should create action for enum values', ->
      pt_old =
        name: 'my colorful products'
        version: 4
        attributes: [
          { name: 'color', type: { name: 'enum' }, values: [ 'black', 'white' ] }
        ]
      pt_new =
        name: 'my colorful products'
        attributes: [
          { name: 'color', type: { name: 'enum' }, values: [ 'black', 'grey', 'white' ] }
        ]

      delta = @utils.diff pt_old, pt_new
      update = @utils.actionsForEnumValues delta, pt_new

      expect(update).toEqual [
        { action: 'addPlainEnumValue', name: 'color', value: { key: 'grey', label: 'Label for grey' } }
      ]