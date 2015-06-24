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