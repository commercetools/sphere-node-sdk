_ = require 'underscore'
_.mixin require 'underscore-mixins'
ProductUtils = require '../../../lib/sync/utils/product'

###
Match different product attributes and variant prices
###
OLD_PRODUCT =
  id: '123'
  name:
    en: 'SAPPHIRE'
    de: 'Hoo'
  slug:
    en: 'sapphire1366126441922'
  description:
    en: 'Sample description'
  masterVariant:
    id: 1
    prices: [
      { id: 'p-1', value: { currencyCode: 'EUR', centAmount: 1 } }
      { id: 'p-2', value: { currencyCode: 'EUR', centAmount: 7 } }
    ]
  variants: [
    {
      id: 2
      prices: [
        { id: 'p-3', value: { currencyCode: 'USD', centAmount: 3 } }
      ]
    },
    {
      id: 3
      prices: [
        { id: 'p-4', value: { currencyCode: 'EUR', centAmount: 2100 }, country: 'DE' }
        { id: 'p-5', value: { currencyCode: 'EUR', centAmount: 2200 }, customerGroup: { id: '123', typeId: 'customer-group' } }
      ]
    },
    {
      id: 4
      prices: [
        { id: 'p-6', value: { currencyCode: 'YEN', centAmount: 7777 } }
      ]
    },
    {
      id: 5
      prices: []
    }
  ]
NEW_PRODUCT =
  id: '123'
  name:
    en: 'Foo'
    it: 'Boo'
  slug:
    en: 'foo'
    it: 'boo'
  masterVariant:
    id: 1
    prices: [
      { value: { currencyCode: 'EUR', centAmount: 2 } }
      { value: { currencyCode: 'USD', centAmount: 7 } }
    ]
  variants: [
    {
      id: 2
      prices: [
        { value: { currencyCode: 'USD', centAmount: 3 } }
      ]
    },
    {
      id: 3
      prices: [
        { value: { currencyCode: 'EUR', centAmount: 2100 }, country: 'CH' }
        { value: { currencyCode: 'EUR', centAmount: 2200 }, customerGroup: { id: '987', typeId: 'customer-group' } }
      ]
    },
    {
      id: 4
      prices: []
    },
    {
      id: 5
      prices: [
        { value: { currencyCode: 'EUR', centAmount: 999 } }
      ]
    }
  ]

###
Match all different attributes types
###
OLD_ALL_ATTRIBUTES =
  id: '123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'foo', value: 'bar' } # text
      { name: 'dog', value: {en: 'Dog', de: 'Hund', es: 'perro' } } # ltext
      { name: 'num', value: 50 } # number
      { name: 'count', value: { label: 'One', key: 'one' } } # enum
      { name: 'size', value: { label: {en: 'Size'}, key: 'medium' } } # lenum
      { name: 'color', value: { label: {en: 'Color'}, key: 'red' } } # lenum
      { name: 'cost', value: { centAmount: 990, currencyCode: 'EUR' } } # money
    ]
NEW_ALL_ATTRIBUTES =
  id: '123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'foo', value: 'qux' } # text
      { name: 'dog', value: {en: 'Doggy', it: 'Cane', es: 'perro' } } # ltext
      { name: 'num', value: 100 } # number
      { name: 'count', value: 'two' } # enum
      { name: 'size', value: 'small' } # lenum
      { name: 'color', value: 'blue' } # lenum
      { name: 'cost', value: { centAmount: 550, currencyCode: 'EUR' } } # money
    ]

describe 'ProductUtils', ->

  beforeEach ->
    @utils = new ProductUtils

  describe ':: diff', ->
    it 'should diff nothing', ->
      delta = @utils.diff({id: '123', masterVariant: { id: 1 }}, {id: '123', masterVariant: { id: 1 }})
      expect(delta).not.toBeDefined()

    it 'should use SKU to compare variants', ->
      OLD =
        id: 'xyz'
        masterVariant: {
          id: 1
          sku: 'mySKU1'
        }
        variants: [
          { id: 3, sku: 'mySKU2' }
        ]
      NEW =
        id: 'xyz'
        masterVariant: {
          id: 1,
          sku: 'mySKU2'
        }
        variants: [
          { id: 2, sku: 'mySKU1' }
        ]
      delta = @utils.diff(OLD, NEW)
      expected_delta =
        masterVariant:
          sku: [ 'mySKU1', 'mySKU2' ]
          _MATCH_CRITERIA: [ 'mySKU1', 'mySKU2' ]
        variants:
          0: [
            {
              id: 2
              sku: 'mySKU1'
              _MATCH_CRITERIA: 'mySKU1'
              _NEW_ARRAY_INDEX: '0'
            }
          ]
          _t: 'a'
          _0: [
            {
              id: 3
              sku: 'mySKU2'
              _MATCH_CRITERIA: 'mySKU2'
              _EXISTING_ARRAY_INDEX: '0'
            },
            0,
            0
          ]

      expect(delta).toEqual expected_delta

    it 'should throw an Error if variant has no ID nor SKU', ->
      OLD =
        id: 'xyz'
        variants: [
          {attributes: [foo: 'bar']}
        ]
      NEW =
        id: 'xyz'
        masterVariant:
          attributes: [foo: 'bar']
      expect(=> @utils.diff(OLD, NEW)).toThrow new Error 'A variant must either have an ID or an SKU.'

    it 'should diff basic attributes (name, slug, description, searchKeywords)', ->
      OLD =
        id: '123'
        name:
          en: 'Foo'
          de: 'Hoo'
        slug:
          en: 'foo'
        description:
          en: 'Sample'
        searchKeywords:
          en: [ {text: 'old'}, {text: 'keywords'} ]
          de: [ {text: 'alte'}, {text: 'schlagwoerter'} ]
        masterVariant:
          id: 1
      NEW =
        id: '123'
        name:
          en: 'Boo'
        slug:
          en: 'boo'
        description:
          en: 'Sample'
          it: 'Esempio'
        searchKeywords:
          en: [ {text: 'new'}, {text: 'keywords'} ]
          it: [ {text: 'veccie'}, {text: 'parole'} ]
        masterVariant:
          id: 1

      delta = @utils.diff(OLD, NEW)
      expected_delta =
        name:
          en: ['Foo', 'Boo']
          de: ['Hoo', 0, 0 ]
        slug:
          en: ['foo', 'boo']
        description:
          it: ['Esempio']
        searchKeywords:
          en : 0 : [ { text : 'new' } ], 1 : [ { text : 'keywords' } ], _t : 'a', _0 : [ { text : 'old' }, 0, 0 ], _1 : [ { text : 'keywords' }, 0, 0 ]
          de : [ [ { text : 'alte' }, { text : 'schlagwoerter' } ], 0, 0 ]
          it: [[ {text: 'veccie'}, {text: 'parole'} ]]
      expect(delta).toEqual expected_delta

    it 'should diff missing attribute', ->
      delta = @utils.diff(OLD_PRODUCT, NEW_PRODUCT)
      expected_delta =
        name:
          en: ['SAPPHIRE', 'Foo'] # changed
          de: ['Hoo', 0, 0]
          it: ['Boo']
        slug:
          en: ['sapphire1366126441922', 'foo']
          it: ['boo']
        description: [en: 'Sample description', 0, 0] # deleted
        masterVariant:
          prices:
            0:
              id: ['p-1', 0,0]
              value:
                centAmount: [1, 2]
            1:
              id: ['p-2', 0,0]
              value:
                currencyCode: ['EUR', 'USD']
            _t: 'a'
        variants:
          0:
            prices:
              0:
                id: ['p-3', 0, 0]
              _t: 'a'
            _EXISTING_ARRAY_INDEX: ['0', 0, 0],
            _NEW_ARRAY_INDEX: ['0']
          1:
            prices:
              0:
                id: ['p-4', 0, 0],
                country: ['DE', 'CH']
              1:
                id: ['p-5', 0, 0],
                customerGroup:
                  id: ['123', '987']
              _t: 'a'
            _EXISTING_ARRAY_INDEX: ['1', 0, 0],
            _NEW_ARRAY_INDEX: ['1']
          2:
            prices:
              _t: 'a',
              _0: [{
                id: 'p-6',
                value:
                  currencyCode: 'YEN',
                  centAmount: 7777
                _MATCH_CRITERIA: '0'
              }, 0, 0]
            _EXISTING_ARRAY_INDEX: ['2', 0, 0],
            _NEW_ARRAY_INDEX: ['2']
          3:
            prices:
              0: [{
                value:
                  currencyCode: 'EUR',
                  centAmount: 999
                _MATCH_CRITERIA: '0'
              }],
              _t: 'a'
            _EXISTING_ARRAY_INDEX: ['3', 0, 0],
            _NEW_ARRAY_INDEX: ['3']
          _t: 'a'
      expect(delta).toEqual expected_delta

    it 'should diff different attribute types', ->
      delta = @utils.diff(OLD_ALL_ATTRIBUTES, NEW_ALL_ATTRIBUTES)
      expected_delta =
        masterVariant:
          attributes:
            0: { value: ['bar', 'qux'] }
            1:
              value:
                en: ['Dog', 'Doggy']
                it: ['Cane']
                de: ['Hund', 0, 0]
            2: { value: [50, 100] }
            3: { value: ['one', 'two'] }
            4: { value: ['medium', 'small'] }
            5: { value: ['red', 'blue'] }
            6: { value: { centAmount: [990, 550] } }
            _t: 'a'

      expect(delta).toEqual expected_delta

    it 'should patch enums', ->
      EXISTING_ENUM_ATTRIBUTES =
        id: 'enum-101'
        masterVariant:
          id: 1
          attributes: [
            { name: 'count', value: { label: 'My Key', key: 'myKey' } } # enum
            { name: 'size', value: { label: { en: 'Size' }, key: 'big' } } # lenum
            { name: 'color', value: { label: { de: 'Farbe' }, key: 'red' } } # lenum
          ]
        variants: [
          { id: 2, attributes: [
            { name: 'tags', value: [ { label: { en: 'Tags1' }, key: 'tag1' } ] } # lenum
          ]}
        ]
      NEW_ENUM_ATTRIBUTES =
        id: 'enum-101'
        masterVariant:
          id: 1
          attributes: [
            { name: 'count', value: 'myKey' } # enum - unchanged
            { name: 'size', value: 'small' } # lenum - changed key
            # color is removed
          ]
        variants: [
          { id: 2, attributes: [
            { name: 'tags', value: [ { label: { en: 'Tags2' }, key: 'tag2' } ] } # lenum
          ]}
        ]

      delta = @utils.diff(EXISTING_ENUM_ATTRIBUTES, NEW_ENUM_ATTRIBUTES)
      expected_delta =
        masterVariant:
          attributes:
            1: { value: ['big', 'small'] }
            _t: 'a'
            _2: [ { name: 'color', value: 'red'}, 0, 0 ]
        variants:
          0:
            attributes:
              0:
                value:
                  0: ['tag2']
                  _t: 'a'
                  _0: ['tag1', 0, 0]
              _t: 'a'
            _NEW_ARRAY_INDEX: ['0']
            _EXISTING_ARRAY_INDEX: ['0', 0, 0]
          _t: 'a'

      expect(delta).toEqual expected_delta

  describe ':: getRemovedVariants', ->

    it 'should throw an error when removing a variant without id and sku', ->
      oldVariants = [
        {
          # no id or sku
          key: 'newVar'
        }
      ]
      newVariants = []

      expect( () => @utils.getRemovedVariants(newVariants, oldVariants))
        .toThrow new Error('ProductSync does need at least one of "id" or "sku" to generate a remove action')

  describe ':: buildChangeMasterVariantAction', ->

    it 'should throw an error when changing a masterVariant without id and sku', ->
      newMasterVariant =
        key: 'newVar'

      oldMasterVariant =
        key: 'oldVar'

      expect( () => @utils.buildChangeMasterVariantAction(newMasterVariant, oldMasterVariant))
        .toThrow new Error('ProductSync needs at least one of "id" or "sku" to generate changeMasterVariant update action')

  describe ':: buildVariantBaseAction', ->

    it 'should build update actions for variant base properties', ->
      oldVariant =
        id: '123'

      newVariant =
        id: '123'
        sku: 'sku123'
        key: 'key123'

      delta = @utils.diff oldVariant, newVariant
      update = @utils.buildVariantBaseAction(delta, oldVariant)
      expected_update = [
        { action : 'setSku', variantId : '123', sku : 'sku123' }
        { action : 'setProductVariantKey', variantId : '123', key : 'key123' }
      ]
      expect(update).toEqual expected_update

  describe ':: actionsMapBase', ->

    it 'should diff if basic attribute is undefined', ->
      OLD =
        key: 'oldKey'
        id: '123'
        name:
          en: 'Foo'
        slug:
          en: 'foo'
        masterVariant:
          id: 1
      NEW =
        key: 'newKey'
        id: '123'
        name:
          de: 'Boo'
        slug:
          en: 'boo'
        description:
          en: 'Sample'
          it: 'Esempio'
        searchKeywords:
          en: [ {text: 'new'}, {text: 'keyword'} ]
        masterVariant:
          id: 1

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapBase(delta, OLD)
      expected_update = [
        { action: 'setKey', key: 'newKey' }
        { action: 'changeName', name: {en: undefined, de: 'Boo'} }
        { action: 'changeSlug', slug: {en: 'boo'} }
        { action: 'setDescription', description: {en: 'Sample', it: 'Esempio'} }
        { action: 'setSearchKeywords', searchKeywords: {en: [ {text: 'new'}, {text: 'keyword'} ]} }
      ]
      expect(update).toEqual expected_update

    it 'should diff long text', ->
      OLD =
        id: '123'
        name:
          en: '`Churchill` talked about climbing a wall which is leaning toward you and kissing a woman who is leaning away from you.'
        slug:
          en: 'churchill-talked-about-climbing-a-wall-which-is-leaning-toward-you-and-kissing-a-woman-who-is-leaning-away-from-you'
        description:
          en: 'There are two things that are more difficult than making an after-dinner speech: climbing a wall which is leaning toward you and kissing a girl who is leaning away from you.'
        masterVariant:
          id: 1
      NEW =
        id: '123'
        name:
          en: '`Churchill` talked about climbing a BIG wall which WAS leaning toward you and kissing a woman who WAS leaning away from you.'
        slug:
          en: 'churchill-talked-about-climbing-a-big-wall-which-was-leaning-toward-you-and-kissing-a-woman-who-was-leaning-away-from-you'
        description:
          en: 'There are three things that are more difficult than making an after-dinner speech: climbing a mountain which is leaning toward you and slapping a girl who is leaning away from you.'
        masterVariant:
          id: 1

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapBase(delta, OLD)
      expected_update = [
        { action: 'changeName', name: {en: NEW.name.en} }
        { action: 'changeSlug', slug: {en: NEW.slug.en} }
        { action: 'setDescription', description: {en: NEW.description.en} }
      ]
      expect(update).toEqual expected_update

    it 'should diff meta attributes', ->
      OLD =
        id: '123'
        metaTitle:
          en: 'A title'
        metaDescription:
          en: 'A description'
        metaKeywords:
          en: 'foo, bar'
        masterVariant:
          id: 1
      NEW =
        id: '123'
        metaTitle:
          en: 'A new title'
        metaDescription:
          en: 'A new description'
        metaKeywords:
          en: 'foo, bar, qux'
        masterVariant:
          id: 1

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapBase(delta, OLD)
      expected_update = [
        {
          action: 'setMetaTitle'
          metaTitle: {en: 'A new title'}
        }
        {
          action: 'setMetaDescription'
          metaDescription: {en: 'A new description'}
        }
        {
          action: 'setMetaKeywords'
          metaKeywords: {en: 'foo, bar, qux'}
        }
      ]
      expect(update).toEqual expected_update

    it 'should transform setCategoryOrderHint actions correctly', ->
      OLD =
        id: '123'
        masterVariant:
          id: 1
        categoryOrderHints:
          abc: '0.9'
      NEW =
        id: '123'
        masterVariant:
          id: 1
        categoryOrderHints:
          abc: '0.3'
          anotherCategoryId: '0.1'

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapCategoryOrderHints(delta, OLD)
      expected_update = [
        {
          action: 'setCategoryOrderHint'
          categoryId: 'abc'
          orderHint: '0.3'
        }, {
          action: 'setCategoryOrderHint'
          categoryId: 'anotherCategoryId'
          orderHint: '0.1'
        },
      ]
      expect(update).toEqual expected_update

    it 'should generate a setCategoryOrderHint action to unset order hints', ->
      OLD =
        id: '123'
        masterVariant:
          id: 1
        categoryOrderHints:
          abc: '0.9'
          anotherCategoryId: '0.5'
          categoryId: '0.5'
      NEW =
        id: '123'
        masterVariant:
          id: 1
        categoryOrderHints:
          abc: null
          anotherCategoryId: '0'
          categoryId: ''

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapCategoryOrderHints(delta, OLD)
      expected_update = [
        {
          action: 'setCategoryOrderHint'
          categoryId: 'abc',
          orderHint: undefined,
        },
        {
          action: 'setCategoryOrderHint'
          categoryId: 'anotherCategoryId',
          orderHint: '0',
        }
        {
          action: 'setCategoryOrderHint'
          categoryId: 'categoryId',
          orderHint: undefined,
        }
      ]
      expect(update).toEqual expected_update

    it 'should should not create an action if categoryOrderHint is empty', ->
      OLD =
        id: '123'
        categoryOrderHints: {}
        metaTitle:
          en: 'A title'
        masterVariant:
          id: 1
      NEW =
        id: '123'
        metaTitle:
          en: 'A new title'
        masterVariant:
          id: 1

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapBase(delta, OLD)
      expected_update = [
        {
          action: 'setMetaTitle'
          metaTitle: {en: 'A new title'}
        }
      ]
      expect(update).toEqual expected_update

  describe ':: actionsMapAttributes', ->

    it 'should create update action for attribute', ->
      _oldVariant = {
        id: 3, attributes: [{ name: 'foo', value: 'bar' }]
      }
      _newVariant = {
        id: 3, attributes: [{ name: 'foo', value: 'CHANGED' }]
      }

      diff = @utils.diff _oldVariant, _newVariant
      update = @utils.buildVariantAttributesActions diff.attributes, _oldVariant, _newVariant

      expected_update = [
        { action: 'setAttribute', variantId: 3, name: 'foo', value: 'CHANGED' }
      ]
      expect(update).toEqual expected_update

    it 'should build attribute update actions for all types', ->
      oldVariant = OLD_ALL_ATTRIBUTES.masterVariant
      newVariant = NEW_ALL_ATTRIBUTES.masterVariant
      diff = @utils.diff oldVariant, newVariant
      update = @utils.buildVariantAttributesActions diff.attributes, oldVariant, newVariant
      expected_update =
        [
          { action: 'setAttribute', variantId: 1, name: 'foo', value: 'qux' }
          { action: 'setAttribute', variantId: 1, name: 'dog', value: {en: 'Doggy', it: 'Cane', de: undefined, es: 'perro'} }
          { action: 'setAttribute', variantId: 1, name: 'num', value: 100 }
          { action: 'setAttribute', variantId: 1, name: 'count', value: 'two' }
          { action: 'setAttribute', variantId: 1, name: 'size', value: 'small' }
          { action: 'setAttribute', variantId: 1, name: 'color', value: 'blue' }
          { action: 'setAttribute', variantId: 1, name: 'cost', value: { centAmount: 550, currencyCode: 'EUR' } }
        ]
      expect(update).toEqual expected_update

    it 'should build actions for attributes with long text as values', ->
      newVariant =
        id: 1
        sku: 'HARJPUL101601202'
        attributes: [
          {
            name: 'images',
            value: '//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-1.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-2.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-4.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-5.jpg'
          },
          {
            name: 'textAttribute',
            value: '[{"textAttributeValue":{"fr-CH":"","de-CH":"","it-CH":"","de-DE":"<p><strong>Some random text to make this longer than the value that was in jsondiffpatch.textDiff.minLength = 300. This should be now a correctly formatted JSON. However, after jsondiffpatch, it will be changed into a different string”</p>","en-GB":"","es-ES":"","fr-FR":""}}]'
          },
          {
            name: 'localized_images',
            value: {
              en: '//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-1.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-2.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-4.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-5.jpg'
            }
          }
        ]
        prices: []
        images: []
      oldVariant =
        id: 1
        sku: 'HARJPUL101601202'
        attributes: [
          {
            name: 'images',
            value: 'http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-1/2000/2000/p-HARJPUL101601-1.jpg;http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-2/2000/2000/p-HARJPUL101601-2.jpg;http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-4/2000/2000/p-HARJPUL101601-4.jpg;http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-5/2000/2000/p-HARJPUL101601-5.jpg'
          },
          {
            name: 'textAttribute',
            value: '[{"textAttributeValue":{"fr-CH":"","de-CH":"","it-CH":"","de-DE":"<p><strong>Some random text to make this longer than the value that was in jsondiffpatch.textDiff.minLength = 300. Also this will be badly formatted JSON”</p>","en-GB":"","es-ES":"","fr-FR":""fr-CH":"","fr-FR": "","it-IT": "","nl-NL": "","ru-RU": ""},"testberichte_video": ""}]'
          },
          {
            name: 'localized_images',
            value: {
              en: 'http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-1/2000/2000/p-HARJPUL101601-1.jpg;http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-2/2000/2000/p-HARJPUL101601-2.jpg;http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-4/2000/2000/p-HARJPUL101601-4.jpg;http://images.luxodo.com/html/zoom/luxodo/p-HARJPUL101601-5/2000/2000/p-HARJPUL101601-5.jpg'
            }
          }
        ]
        prices: []
        images: []

      diff = @utils.diff oldVariant, newVariant
      update = @utils.buildVariantAttributesActions diff.attributes, oldVariant, newVariant
      expected_update =
        [
          { action: 'setAttribute', variantId: 1, name: 'images', value: '//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-1.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-2.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-4.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-5.jpg' },
          { action: 'setAttribute', variantId: 1, name: 'textAttribute', value: '[{"textAttributeValue":{"fr-CH":"","de-CH":"","it-CH":"","de-DE":"<p><strong>Some random text to make this longer than the value that was in jsondiffpatch.textDiff.minLength = 300. This should be now a correctly formatted JSON. However, after jsondiffpatch, it will be changed into a different string”</p>","en-GB":"","es-ES":"","fr-FR":""}}]' },
          { action: 'setAttribute', variantId: 1, name: 'localized_images', value: { en: '//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-1.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-2.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-4.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-5.jpg' } }
        ]
      expect(update).toEqual expected_update

    it 'should not create update action if attribute is not changed', ->
      oldVariant =
        sku: 'TEST MASTER VARIANT'
        attributes: [
          {
            name: 'test_attribute',
            value: [
              {
                label: {
                  'de': 'schwarz'
                },
                key: 'SW'
              },
              {
                label: {
                  'de': 'grün'
                },
                key: 'GN'
              }
            ]
          }
        ]

      newVariant =
        sku: 'TEST MASTER VARIANT'
        attributes: [
          {
            'name': 'test_attribute',
            'value': [
              {
                'label': {
                  'de': 'grün'
                },
                'key': 'GN'
              },
              {
                'label': {
                  'de': 'schwarz'
                },
                'key': 'SW'
              }
            ]
          }
        ]


      diff = @utils.diff oldVariant, newVariant
      update = @utils.buildVariantAttributesActions diff.attributes, oldVariant, newVariant
      expect(update.length).toBe(0)

    it 'should create update action if attribute value item is removed', ->
      newVariant =
        sku: 'TEST MASTER VARIANT'
        attributes: [
          {
            'name': 'test_attribute',
            'value': [
              'a', 'b'
            ]
          }
        ]

      oldVariant =
        sku: 'TEST MASTER VARIANT'
        attributes: [
          {
            name: 'test_attribute',
            value: [
              'a', 'b', 'c'
            ]
          }
        ]

      diff = @utils.diff oldVariant, newVariant
      update = @utils.buildVariantAttributesActions diff.attributes, oldVariant, newVariant
      expect(update.length).toBe(1)
      expect(update[0].action).toBe 'setAttribute'
      expect(update[0].name).toBe 'test_attribute'
      expect(update[0].value).toEqual [ 'a', 'b' ]

    it 'should create update action if attribute value item is added', ->
      newVariant =
        sku: 'TEST MASTER VARIANT'
        attributes: [
          {
            'name': 'test_attribute',
            'value': [
              'a', 'b', 'c'
            ]
          }
        ]

      oldVariant =
        sku: 'TEST MASTER VARIANT'
        attributes: [
          {
            name: 'test_attribute',
            value: [
              'a', 'b'
            ]
          }
        ]

      diff = @utils.diff oldVariant, newVariant
      update = @utils.buildVariantAttributesActions diff.attributes, oldVariant, newVariant
      expect(update.length).toBe(1)
      expect(update[0].action).toBe 'setAttribute'
      expect(update[0].name).toBe 'test_attribute'
      expect(update[0].value).toEqual [ 'a', 'b', 'c' ]

  describe ':: actionsMapReferences', ->

    describe ':: tax-category', ->

      beforeEach ->
        @utils = new ProductUtils
        @OLD_REFERENCE =
          id: '123'
          taxCategory:
            typeId: 'tax-category'
            id: 'tax-de'
          masterVariant:
            id: 1

        @NEW_REFERENCE =
          id: '123'
          taxCategory:
            typeId: 'tax-category'
            id: 'tax-us'
          masterVariant:
            id: 1

      it 'should build action to change tax-category', ->
        delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
        update = @utils.actionsMapReferences delta, @NEW_REFERENCE, @OLD_REFERENCE
        expected_update = [
          { action: 'setTaxCategory', taxCategory: { typeId: 'tax-category', id: 'tax-us' } }
        ]
        expect(update).toEqual expected_update

      it 'should build action to delete tax-category', ->
        delete @NEW_REFERENCE.taxCategory
        delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
        update = @utils.actionsMapReferences delta, @NEW_REFERENCE, @OLD_REFERENCE
        expected_update = [
          { action: 'setTaxCategory' }
        ]
        expect(update).toEqual expected_update

      it 'should build action to add tax-category', ->
        delete @OLD_REFERENCE.taxCategory
        delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
        update = @utils.actionsMapReferences delta, @NEW_REFERENCE, @OLD_REFERENCE
        expected_update = [
          { action: 'setTaxCategory', taxCategory: { typeId: 'tax-category', id: 'tax-us' } }
        ]
        expect(update).toEqual expected_update

    describe ':: state', ->

      beforeEach ->
        @utils = new ProductUtils
        @OLD_REFERENCE =
          id: '123'
          state:
            typeId: 'state'
            id: 'old-state-id'
          masterVariant:
            id: 1

        @NEW_REFERENCE =
          id: '123'
          state:
            typeId: 'state'
            id: 'new-state-id'
          masterVariant:
            id: 1

      it 'should build a transitionState action for the initial state', ->
        oldRef = _.extend({}, @OLD_REFERENCE, { state: null })
        delta = @utils.diff oldRef, @NEW_REFERENCE
        actual = @utils.actionsMapReferences(
          delta, @NEW_REFERENCE, oldRef
        )
        expected = [{
          action: 'transitionState',
          state: { typeId: 'state', id: 'new-state-id' }
        }]
        expect(actual).toEqual(expected)

      it 'should not build a transitionState action if no state is provided
      even if the product already has a state', ->
        # test with { state: null }
        newRef = _.extend({}, @NEW_REFERENCE, { state: null })
        delta = @utils.diff @OLD_REFERENCE, newRef
        actual = @utils.actionsMapReferences(
          delta, newRef, @OLD_REFERENCE
        )
        expected = []
        expect(actual).toEqual(expected)

        # test without state
        delete newRef.state
        delta = @utils.diff @OLD_REFERENCE, newRef
        actual = @utils.actionsMapReferences(
          delta, newRef, @OLD_REFERENCE
        )
        expected = []
        expect(actual).toEqual(expected)

      it 'should build a transitionState action for a state change', ->
        delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
        actual = @utils.actionsMapReferences(
          delta, @NEW_REFERENCE, @OLD_REFERENCE
        )
        expected = [{
          action: 'transitionState',
          state: { typeId: 'state', id: 'new-state-id' }
        }]
        expect(actual).toEqual(expected)

  describe ':: actionsMapCategories (category)', ->

    beforeEach ->
      @utils = new ProductUtils
      @OLD_REFERENCE =
        id: '123'
        categories: [
          { typeId: 'category', id: 'cat1' }
          { typeId: 'category', id: 'cat2' }
        ]
        masterVariant:
          id: 1

      @NEW_REFERENCE =
        id: '123'
        categories: [
          { typeId: 'category', id: 'cat1' }
          { typeId: 'category', id: 'cat3' }
        ]
        masterVariant:
          id: 1

    it 'should build actions to change category', ->
      delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
      update = @utils.actionsMapCategories delta, @OLD_REFERENCE, @NEW_REFERENCE
      expected_update = [
        { action: 'removeFromCategory', category: { typeId: 'category', id: 'cat2' } }
        { action: 'addToCategory', category: { typeId: 'category', id: 'cat3' } }
      ]
      expect(update).toEqual expected_update

    it 'should ignore changes in ordering of category references', ->
      before =
        id: '123'
        categories: [
          { typeId: 'category', id: 'cat1' }
          { typeId: 'category', id: 'cat2' }
        ]
        masterVariant:
          id: 1

      after =
        id: '123'
        categories: [
          { typeId: 'category', id: 'cat2' }
          { typeId: 'category', id: 'cat1' }
        ]
        masterVariant:
          id: 1

      delta = @utils.diff before, after
      update = @utils.actionsMapCategories delta, before, after
      expect(update).toEqual []
