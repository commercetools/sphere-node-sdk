_ = require 'underscore'
{ProductSync} = require '../../lib/main'

describe 'ProductUtils SKU based matching', ->

  beforeEach ->
    @sync = new ProductSync
    @oldProduct =
      id: '123'
      masterVariant:
        id: 1
      variants: []

    @newProduct =
      id: '123'
      masterVariant:
        id: 1
      variants: []

  compareVariantActions = (sync, oldProduct, newProduct, expectedVariantActions) ->
    opts = [
      {type: 'variants', group: 'white'}
    ]
    actions = sync.config(opts).buildActions(newProduct, oldProduct).getUpdateActions()
    expect(actions).toEqual expectedVariantActions

  compareAttributeActions = (sync, oldProduct, newProduct, expectedAttributeActions) ->
    opts = [
      {type: 'variants', group: 'black'}
      {type: 'attributes', group: 'white'}
    ]
    actions = sync.config(opts).buildActions(newProduct, oldProduct).getUpdateActions()
    expect(actions).toEqual expectedAttributeActions

  it 'should work with a new variant', ->
    @newProduct.variants = [
      { sku: 'v2', attributes: [{name: 'attrib', value: 'val'}] }
    ]

    compareVariantActions @sync, @oldProduct, @newProduct,
      [
        {
          action: 'addVariant'
          sku: 'v2'
          attributes: [{ name: 'attrib', value: 'val' }]
        }
      ]

    compareAttributeActions @sync, @oldProduct, @newProduct, []

  it 'should work when removing a variant', ->
    @oldProduct.variants = [
      { id: 7, sku: 'vX', attributes: [{name: 'attrib', value: 'val'}] }
    ]

    compareVariantActions @sync, @oldProduct, @newProduct,
      [{ action: 'removeVariant', id: 7 }]

    compareAttributeActions @sync, @oldProduct, @newProduct, []

  it 'should work when adding a new variant before others', ->
    @oldProduct.variants = [
      { id: 9, sku: 'v2', attributes: [{name: 'attrib', value: 'val'}] }
    ]
    @newProduct.variants = [
      { sku: 'vN', attributes: [{name: 'attribN', value: 'valN'}] }
      { sku: 'v2', attributes: [{name: 'attrib', value: 'CHANGED'}] }
    ]

    compareVariantActions @sync, @oldProduct, @newProduct,  [
      { action: 'addVariant', sku: 'vN', attributes: [{name: 'attribN', value: 'valN'}] }
    ]
    compareAttributeActions @sync, @oldProduct, @newProduct, [
      { action: 'setAttribute', variantId: 9, name: 'attrib', value: 'CHANGED' }
    ]

  it 'should work when the order of variant has changed', ->
    @oldProduct.variants = [
      { id: 2, sku: 'v2', attributes: [{name: 'attrib2', value: 'val2'}] }
      { id: 3, sku: 'v3', attributes: [{name: 'attrib3', value: 'val3'}] }
      { id: 4, sku: 'v4', attributes: [{name: 'attrib4', value: 'val4'}] }
      { id: 5, sku: 'v5', attributes: [{name: 'attrib5', value: 'val5'}] }
    ]
    @newProduct.variants = [
      { sku: 'v5', attributes: [{name: 'attrib5', value: 'CHANGED5'}] }
      { sku: 'v4', attributes: [{name: 'attrib4', value: 'val4'}] }
      { sku: 'v3', attributes: [{name: 'attrib3', value: 'val3'}] }
      { sku: 'v2', attributes: [{name: 'attrib2', value: 'CHANGED2'}] }
    ]

    compareVariantActions @sync, @oldProduct, @newProduct,  []

    compareAttributeActions @sync, @oldProduct, @newProduct, [
      { action: 'setAttribute', variantId: 5, name: 'attrib5', value: 'CHANGED5' }
      { action: 'setAttribute', variantId: 2, name: 'attrib2', value: 'CHANGED2' }
    ]

  it 'should work in combination with variant additions and removes', ->
    @oldProduct.variants = [
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

    compareVariantActions @sync, @oldProduct, @newProduct,  [
      { action: 'removeVariant', id: 2 }
      { action: 'addVariant', sku: 'v4', attributes: [{ name: 'attrib4', value: 'val4' }] }
      { action: 'addVariant', sku: 'v6', attributes: [{ name: 'attrib6', value: 'val6' }] }
    ]

    compareAttributeActions @sync, @oldProduct, @newProduct, [
      { action: 'setAttribute', variantId: 3, name: 'attrib3', value: 'CHANGED3' }
      { action: 'setAttribute', variantId: 5, name: 'attrib5', value: 'CHANGED5' }
    ]

  it 'should work when master variant was switched with another variant', ->
    @oldProduct.masterVariant.sku = 'v1'
    @oldProduct.variants = [
      { id: 3, sku: 'v3', attributes: [{name: 'attrib3', value: 'val3'}] }
    ]
    @newProduct.masterVariant.sku = 'v3'
    delete @newProduct.masterVariant.id

    @newProduct.variants = [
      { sku: 'v1', attributes: [{name: 'attrib3', value: 'CHANGED3'}] }
    ]

    compareVariantActions @sync, @oldProduct, @newProduct,  [
      { action : 'changeMasterVariant', sku : 'v3' }
    ]
    compareAttributeActions @sync, @oldProduct, @newProduct, [
      { action: 'setAttribute', variantId: 3, name: 'attrib3', value: undefined } # remove from master
      { action: 'setAttribute', variantId: 1, name: 'attrib3', value: 'CHANGED3' } # set on variant v1
    ]
