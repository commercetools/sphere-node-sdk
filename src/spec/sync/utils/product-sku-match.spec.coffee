ProductUtils = require '../../../lib/sync/utils/product'

describe 'ProductUtils SKU based matching', ->

  beforeEach ->
    @utils = new ProductUtils
    @existingProduct =
      id: '123'
      masterVariant:
        id: 1
      variants: []

    @newProduct =
      id: '123'
      masterVariant:
        id: 1
      variants: []

  compareDiff = (utils, existingProduct, newProduct, expectedDelta) ->
    delta = utils.diff existingProduct, newProduct
    expect(delta).toEqual expectedDelta
    delta

  compareVariantActions = (utils, delta, existingProduct, newProduct, expectedVariantActions) ->
    update = utils.actionsMapVariants delta, existingProduct, newProduct
    expect(update).toEqual expectedVariantActions

  compareAttributeActions = (utils, delta, existingProduct, newProduct, expectedAttributeActions) ->
    update = utils.actionsMapAttributes delta, existingProduct, newProduct
    expect(update).toEqual expectedAttributeActions

  #compareAttributeActions = ()

  it 'should work with a new variant', ->
    @newProduct.variants = [
      { sku: 'v2', attributes: [{name: 'attrib', value: 'val'}] }
    ]

    delta = compareDiff @utils, @existingProduct, @newProduct,
      variants:
        0: [
          {
            sku: 'v2'
            attributes: [{ name: 'attrib', value: 'val' }]
            _MATCH_CRITERIA: 'v2'
            _NEW_ARRAY_INDEX: '0'
          }
        ]
        _t: 'a'

    compareVariantActions @utils, delta, @existingProduct, @newProduct,
      [
        {
          action: 'addVariant'
          sku: 'v2'
          attributes: [{ name: 'attrib', value: 'val' }]
        }
      ]

    compareAttributeActions @utils, delta, @existingProduct, @newProduct, []

  it 'should work when removing a variant', ->
    @existingProduct.variants = [
      { id: 7, sku: 'vX', attributes: [{name: 'attrib', value: 'val'}] }
    ]

    delta = compareDiff @utils, @existingProduct, @newProduct,
      variants:
        _t: 'a'
        _0: [
          {
            id: 7
            sku: 'vX'
            attributes: [{ name: 'attrib', value: 'val' }]
            _MATCH_CRITERIA: 'vX'
            _EXISTING_ARRAY_INDEX: '0'
          },
          0,
          0
        ]

    compareVariantActions @utils, delta, @existingProduct, @newProduct,
      [{ action: 'removeVariant', id: 7 }]

    compareAttributeActions @utils, delta, @existingProduct, @newProduct, []

  it 'should work when adding a new variant before others', ->
    @existingProduct.variants = [
      { id: 9, sku: 'v2', attributes: [{name: 'attrib', value: 'val'}] }
    ]

    @newProduct.variants = [
      { sku: 'vN', attributes: [{name: 'attribN', value: 'valN'}] }
      { sku: 'v2', attributes: [{name: 'attrib', value: 'CHANGED'}] }
    ]

    delta = compareDiff @utils, @existingProduct, @newProduct,
      variants:
        0: [
          {
            sku: 'vN'
            attributes: [{ name: 'attribN', value: 'valN' }]
            _MATCH_CRITERIA: 'vN'
            _NEW_ARRAY_INDEX: '0'
          }
        ]
        1:
          attributes:
            0:
              value: ['val', 'CHANGED']
            _t: 'a'
          id: [9, 0, 0]
          _NEW_ARRAY_INDEX: ['1']
          _EXISTING_ARRAY_INDEX: ['0', 0, 0]
        _t: 'a'

    compareVariantActions @utils, delta, @existingProduct, @newProduct,  [
      { action: 'addVariant', sku: 'vN', attributes: [{name: 'attribN', value: 'valN'}] }
    ]

    compareAttributeActions @utils, delta, @existingProduct, @newProduct, [
      { action: 'setAttribute', variantId: 9, name: 'attrib', value: 'CHANGED' }
    ]

  it 'should work when the order of variant has changed', ->
    @existingProduct.variants = [
      { id: 2, sku: 'v2', attributes: [{name: 'attrib2', value: 'val2'}] }
      { id: 3, sku: 'v3', attributes: [{name: 'attrib3', value: 'val3'}] }
      { id: 4, sku: 'v4', attributes: [{name: 'attrib4', value: 'val4'}] }
      { id: 5, sku: 'v5', attributes: [{name: 'attrib5', value: 'val5'}] }
    ]

    @newProduct.variants = [
      { id: 2, sku: 'v5', attributes: [{name: 'attrib5', value: 'CHANGED5'}] }
      { id: 3, sku: 'v4', attributes: [{name: 'attrib4', value: 'val4'}] }
      { id: 4, sku: 'v3', attributes: [{name: 'attrib3', value: 'val3'}] }
      { id: 5, sku: 'v2', attributes: [{name: 'attrib2', value: 'CHANGED2'}] }
    ]

    delta = compareDiff @utils, @existingProduct, @newProduct,
      variants:
        0:
          id: [5, 2]
          attributes:
            0:
              value: ['val5', 'CHANGED5']
            _t: 'a'
          _NEW_ARRAY_INDEX: ['0']
          _EXISTING_ARRAY_INDEX: ['3', 0, 0]
        1:
          id: [4, 3]
          _NEW_ARRAY_INDEX: ['1']
          _EXISTING_ARRAY_INDEX: ['2', 0, 0]
        2:
          id: [3, 4]
          _NEW_ARRAY_INDEX: ['2']
          _EXISTING_ARRAY_INDEX: ['1', 0, 0]
        3:
          id: [2, 5]
          attributes:
            0:
              value: ['val2', 'CHANGED2']
            _t: 'a'
          _NEW_ARRAY_INDEX: ['3']
          _EXISTING_ARRAY_INDEX: ['0', 0, 0]
        _t: 'a'
        _1: ['', 2, 3]
        _2: ['', 1, 3]
        _3: ['', 0, 3]

    compareVariantActions @utils, delta, @existingProduct, @newProduct,  []

    compareAttributeActions @utils, delta, @existingProduct, @newProduct, [
      { action: 'setAttribute', variantId: 5, name: 'attrib5', value: 'CHANGED5' }
      { action: 'setAttribute', variantId: 2, name: 'attrib2', value: 'CHANGED2' }
    ]

  it 'should work in combination with variant additions and removes', ->
    @existingProduct.variants = [
      { id: 2, sku: 'v2', attributes: [{name: 'attrib2', value: 'val2'}] }
      { id: 3, sku: 'v3', attributes: [{name: 'attrib3', value: 'val3'}] }
      { id: 5, sku: 'v5', attributes: [{name: 'attrib5', value: 'val5'}] }
    ]

    @newProduct.variants = [
      { sku: 'v3', attributes: [{name: 'attrib3', value: 'CHANGED3'}] }
      { sku: 'v4', attributes: [{name: 'attrib4', value: 'val4'}] }
      { sku: 'v5', attributes: [{name: 'attrib5', value: 'CHANGED5'}] }
      { sku: 'v6', attributes: [{name: 'attrib6', value: 'val6'}] }
    ]

    delta = compareDiff @utils, @existingProduct, @newProduct,
      variants:
        0:
          attributes:
            0:
              value: ['val3', 'CHANGED3']
            _t: 'a'
          id: [3, 0, 0]
          _NEW_ARRAY_INDEX: ['0']
          _EXISTING_ARRAY_INDEX: ['1', 0, 0]
        1: [
          {
            sku: 'v4'
            attributes: [{ name: 'attrib4', value: 'val4' }]
            _MATCH_CRITERIA: 'v4'
            _NEW_ARRAY_INDEX: '1'
          }
        ]
        2:
          attributes:
            0:
              value: ['val5', 'CHANGED5']
            _t: 'a'
          id: [5, 0, 0]
          _NEW_ARRAY_INDEX: ['2']
          _EXISTING_ARRAY_INDEX: ['2', 0, 0]
        3: [
          {
            sku: 'v6'
            attributes: [{ name: 'attrib6', value: 'val6' }]
            _MATCH_CRITERIA: 'v6'
            _NEW_ARRAY_INDEX: '3'
          }
        ]
        _t: 'a'
        _0: [
          {
            id: 2
            sku: 'v2'
            attributes: [{ name: 'attrib2', value: 'val2' }]
            _MATCH_CRITERIA: 'v2'
            _EXISTING_ARRAY_INDEX: '0'
          },
          0,
          0
        ]

    compareVariantActions @utils, delta, @existingProduct, @newProduct,  [
      { action: 'removeVariant', id: 2 }
      { action: 'addVariant', sku: 'v4', attributes: [{ name: 'attrib4', value: 'val4' }] }
      { action: 'addVariant', sku: 'v6', attributes: [{ name: 'attrib6', value: 'val6' }] }
    ]

    compareAttributeActions @utils, delta, @existingProduct, @newProduct, [
      { action: 'setAttribute', variantId: 3, name: 'attrib3', value: 'CHANGED3' }
      { action: 'setAttribute', variantId: 5, name: 'attrib5', value: 'CHANGED5' }
    ]

  it 'should work when master variant was switched with another variant', ->
    @existingProduct.masterVariant.sku = 'v1'
    @existingProduct.variants = [
      { id: 3, sku: 'v3', attributes: [{name: 'attrib3', value: 'val3'}] }
    ]

    @newProduct.masterVariant.sku = 'v3'
    @newProduct.variants = [
      { sku: 'v1', attributes: [{name: 'attrib3', value: 'CHANGED3'}] }
    ]

    expectedDelta =
      masterVariant:
        sku: ['v1', 'v3']
        _MATCH_CRITERIA: ['v1', 'v3']
      variants:
        0: [
          {
            sku: 'v1'
            attributes: [{ name: 'attrib3', value: 'CHANGED3' }]
            _MATCH_CRITERIA: 'v1'
            _NEW_ARRAY_INDEX: '0'
          }
        ]
        _t: 'a'
        _0: [
          {
            id: 3
            sku: 'v3'
            attributes: [{ name: 'attrib3', value: 'val3' }]
            _MATCH_CRITERIA: 'v3'
            _EXISTING_ARRAY_INDEX: '0'
          },
          0,
          0
        ]
    delta = compareDiff @utils, @existingProduct, @newProduct, expectedDelta

    compareVariantActions @utils, delta, @existingProduct, @newProduct,  [
      { action: 'removeVariant', id: 3 }
      { action: 'addVariant', sku: 'v1', attributes: [{ name: 'attrib3', value: 'CHANGED3' }] }
    ]

    compareAttributeActions @utils, delta, @existingProduct, @newProduct, [
      { action: 'setSKU', variantId: 1, sku: 'v3' }
    ]
