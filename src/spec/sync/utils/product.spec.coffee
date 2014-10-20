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
      { value: { currencyCode: 'EUR', centAmount: 1 } }
      { value: { currencyCode: 'EUR', centAmount: 7 } }
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
        { value: { currencyCode: 'EUR', centAmount: 2100 }, country: 'DE' }
        { value: { currencyCode: 'EUR', centAmount: 2200 }, customerGroup: { id: '123', typeId: 'customer-group' } }
      ]
    },
    {
      id: 4
      prices: [
        { value: { currencyCode: 'YEN', centAmount: 7777 } }
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

OLD_VARIANT =
  id: '123'
  masterVariant:
    id: 1
  variants: [
    { id: 2 }
    { id: 3, attributes: [{ name: 'foo', value: 'bar' }] }
    { id: 4, sku: 'v4' }
    { id: 5 }
    { id: 6, sku: 'v6' }
    { id: 7, sku: 'v7', attributes: [{ name: 'foo', value: 'bar' }] }
  ]

NEW_VARIANT =
  id: '123'
  masterVariant:
    id: 1
  variants: [
    { id: 2, sku: 'SKUadded' }
    { id: 3, attributes: [{ name: 'foo', value: 'CHANGED' }] }
    { id: 6, sku: 'SKUchanged!' }
    { id: 7, attributes: [{ name: 'foo', value: 'bar' }] }
    { id: 8, attributes: [{ name: 'some', value: 'thing' }] }
    { id: 9, attributes: [{ name: 'yet', value: 'another' }] }
    { sku: 'v10', attributes: [{ name: 'something', value: 'else' }] }
    { id: 100, sku: 'SKUwins' }
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

###
Match (l)enum the way they would be created
###
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

###
Match different attributes on variant level
###
OLD_ATTRIBUTES =
  id: '123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'uid', value: '20063672' },
      { name: 'length', value: 160 },
      { name: 'wide', value: 85 },
      { name: 'bulkygoods', value: { label: 'Ja', key: 'YES' } },
      { name: 'ean', value: '20063672' }
    ]
  variants: [
    {
      id: 2
      attributes: [
        { name: 'uid', value: '20063672' },
        { name: 'length', value: 160 },
        { name: 'wide', value: 85 },
        { name: 'bulkygoods', value: { label: 'Ja', key: 'YES' } },
        { name: 'ean', value: '20063672' }
      ]
    },
    {
      id: 3
      attributes: []
    }
    {
      id: 4
      attributes: [
        { name: 'uid', value: '1234567' },
        { name: 'length', value: 123 },
        { name: 'bulkygoods', value: { label: 'Si', key: 'SI' } }
      ]
    }
  ]
NEW_ATTRIBUTES =
  id: '123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'uid', value: '20063675' },
      { name: 'length', value: 160 },
      { name: 'wide', value: 10 },
      { name: 'bulkygoods', value: 'NO' },
      { name: 'ean', value: '20063672' }
    ]
  variants: [
    {
      id: 2
      attributes: [
        { name: 'uid', value: '20055572' },
        { name: 'length', value: 333 },
        { name: 'wide', value: 33 },
        { name: 'bulkygoods', value: 'YES' },
        { name: 'ean', value: '20063672' }
      ]
    },
    {
      id: 3
      attributes: [
        { name: 'uid', value: '00001' },
        { name: 'length', value: 500 },
        { name: 'bulkygoods', value: 'SI' }
      ]
    },
    {
      id: 4
      attributes: []
    }
  ]

###
Match different attributes that have the `SameForAll` constraint
###
OLD_SAME_FOR_ALL_ATTRIBUTES =
  id: '123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'brand', value: 'Awesome Shoes' }
    ]
  variants: [
    {
      id: 2
      attributes: [
        { name: 'brand', value: 'Awesome Shoes' },
      ]
    },
    {
      id: 3
      attributes: [
        { name: 'brand', value: 'Awesome Shoes' },
      ]
    },
    {
      id: 4
      attributes: [
        { name: 'tags', value: [ { key: 'tag1', label: { en: 'Tag 1' } } ] },
      ]
    }
  ]


NEW_SAME_FOR_ALL_ATTRIBUTES =
  id: '123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'brand', value: 'Cool Shirts' }
    ]
  variants: [
    {
      id: 2
      attributes: [
        { name: 'brand', value: 'Cool Shirts' },
      ]
    },
    {
      id: 3
      attributes: [
        { name: 'brand', value: 'Cool Shirts' },
      ]
    },
    {
      id: 4
      attributes: [
        { name: 'tags', value: [ { key: 'tag2', label: { en: 'Tag 2' } } ] },
      ]
    }
  ]

###
Match different attributes that have `set` as base type
###
OLD_SET_ATTRIBUTES =
  id: 'set123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'colors', value: [
        { key: 'green', label: 'Green' }
        { key: 'red', label: 'Red' }
      ] }
    ]
  variants: [
    {
      id: 2
      attributes: [
        { name: 'colors', value: [
          { key: 'black', label: 'Black' }
          { key: 'white', label: 'White' }
        ] }
      ]
    },
    {
      id: 3
      attributes: [
        { name: 'colors', value: [ { key: 'yellow', label: 'Yellow' } ] },
      ]
    },
    {
      id: 4
      attributes: []
    }
  ]

NEW_SET_ATTRIBUTES =
  id: 'set123'
  masterVariant:
    id: 1
    attributes: [
      { name: 'colors', value: [ 'pink', 'orange' ] }
    ]
  variants: [
    {
      id: 2
      attributes: [
        { name: 'colors', value: [ 'black', 'white' ] },
      ]
    },
    {
      id: 3
      attributes: []
    },
    {
      id: 4
      attributes: [
        { name: 'colors', value: [ 'gray' ] },
      ]
    }
  ]

###
Match images
###
OLD_IMAGE_PRODUCT =
  id: '123'
  masterVariant:
    id: 1
    images: []
  variants: [
    {
      id: 2
      images: [
        { url: '//example.com/image.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
      ]
    },
    {
      id: 3
      images: [
        { url: '//example.com/image.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
        { url: '//example.com/image.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
        { url: '//example.com/image.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
      ]
    },
    {
      id: 4
      images: [
        { url: '//example.com/old.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
      ]
    },
    {
      id: 5
      images: []
    }
  ]
NEW_IMAGE_PRODUCT =
  id: '123'
  masterVariant:
    id: 1
    images: []
  variants: [
    {
      id: 2
      images: [
        { url: '//example.com/image.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
      ]
    },
    {
      id: 3
      images: [
        { url: '//example.com/image.png', label: 'CHANGED', dimensions: { x: 1024, y: 768 } }
        { url: '//example.com/image.png', label: 'foo', dimensions: { x: 400, y: 300 } }
        { url: '//example.com/CHANGED.jpg', label: 'foo', dimensions: { x: 400, y: 300 } }
      ]
    },
    {
      id: 4
      images: []
    },
    {
      id: 5
      images: [
        { url: '//example.com/new.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
      ]
    }
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

    it 'should diff basic attributes (name, slug, description)', ->
      OLD =
        id: '123'
        name:
          en: 'Foo'
          de: 'Hoo'
        slug:
          en: 'foo'
        description:
          en: 'Sample'
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
              value:
                centAmount: [1, 2]
            1:
              value:
                currencyCode: ['EUR', 'USD']
            _t: 'a'
        variants:
          0:
            _NEW_ARRAY_INDEX: ['0']
            _EXISTING_ARRAY_INDEX: ['0', 0, 0]
          1:
            prices:
              0:
                country: ['DE', 'CH']
              1:
                customerGroup:
                  id: ['123', '987']
              _t: 'a'
            _NEW_ARRAY_INDEX: ['1']
            _EXISTING_ARRAY_INDEX: ['1', 0, 0]
          2:
            prices:
              _t: 'a'
              _0: [ { value: { currencyCode: 'YEN', centAmount: 7777 }, _MATCH_CRITERIA: '0' }, 0, 0 ]
            _NEW_ARRAY_INDEX: ['2']
            _EXISTING_ARRAY_INDEX: ['2', 0, 0]
          3:
            prices:
              0: [ { value: { currencyCode: 'EUR', centAmount: 999 }, _MATCH_CRITERIA: '0' } ]
              _t: 'a'
            _NEW_ARRAY_INDEX: ['3']
            _EXISTING_ARRAY_INDEX: ['3', 0, 0]
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

  describe ':: actionsMapBase', ->

    it 'should diff if basic attribute is undefined', ->
      OLD =
        id: '123'
        name:
          en: 'Foo'
        slug:
          en: 'foo'
        masterVariant:
          id: 1
      NEW =
        id: '123'
        name:
          de: 'Boo'
        slug:
          en: 'boo'
        description:
          en: 'Sample'
          it: 'Esempio'
        masterVariant:
          id: 1

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapBase(delta, OLD)
      expected_update = [
        { action: 'changeName', name: {en: undefined, de: 'Boo'} }
        { action: 'changeSlug', slug: {en: 'boo'} }
        { action: 'setDescription', description: {en: 'Sample', it: 'Esempio'} }
      ]
      expect(update).toEqual expected_update

  describe ':: actionsMapMetaAttributes', ->

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
      update = @utils.actionsMapMetaAttributes(delta, OLD)
      expected_update = [
        {
          action: 'setMetaAttributes'
          metaTitle: {en: 'A new title'}
          metaDescription: {en: 'A new description'}
          metaKeywords: {en: 'foo, bar, qux'}
        }
      ]
      expect(update).toEqual expected_update

    it 'should build meta attributes action with original values, if not all are changed', ->
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
        masterVariant:
          id: 1

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapMetaAttributes(delta, OLD)
      expected_update = [
        {
          action: 'setMetaAttributes'
          metaTitle: {en: 'A new title'}
          metaDescription: {en: 'A description'}
          metaKeywords: {en: 'foo, bar'}
        }
      ]
      expect(update).toEqual expected_update

  describe ':: actionsMapVariants', ->

    it 'should build variant actions', ->
      delta = @utils.diff OLD_VARIANT, NEW_VARIANT
      expected_delta =
        variants:
          0: [ { id: 2, sku: 'SKUadded', _MATCH_CRITERIA: 'SKUadded', _NEW_ARRAY_INDEX: '0' } ]
          1: { attributes: { 0: { value: [ 'bar', 'CHANGED' ] }, _t: 'a' }, _NEW_ARRAY_INDEX: ['1'], _EXISTING_ARRAY_INDEX: ['1', 0, 0] }
          2: [ { id: 6, sku: 'SKUchanged!', _MATCH_CRITERIA: 'SKUchanged!', _NEW_ARRAY_INDEX: '2' } ]
          3: [ { id: 7, attributes: [ { name: 'foo', value: 'bar' } ], _MATCH_CRITERIA: '7', _NEW_ARRAY_INDEX: '3' } ]
          4: [ { id: 8, attributes: [ { name: 'some', value: 'thing' } ], _MATCH_CRITERIA: '8', _NEW_ARRAY_INDEX: '4' } ]
          5: [ { id: 9, attributes: [ { name: 'yet', value: 'another' } ], _MATCH_CRITERIA: '9', _NEW_ARRAY_INDEX: '5' } ]
          6: [ { sku: 'v10', attributes: [ { name: 'something', value: 'else' } ], _MATCH_CRITERIA: 'v10', _NEW_ARRAY_INDEX: '6' } ]
          7: [ { id: 100, sku: 'SKUwins', _MATCH_CRITERIA: 'SKUwins', _NEW_ARRAY_INDEX: '7' } ]

          _t: 'a'
          _0: [ { id: 2, _MATCH_CRITERIA: '2', _EXISTING_ARRAY_INDEX: '0' }, 0, 0 ]
          _2: [ { id: 4, sku: 'v4', _MATCH_CRITERIA: 'v4', _EXISTING_ARRAY_INDEX: '2' }, 0, 0 ]
          _3: [ { id: 5, _MATCH_CRITERIA: '5', _EXISTING_ARRAY_INDEX: '3' }, 0, 0 ]
          _4: [ { id: 6, sku: 'v6', _MATCH_CRITERIA: 'v6', _EXISTING_ARRAY_INDEX: '4' }, 0, 0 ]
          _5: [ { id: 7, sku: 'v7', attributes: [ { name: 'foo', value: 'bar' } ], _MATCH_CRITERIA: 'v7', _EXISTING_ARRAY_INDEX: '5' }, 0, 0 ]
      expect(delta).toEqual expected_delta

      update = @utils.actionsMapVariants delta, OLD_VARIANT, NEW_VARIANT
      expected_update = [
        { action: 'removeVariant', id: 2 }
        { action: 'removeVariant', id: 4 }
        { action: 'removeVariant', id: 5 }
        { action: 'removeVariant', id: 6 }
        { action: 'removeVariant', id: 7 }
        { action: 'addVariant', sku: 'SKUadded' }
        { action: 'addVariant', sku: 'SKUchanged!' }
        { action: 'addVariant', attributes: [ { name: 'foo', value: 'bar' } ] }
        { action: 'addVariant', attributes: [ { name: 'some', value: 'thing' } ] }
        { action: 'addVariant', attributes: [ { name: 'yet', value: 'another' } ] }
        { action: 'addVariant', sku: 'v10', attributes: [ { name: 'something', value: 'else' } ] }
        { action: 'addVariant', sku: 'SKUwins' }
      ]
      expect(update).toEqual expected_update

  describe ':: actionsMapAttributes', ->

    it 'should not create action for sku', ->
      delta = @utils.diff OLD_VARIANT, NEW_VARIANT
      update = @utils.actionsMapAttributes delta, OLD_VARIANT, NEW_VARIANT
      expected_update = [
        { action: 'setAttribute', variantId: 3, name: 'foo', value: 'CHANGED' }
      ]
      expect(update).toEqual expected_update

    it 'should build attribute actions', ->
      delta = @utils.diff(OLD_ATTRIBUTES, NEW_ATTRIBUTES)
      expected_delta =
        masterVariant:
          attributes:
            0: { value: ['20063672', '20063675'] }
            2: { value: [85, 10] }
            3: { value: ['YES', 'NO'] }
            _t: 'a'
        variants:
          0:
            attributes:
              0: { value: ['20063672', '20055572'] }
              1: { value: [160, 333] }
              2: { value: [85, 33] }
              _t: 'a'
            _NEW_ARRAY_INDEX: ['0']
            _EXISTING_ARRAY_INDEX: ['0', 0, 0]
          1:
            attributes:
              0: [ { name: 'uid', value: '00001' } ]
              1: [ { name: 'length', value: 500 } ]
              2: [ { name: 'bulkygoods', value: 'SI'} ]
              _t: 'a'
            _NEW_ARRAY_INDEX: ['1']
            _EXISTING_ARRAY_INDEX: ['1', 0, 0]
          2:
            attributes:
              _t: 'a'
              _0: [ { name: 'uid', value: '1234567' }, 0, 0 ]
              _1: [ { name: 'length', value: 123 }, 0, 0 ]
              _2: [ { name: 'bulkygoods', value: 'SI' }, 0, 0 ]
            _NEW_ARRAY_INDEX: ['2']
            _EXISTING_ARRAY_INDEX: ['2', 0, 0]
          _t: 'a'
      expect(delta).toEqual expected_delta

      update = @utils.actionsMapAttributes(delta, OLD_ATTRIBUTES, NEW_ATTRIBUTES)
      expected_update =
        [
          { action: 'setAttribute', variantId: 1, name: 'uid', value: '20063675' }
          { action: 'setAttribute', variantId: 1, name: 'wide', value: 10 }
          { action: 'setAttribute', variantId: 1, name: 'bulkygoods', value: 'NO' }
          { action: 'setAttribute', variantId: 2, name: 'uid', value: '20055572' }
          { action: 'setAttribute', variantId: 2, name: 'length', value: 333 }
          { action: 'setAttribute', variantId: 2, name: 'wide', value: 33 }
          { action: 'setAttribute', variantId: 3, name: 'uid', value: '00001' }
          { action: 'setAttribute', variantId: 3, name: 'length', value: 500 }
          { action: 'setAttribute', variantId: 3, name: 'bulkygoods', value: 'SI' }
          { action: 'setAttribute', variantId: 4, name: 'uid', value: undefined }
          { action: 'setAttribute', variantId: 4, name: 'length', value: undefined }
          { action: 'setAttribute', variantId: 4, name: 'bulkygoods', value: undefined }
        ]
      expect(update).toEqual expected_update

    it 'should build attribute actions for all types', ->
      delta = @utils.diff(OLD_ALL_ATTRIBUTES, NEW_ALL_ATTRIBUTES)
      update = @utils.actionsMapAttributes(delta, OLD_ALL_ATTRIBUTES, NEW_ALL_ATTRIBUTES)
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

    it 'should build attribute especially for (l)enum', ->
      delta = @utils.diff EXISTING_ENUM_ATTRIBUTES, NEW_ENUM_ATTRIBUTES
      update = @utils.actionsMapAttributes delta, EXISTING_ENUM_ATTRIBUTES, NEW_ENUM_ATTRIBUTES
      expected_update =
        [
          { action: 'setAttribute', variantId: 1, name: 'size', value: 'small' }
          { action: 'setAttribute', variantId: 1, name: 'color' }
          { action: 'setAttribute', variantId: 2, name: 'tags', value: [ 'tag2' ] }
        ]
      expect(update).toEqual expected_update

    it 'should build setAttributeInAllVariants actions', ->
      delta = @utils.diff OLD_SAME_FOR_ALL_ATTRIBUTES, NEW_SAME_FOR_ALL_ATTRIBUTES
      update = @utils.actionsMapAttributes delta, OLD_SAME_FOR_ALL_ATTRIBUTES, NEW_SAME_FOR_ALL_ATTRIBUTES, ['brand', 'tags']
      expected_update =
        [
          { action: 'setAttributeInAllVariants', name: 'brand', value: 'Cool Shirts' }
          { action: 'setAttributeInAllVariants', name: 'tags', value: [ 'tag2' ] }
        ]
      expect(update).toEqual expected_update

    it 'should build actions for set attributes', ->
      delta = @utils.diff OLD_SET_ATTRIBUTES, NEW_SET_ATTRIBUTES
      update = @utils.actionsMapAttributes delta, OLD_SET_ATTRIBUTES, NEW_SET_ATTRIBUTES
      expected_update =
        [
          { action: 'setAttribute', variantId: 1, name: 'colors', value: [ 'pink', 'orange' ] }
          { action: 'setAttribute', variantId: 3, name: 'colors' }
          { action: 'setAttribute', variantId: 4, name: 'colors', value: [ 'gray' ] }
        ]
      expect(update).toEqual expected_update

    it 'should build action for set attributes (ltext)', ->
      oldAttr =
        id: '123'
        masterVariant:
          id: 1
          attributes: [
            {
              name: 'details'
              value: [
                { de: 'Maße: 40 x 32 x 14 cm', en: 'Size: 40 x 32 x 14 cm', it: 'Taglia: 40 x 32 x 14 cm' },
                { de: ' Material: Leder ', en: ' Material: leather', it: ' Materiale: pelle' }
              ]
            }
          ]
        variants: [
          {
            id: 2
            attributes: [
              {
                name: 'details'
                value: [
                  { de: 'Maße: 40 x 32 x 14 cm', en: 'Size: 40 x 32 x 14 cm', it: 'Taglia: 40 x 32 x 14 cm' },
                  { de: ' Material: Leder ', en: ' Material: leather', it: ' Materiale: pelle' }
                ]
              }
            ]
          }
        ]

      newAttr =
        id: '123'
        masterVariant:
          id: 1
          attributes: [
            {
              name: 'details'
              value: [
                { de: 'Maße: 40 x 32 x 14 cm', en: 'Size: 40 x 32 x 14 cm', it: 'Taglia: 40 x 32 x 14 cm' },
                { de: 'Material: Leder', en: 'Material: leather', it: 'Materiale: pelle' }
                { de: 'Farbe: braun ', en: 'Color: brown', it: 'Colore: marrone' }
              ]
            }
          ]
        variants: [
          {
            id: 2
            attributes: []
          }
        ]

      # nothing to do
      delta1 = @utils.diff oldAttr, _.deepClone(oldAttr)
      noUpdate = @utils.actionsMapAttributes delta1, oldAttr, _.deepClone(oldAttr)
      expect(noUpdate).toEqual []

      # build actions
      delta2 = @utils.diff oldAttr, newAttr
      update = @utils.actionsMapAttributes delta2, oldAttr, newAttr
      expected_update =
        [
          {
            action: 'setAttribute'
            variantId: 1
            name: 'details'
            value: [
              { de: 'Maße: 40 x 32 x 14 cm', en: 'Size: 40 x 32 x 14 cm', it: 'Taglia: 40 x 32 x 14 cm' }
              { de: 'Material: Leder', en: 'Material: leather', it: 'Materiale: pelle' }
              { de: 'Farbe: braun ', en: 'Color: brown', it: 'Colore: marrone' }
            ]
          },
          { action: 'setAttribute', variantId: 2, name: 'details', value : undefined }
        ]
      expect(update).toEqual expected_update

  describe ':: actionsMapImages', ->

    it 'should build actions for images', ->
      delta = @utils.diff OLD_IMAGE_PRODUCT, NEW_IMAGE_PRODUCT
      update = @utils.actionsMapImages delta, OLD_IMAGE_PRODUCT, NEW_IMAGE_PRODUCT
      expected_update = [
        { action: 'removeImage', variantId: 3, imageUrl: '//example.com/image.png' }
        { action: 'removeImage', variantId: 3, imageUrl: '//example.com/image.png' }
        { action: 'removeImage', variantId: 3, imageUrl: '//example.com/image.png' }
        { action: 'removeImage', variantId: 4, imageUrl: '//example.com/old.png' }
        { action: 'addExternalImage', variantId: 3, image: { url: '//example.com/image.png', label: 'CHANGED', dimensions: { x: 1024, y: 768 } } }
        { action: 'addExternalImage', variantId: 3, image: { url: '//example.com/image.png', label: 'foo', dimensions: { x: 400, y: 300 } } }
        { action: 'addExternalImage', variantId: 3, image: { url: '//example.com/CHANGED.jpg', label: 'foo', dimensions: { x: 400, y: 300 } } }
        { action: 'addExternalImage', variantId: 5, image: { url: '//example.com/new.png', label: 'foo', dimensions: { x: 1024, y: 768 } } }
      ]
      expect(update).toEqual expected_update

    it 'should not build actions if images are not set', ->
      oldProduct =
        id: '123-abc'
        masterVariant:
          id: 1,
          images: []
        variants: []
      newProduct =
        id: '456-def'
        masterVariant:
          id: 1
        variants: []
      delta = @utils.diff oldProduct, newProduct
      update = @utils.actionsMapImages delta, oldProduct, newProduct
      expected_update = []
      expect(update).toEqual expected_update

  describe ':: actionsMapPrices', ->

    it 'should build prices actions', ->
      delta = @utils.diff OLD_PRODUCT, NEW_PRODUCT
      update = @utils.actionsMapPrices delta, OLD_PRODUCT, NEW_PRODUCT
      expected_update = [
        { action: 'changePrice', variantId: 1, price: { value: { currencyCode: 'EUR', centAmount: 2 } } }
        { action: 'removePrice', variantId: 1, price: { value: { currencyCode: 'EUR', centAmount: 7 } } }
        { action: 'removePrice', variantId: 3, price: { value: { currencyCode: 'EUR', centAmount: 2100 }, country: 'DE' } }
        { action: 'removePrice', variantId: 3, price: { value: { currencyCode: 'EUR', centAmount: 2200 }, customerGroup: { id: '123', typeId: 'customer-group' } } }
        { action: 'removePrice', variantId: 4, price: { value: { currencyCode: 'YEN', centAmount: 7777 } } }
        { action: 'addPrice', variantId: 1, price: { value: { currencyCode: 'USD', centAmount: 7 } } }
        { action: 'addPrice', variantId: 3, price: { value: { currencyCode: 'EUR', centAmount: 2100 }, country: 'CH' } }
        { action: 'addPrice', variantId: 3, price: { value: { currencyCode: 'EUR', centAmount: 2200 }, customerGroup: { id: '987', typeId: 'customer-group' } } }
        { action: 'addPrice', variantId: 5, price: { value: { currencyCode: 'EUR', centAmount: 999 } } }
      ]
      expect(update).toEqual expected_update

    it 'should build change price actions', ->
      oldPrice =
        masterVariant:
          id: 1
          prices: [
            {value: {currencyCode: 'EUR', centAmount: 2}}
            {value: {currencyCode: 'EUR', centAmount: 10}, country: 'DE'}
          ]
        variants: [
          {
            id: 2
            prices: [
              {value: {currencyCode: 'EUR', centAmount: 2}, customerGroup: {id: '987', typeId: 'customer-group'}}
              {value: {currencyCode: 'EUR', centAmount: 10}, country: 'DE'}
            ]
          }
        ]
      newPrice =
        masterVariant:
          id: 1
          prices: [
            {value: {currencyCode: 'EUR', centAmount: 5}}
            {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}
          ]
        variants: [
          {
            id: 2
            prices: [
              {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}
              {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}
            ]
          }
        ]

      delta = @utils.diff oldPrice, newPrice
      update = @utils.actionsMapPrices delta, oldPrice, newPrice

      expect(update.length).toBe 4
      expect(update[0]).toEqual {action: 'changePrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 5}}}
      expect(update[1]).toEqual {action: 'changePrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}
      expect(update[2]).toEqual {action: 'changePrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
      expect(update[3]).toEqual {action: 'changePrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}

    it 'should build price actions by ignoring discounts', ->
      oldPrice =
        masterVariant:
          id: 1
          prices: [
            {
              value:
                currencyCode: 'EUR'
                centAmount: 100
              discounted:
                value:
                  currencyCode: 'EUR'
                  centAmount: 80
                discount:
                  typeId: 'product-discount'
                  id: '123'
            }
          ]
        variants: [
          {
            id: 2
            prices: [
              {
                value:
                  currencyCode: 'EUR'
                  centAmount: 200
                customerGroup:
                  id: '987'
                  typeId: 'customer-group'
                discounted:
                  value:
                    currencyCode: 'EUR'
                    centAmount: 120
                  discount:
                    typeId: 'product-discount'
                    id: '123'
              }
            ]
          }
        ]
      newPrice =
        masterVariant:
          id: 1
          prices: [
            {value: {currencyCode: 'EUR', centAmount: 100}}
            {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}
          ]
        variants: [
          {
            id: 2
            prices: [
              {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}
            ]
          }
        ]

      delta = @utils.diff oldPrice, newPrice
      update = @utils.actionsMapPrices delta, oldPrice, newPrice

      expect(update.length).toBe 2
      expect(update[0]).toEqual {action: 'changePrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
      expect(update[1]).toEqual {action: 'addPrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}

  describe ':: actionsMapReferences (tax-category)', ->

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
      update = @utils.actionsMapReferences delta, @OLD_REFERENCE, @NEW_REFERENCE
      expected_update = [
        { action: 'setTaxCategory', taxCategory: { typeId: 'tax-category', id: 'tax-us' } }
      ]
      expect(update).toEqual expected_update

    it 'should build action to delete tax-category', ->
      delete @NEW_REFERENCE.taxCategory
      delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
      update = @utils.actionsMapReferences delta, @OLD_REFERENCE, @NEW_REFERENCE
      expected_update = [
        { action: 'setTaxCategory' }
      ]
      expect(update).toEqual expected_update

    it 'should build action to add tax-category', ->
      delete @OLD_REFERENCE.taxCategory
      delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
      update = @utils.actionsMapReferences delta, @OLD_REFERENCE, @NEW_REFERENCE
      expected_update = [
        { action: 'setTaxCategory', taxCategory: { typeId: 'tax-category', id: 'tax-us' } }
      ]
      expect(update).toEqual expected_update

  describe ':: actionsMapReferences (category)', ->

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
      update = @utils.actionsMapReferences delta, @OLD_REFERENCE, @NEW_REFERENCE
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
      update = @utils.actionsMapReferences delta, before, after
      expect(update).toEqual []
