_ = require 'underscore'
{ProductSync} = require '../../lib/main'

OLD_PRODUCT =
  id: '123'
  version: 1
  name:
    en: 'SAPPHIRE'
    de: 'Hoo'
  slug:
    en: 'sapphire1366126441922'
  description:
    en: 'Sample description'
  state:
    typeId: 'state'
    id: 'old-state-id'
  masterVariant:
    id: 1
    prices: [
      {id: 'p-1', value: {currencyCode: 'EUR', centAmount: 100}},
      {id: 'p-2', value: {currencyCode: 'EUR', centAmount: 1000}},
      {id: 'p-3', value: {currencyCode: 'EUR', centAmount: 1100}, country: 'DE'},
      {id: 'p-4', value: {currencyCode: 'EUR', centAmount: 1200}, customerGroup: {id: '984a64de-24a4-42c0-868b-da7abfe1c5f6', typeId: 'customer-group'}}
    ]
  variants: [
    {
      id: 2
      prices: [
        {id: 'p-6', value: {currencyCode: 'EUR', centAmount: 100}},
        {id: 'p-7', value: {currencyCode: 'EUR', centAmount: 2000}},
        {id: 'p-8', value: {currencyCode: 'EUR', centAmount: 2100}, country: 'US'},
        {id: 'p-9', value: {currencyCode: 'EUR', centAmount: 2200}, customerGroup: {id: '59c64f80-6472-474e-b5be-dc57b45b2faf', typeId: 'customer-group'}}
      ]
    }
    { id: 4 }
    {
      id: 77
      prices: [
        {id: 'p-10', value: {currencyCode: 'EUR', centAmount: 5889}, country: 'DE'},
        {id: 'p-11', value: {currencyCode: 'EUR', centAmount: 5889}, country: 'AT'},
        {id: 'p-12', value: {currencyCode: 'EUR', centAmount: 6559}, country: 'FR'},
        {id: 'p-13', value: {currencyCode: 'EUR', centAmount: 13118}, country: 'BE'}
      ]
    }
  ]
  searchKeywords: {
    de: [{text: 'altes'}, {text: 'zeug'}, {text: 'weg'}]
  }

NEW_PRODUCT =
  id: '123'
  name:
    en: 'Foo'
    it: 'Boo'
  slug:
    en: 'foo'
    it: 'boo'
  state:
    typeId: 'state'
    id: 'new-state-id'
  masterVariant:
    id: 1
    prices: [
      {value: {currencyCode: 'EUR', centAmount: 100}},
      {value: {currencyCode: 'EUR', centAmount: 3800}}, # change
      {value: {currencyCode: 'EUR', centAmount: 1100}, country: 'IT'} # change
      {
        value: {currencyCode: 'JPY', centAmount: 9001},
        custom: {
          type: {
            typeId: 'type', id: 'decaf-f005ba11-abaca',
            fields: {superCustom: 'super true'}
          }
        }
      }
    ]
  categoryOrderHints:
    myFancyCategoryId: 0.9
  variants: [
    {
      id: 2
      prices: [
        {value: {currencyCode: 'EUR', centAmount: 100}},
        {value: {currencyCode: 'EUR', centAmount: 2000}},
        {value: {currencyCode: 'EUR', centAmount: 2200}, customerGroup: {id: '59c64f80-6472-474e-b5be-dc57b45b2faf', typeId: 'customer-group'}}
      ]
    }
    { sku: 'new', attributes: [ { name: 'what', value: 'no ID' } ] }
    { id: 7, attributes: [ { name: 'what', value: 'no SKU' } ] }
    {
      id: 77
      prices: [
        {value: {currencyCode: 'EUR', centAmount: 5889}, country: 'DE'},
        {value: {currencyCode: 'EUR', centAmount: 4790}, country: 'DE', customerGroup: {id: 'special-price-id', typeId: 'customer-group'}},
        {value: {currencyCode: 'EUR', centAmount: 5889}, country: 'AT'},
        {value: {currencyCode: 'EUR', centAmount: 4790}, country: 'AT', customerGroup: {id: 'special-price-id', typeId: 'customer-group'}},
        {value: {currencyCode: 'EUR', centAmount: 6559}, country: 'FR'},
        {value: {currencyCode: 'EUR', centAmount: 13118}, country: 'BE'}
      ]
    }
  ]
  searchKeywords: {
    en: [{text: 'new'}, {text: 'search'}, {text: 'keywords'}]
    "fr-BE": [{text: 'bruxelles'}, {text:'liege'}, {text: 'brugge'}]
  }

describe 'ProductSync', ->

  beforeEach ->
    @sync = new ProductSync

  afterEach ->
    @sync = null

  describe ':: config', ->

    it 'should build white/black-listed actions update', ->
      opts = [
        {type: 'base', group: 'white'}
        {type: 'prices', group: 'black'}
      ]
      update = @sync.config(opts).buildActions(NEW_PRODUCT, OLD_PRODUCT).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'changeName', name: {en: 'Foo', de: undefined, it: 'Boo'} }
          { action: 'changeSlug', slug: {en: 'foo', it: 'boo'} }
          { action: 'setCategoryOrderHint', categoryId : 'myFancyCategoryId', orderHint : '0.9' }
          { action: 'setDescription', description: undefined }
          { action: 'setSearchKeywords', searchKeywords: en: [{text: 'new'}, {text: 'search'}, {text: 'keywords'}], "fr-BE": [{text: 'bruxelles'}, {text:'liege'}, {text: 'brugge'}] }
        ]
        version: OLD_PRODUCT.version
      expect(update).toEqual expected_update


  describe ':: buildActions', ->

    it 'should build the action update', ->
      update = @sync.buildActions(NEW_PRODUCT, OLD_PRODUCT).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'removeVariant', id: 4 }
          { action: 'addVariant', sku: 'new', attributes: [ { name: 'what', value: 'no ID' } ] }
          { action: 'addVariant', attributes: [ { name: 'what', value: 'no SKU' } ] }
          { action: 'changeName', name: {en: 'Foo', de: undefined, it: 'Boo'} }
          { action: 'changeSlug', slug: {en: 'foo', it: 'boo'} }
          { action: 'setCategoryOrderHint', categoryId : 'myFancyCategoryId', orderHint : '0.9' }
          { action: 'setDescription', description: undefined }
          { action: 'setSearchKeywords', searchKeywords: en: [{text: 'new'}, {text: 'search'}, {text: 'keywords'}], "fr-BE": [{text: 'bruxelles'}, {text:'liege'}, {text: 'brugge'}]}
          { action: 'transitionState', state: { typeId: 'state', id: 'new-state-id' } }
          { action: 'changePrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 3800}} }
          { action: 'removePrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 1100}, country: 'DE'} }
          { action: 'removePrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 1200}, customerGroup: {id: '984a64de-24a4-42c0-868b-da7abfe1c5f6', typeId: 'customer-group'}} }
          { action: 'removePrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 2100}, country: 'US'} }
          { action: 'removePrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 2200}, customerGroup: {id: '59c64f80-6472-474e-b5be-dc57b45b2faf', typeId: 'customer-group'}} }
          { action: 'removePrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 5889 }, country: 'AT' } }
          { action: 'removePrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 6559 }, country: 'FR' } }
          { action: 'removePrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 13118 }, country: 'BE' } }
          { action: 'addPrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 1100}, country: 'IT'} }
          { action: 'addPrice', variantId: 1, price: {value: {currencyCode: 'JPY', centAmount: 9001}, custom: {type: {typeId: 'type', id: 'decaf-f005ba11-abaca', fields: {superCustom: 'super true'}}}} }
          { action: 'addPrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 2200}, customerGroup: {id: '59c64f80-6472-474e-b5be-dc57b45b2faf', typeId: 'customer-group'}} }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 4790 }, country: 'DE', customerGroup: { id: 'special-price-id', typeId: 'customer-group' } } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 5889 }, country: 'AT' } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 4790 }, country: 'AT', customerGroup: { id: 'special-price-id', typeId: 'customer-group' } } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 6559 }, country: 'FR' } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 13118 }, country: 'BE' } }
        ]
        version: OLD_PRODUCT.version
      expect(update).toEqual expected_update

    it 'should handle mapping actions for new variants without ids', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
          sku: 'v1'
          attributes: [{name: 'foo', value: 'bar'}]
        variants: [
          { id: 2, sku: 'v2', attributes: [{name: 'foo', value: 'qux'}] }
          { id: 3, sku: 'v3', attributes: [{name: 'foo', value: 'baz'}] }
        ]

      newProduct =
        id: '123'
        masterVariant:
          sku: 'v1'
          attributes: [{name: 'foo', value: 'new value'}]
        variants: [
          { id: 2, sku: 'v2', attributes: [{name: 'foo', value: 'another value'}] }
          { id: 3, sku: 'v4', attributes: [{name: 'foo', value: 'i dont care'}] }
          { id: 4, sku: 'v3', attributes: [{name: 'foo', value: 'yet another'}] }
        ]
      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'addVariant', sku: 'v4', attributes: [{ name: 'foo', value: 'i dont care' }] }
          { action: 'setAttribute', variantId: 1, name: 'foo', value: 'new value' }
          { action: 'setAttribute', variantId: 2, name: 'foo', value: 'another value' }
          { action: 'setAttribute', variantId: 3, name: 'foo', value: 'yet another' }
        ]
        version: oldProduct.version
      expect(update).toEqual expected_update

    it 'should handle mapping actions for new variants without masterVariant', ->
      oldProduct =
        id: '123'
        version: 1
        variants: []

      newProduct =
        id: '123'
        variants: [
          { id: 2, sku: 'v2', attributes: [{name: 'foo', value: 'new variant'}] }
        ]
      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'addVariant', sku: 'v2', attributes: [{ name: 'foo', value: 'new variant' }] }
        ]
        version: oldProduct.version
      expect(update).toEqual expected_update
