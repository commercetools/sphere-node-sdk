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
        { url: '//example.com/image1.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
        { url: '//example.com/image2.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
        { url: '//example.com/image3.png', label: 'foo', dimensions: { x: 1024, y: 768 } }
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
        { url: '//example.com/image1.png', label: 'CHANGED', dimensions: { x: 1024, y: 768 } }
        { url: '//example.com/image2.png', label: 'foo', dimensions: { x: 400, y: 300 } }
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

    it 'should create actions for changed variant keys', ->
      OLD =
        id: '123'
        masterVariant:
          id: 1
          sku: 'masterSku'
          key: 'oldKey'
        variants: [
          {
            id: 2
            sku: 'variantSku'
            key: 'oldVariantKey'
          },
          {
            id: 3
            sku: 'variantSku2'
            key: 'oldVariantKey2'
          },
          {
            id: 4
            sku: 'variantSku3'
          }
        ]

      NEW =
        id: '123'
        masterVariant:
          sku: 'masterSku'
          key: 'newKey'
        variants: [
          {
            sku: 'variantSku'
            key: 'newVariantKey'
          },
          {
            sku: 'variantSku2'
          },
          {
            sku: 'variantSku3'
            key: 'newVariantKey3'
          }
        ]

      delta = @utils.diff OLD, NEW
      update = @utils.actionsMapAttributes delta, OLD, NEW

      expected_update = [
        { action: 'setProductVariantKey', variantId: 1, key: 'newKey' }
        { action: 'setProductVariantKey', variantId: 2, key: 'newVariantKey' }
        { action: 'setProductVariantKey', variantId: 3, key: undefined }
        { action: 'setProductVariantKey', variantId: 4, key: 'newVariantKey3' }
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
            attributes: []
          },
          {
            id: 3
            attributes: [
              {
                name: 'details'
                value: [
                  { de: 'Farbe: braun ', en: 'Color: brown', it: 'Colore: marrone' }
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
            attributes: [
              {
                name: 'details'
                value: [
                  { de: 'Maße: 40 x 32 x 14 cm', en: 'Size: 40 x 32 x 14 cm', it: 'Taglia: 40 x 32 x 14 cm' },
                  { de: 'Material: Leder', en: 'Material: leather', it: 'Materiale: pelle' }
                ]
              }
            ]
          },
          {
            id: 3
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
          {
            action: 'setAttribute'
            variantId: 2
            name: 'details'
            value: [
              { de: 'Maße: 40 x 32 x 14 cm', en: 'Size: 40 x 32 x 14 cm', it: 'Taglia: 40 x 32 x 14 cm' }
              { de: 'Material: Leder', en: 'Material: leather', it: 'Materiale: pelle' }
            ]
          },
          { action: 'setAttribute', variantId: 3, name: 'details', value: undefined }
        ]
      expect(update).toEqual expected_update

    it 'should build actions for attributes with long text as values', ->
      newProduct =
        masterVariant:
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
        variants: []
      originalProduct =
        masterVariant:
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
        variants: []

      delta = @utils.diff originalProduct, newProduct
      update = @utils.actionsMapAttributes delta, originalProduct, newProduct
      expected_update =
        [
          { action: 'setAttribute', variantId: 1, name: 'images', value: '//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-1.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-2.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-4.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-5.jpg' },
          { action: 'setAttribute', variantId: 1, name: 'textAttribute', value: '[{"textAttributeValue":{"fr-CH":"","de-CH":"","it-CH":"","de-DE":"<p><strong>Some random text to make this longer than the value that was in jsondiffpatch.textDiff.minLength = 300. This should be now a correctly formatted JSON. However, after jsondiffpatch, it will be changed into a different string”</p>","en-GB":"","es-ES":"","fr-FR":""}}]' },
          { action: 'setAttribute', variantId: 1, name: 'localized_images', value: { en: '//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-1.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-2.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-4.jpg;//dceroyf7rfc0x.cloudfront.net/product/images/390x520/a/arj/po/HARJPUL101601-5.jpg' } }
        ]
      expect(update).toEqual expected_update

    it 'should not modify original attributes', ->
      newProduct =
        masterVariant:
          id: 1
          sku: 'test_sku_1'
          attributes: [
            {
              name: 'testAttribute1',
              value: false
            }
          ]
        variants: [
          id: 2
          sku: 'test_sku_2'
          attributes: [
            {
              name: 'testAttribute1',
              value: false
            }
          ]
        ]

      originalProduct =
        masterVariant:
          id: 1
          sku: 'test_sku_1'
          attributes: [
            {
              name: 'testAttribute2',
              value: 'testValue'
            }
          ]

      cloneOfOriginalProduct = _.deepClone(originalProduct)

      delta = @utils.diff originalProduct, newProduct
      update = @utils.actionsMapAttributes delta, originalProduct, newProduct

      expected_update =
        [
          { action: 'setAttribute', variantId: 1, name: 'testAttribute1', value: false },
          { action: 'setAttribute', variantId: 1, name: 'testAttribute2' }
        ]
      expect(cloneOfOriginalProduct.masterVariant.attributes).toEqual originalProduct.masterVariant.attributes
      expect(update).toEqual expected_update

    it 'should not create update action if attribute is not changed', ->
      newProduct =
        masterVariant:
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

      originalProduct =
        masterVariant:
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

      delta = @utils.diff originalProduct, newProduct
      update = @utils.actionsMapAttributes delta, originalProduct, newProduct
      expect(update.length).toBe(0)

    it 'should create update action if attribute value item is removed', ->
      newProduct =
        masterVariant:
          sku: 'TEST MASTER VARIANT'
          attributes: [
            {
              'name': 'test_attribute',
              'value': [
                'a', 'b'
              ]
            }
          ]

      originalProduct =
        masterVariant:
          sku: 'TEST MASTER VARIANT'
          attributes: [
            {
              name: 'test_attribute',
              value: [
                'a', 'b', 'c'
              ]
            }
          ]

      delta = @utils.diff originalProduct, newProduct
      update = @utils.actionsMapAttributes delta, originalProduct, newProduct
      expect(update.length).toBe(1)
      expect(update[0].action).toBe 'setAttribute'
      expect(update[0].name).toBe 'test_attribute'
      expect(update[0].value).toEqual [ 'a', 'b' ]

    it 'should create update action if attribute value item is added', ->
      newProduct =
        masterVariant:
          sku: 'TEST MASTER VARIANT'
          attributes: [
            {
              'name': 'test_attribute',
              'value': [
                'a', 'b', 'c'
              ]
            }
          ]

      originalProduct =
        masterVariant:
          sku: 'TEST MASTER VARIANT'
          attributes: [
            {
              name: 'test_attribute',
              value: [
                'a', 'b'
              ]
            }
          ]

      delta = @utils.diff originalProduct, newProduct
      update = @utils.actionsMapAttributes delta, originalProduct, newProduct
      expect(update.length).toBe(1)
      expect(update[0].action).toBe 'setAttribute'
      expect(update[0].name).toBe 'test_attribute'
      expect(update[0].value).toEqual [ 'a', 'b', 'c' ]

  describe ':: actionsMapImages', ->

    it 'should build actions for images', ->
      delta = @utils.diff OLD_IMAGE_PRODUCT, NEW_IMAGE_PRODUCT
      update = @utils.actionsMapImages delta, OLD_IMAGE_PRODUCT, NEW_IMAGE_PRODUCT
      not_expected = [
        # the first image of variant with id 3 changed the label
        # which would normally result in a remove + add action
        # which in return would result in the image being deleted from the CDN
        # thus we expect for the actions to NOT contain a remove action for
        # the first image of variant with id 3
        { action: 'removeImage', variantId: 3, imageUrl: '//example.com/image1.png' }
        { action: 'addExternalImage', variantId: 3, image: { url: '//example.com/image1.png', label: 'CHANGED', dimensions: { x: 1024, y: 768 } } }
        # the second image of the variant with the id 3 changed the dimensions
        # here we also want no changes to happen in order to prevent the
        # image from being deleted form the CDN
        { action: 'removeImage', variantId: 3, imageUrl: '//example.com/image2.png' }
        { action: 'addExternalImage', variantId: 3, image: { url: '//example.com/image2.png', label: 'foo', dimensions: { x: 400, y: 300 } } }
      ]
      expected_update = [
        # expect a change label action for the first image of variant 3
        { action: 'changeImageLabel', variantId: 3, imageUrl: '//example.com/image1.png', label: 'CHANGED' }
        # for the third image of the variant with the id 3 the image url changed
        # which should result in a remove+add action
        { action: 'removeImage', variantId: 3, imageUrl: '//example.com/image3.png' }
        # for the image of variant 4 the same applies
        # as for the third image of variant 3
        { action: 'removeImage', variantId: 4, imageUrl: '//example.com/old.png' }
        { action: 'addExternalImage', variantId: 3, image: { url: '//example.com/CHANGED.jpg', label: 'foo', dimensions: { x: 400, y: 300 } } }
        { action: 'addExternalImage', variantId: 5, image: { url: '//example.com/new.png', label: 'foo', dimensions: { x: 1024, y: 768 } } }
      ]
      _.each(not_expected, (notExpectedAction) ->
        expect(update).toNotContain notExpectedAction
      )
      _.each(expected_update, (expectedAction) ->
        expect(update).toContain expectedAction
      )

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
        { action: 'changePrice', priceId: 'p-1', price: { value: { currencyCode: 'EUR', centAmount: 2 } } }
        { action: 'removePrice', priceId: 'p-2' }
        { action: 'removePrice', priceId: 'p-4' }
        { action: 'removePrice', priceId: 'p-5' }
        { action: 'removePrice', priceId: 'p-6' }
        { action: 'addPrice', variantId: 1, price: { value: { currencyCode: 'USD', centAmount: 7 } } }
        { action: 'addPrice', variantId: 3, price: { value: { currencyCode: 'EUR', centAmount: 2100 }, country: 'CH' } }
        { action: 'addPrice', variantId: 3, price: { value: { currencyCode: 'EUR', centAmount: 2200 }, customerGroup: { id: '987', typeId: 'customer-group' } } }
        { action: 'addPrice', variantId: 5, price: { value: { currencyCode: 'EUR', centAmount: 999 } } }
      ]
      expect(update).toEqual expected_update

    it 'should build prices actions (even with missing new variant id)', ->
      oldProd =
        masterVariant: { id: 1 }
        variants: [
          {
            id: 2
            sku: 'foo'
            prices: []
          }
        ]
      newProd =
        masterVariant: { id: 1 }
        variants: [
          {
            sku: 'foo'
            prices: [
              {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}
              {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}
            ]
          }
        ]

      delta = @utils.diff oldProd, newProd
      update = @utils.actionsMapPrices delta, oldProd, newProd

      expect(update.length).toBe 2
      expect(update[0]).toEqual {action: 'addPrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
      expect(update[1]).toEqual {action: 'addPrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}

    it 'should build change price actions', ->
      oldPrice =
        masterVariant:
          id: 1
          prices: [
            {id: 'p-1', value: {currencyCode: 'EUR', centAmount: 2}}
            {id: 'p-2', value: {currencyCode: 'EUR', centAmount: 10}, country: 'DE'}
          ]
        variants: [
          {
            id: 2
            prices: [
              {id: 'p-3', value: {currencyCode: 'EUR', centAmount: 2}, customerGroup: {id: '987', typeId: 'customer-group'}}
              {id: 'p-4', value: {currencyCode: 'EUR', centAmount: 10}, country: 'DE'}
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
      expect(update[0]).toEqual {action: 'changePrice', priceId: 'p-1', price: {value: {currencyCode: 'EUR', centAmount: 5}}}
      expect(update[1]).toEqual {action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}
      expect(update[2]).toEqual {action: 'changePrice', priceId: 'p-3', price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
      expect(update[3]).toEqual {action: 'changePrice', priceId: 'p-4', price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}

    it 'should build change price actions with priceId', ->
      oldPrice =
        masterVariant:
          id: 1
          prices: [
            {id: 'p-1', value: {currencyCode: 'EUR', centAmount: 2}}
            {id: 'p-2', value: {currencyCode: 'EUR', centAmount: 10}, country: 'DE'}
          ]
        variants: [
          {
            id: 2
            prices: [
              {id: 'p-3', value: {currencyCode: 'EUR', centAmount: 2}, customerGroup: {id: '987', typeId: 'customer-group'}}
              {id: 'p-4', value: {currencyCode: 'EUR', centAmount: 10}, country: 'DE'}
            ]
          }
        ]
      newPrice =
        masterVariant:
          id: 1
          prices: [
            {id: 'p-1', value: {currencyCode: 'EUR', centAmount: 50}}
            {id: 'p-2', value: {currencyCode: 'EUR', centAmount: 1000}, country: 'FR'}
          ]
        variants: [
          {
            id: 2
            prices: [
              {id: 'p-3', value: {currencyCode: 'EUR', centAmount: 567}, customerGroup: {id: '123', typeId: 'new-customer-group'}}
              {id: 'p-4', value: {currencyCode: 'EUR', centAmount: 243}, country: 'DE'}
            ]
          }
        ]

      delta = @utils.diff oldPrice, newPrice
      update = @utils.actionsMapPrices delta, oldPrice, newPrice

      expect(update.length).toBe 4
      expect(update[0]).toEqual {action: 'changePrice', priceId: 'p-1', price: {value: {currencyCode: 'EUR', centAmount: 50}}}
      expect(update[1]).toEqual {action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 1000}, country: 'FR'}}
      expect(update[2]).toEqual {action: 'changePrice', priceId: 'p-3', price: {value: {currencyCode: 'EUR', centAmount: 567}, customerGroup: {id: '123', typeId: 'new-customer-group'}}}
      expect(update[3]).toEqual {action: 'changePrice', priceId: 'p-4', price: {value: {currencyCode: 'EUR', centAmount: 243}, country: 'DE'}}

    it 'should build price actions by ignoring discounts', ->
      oldPrice =
        masterVariant:
          id: 1
          prices: [
            {
              id: 'p-1'
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
                id: 'p-2'
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
      expect(update[0]).toEqual {action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
      expect(update[1]).toEqual {action: 'addPrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}

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
          delta, oldRef, @NEW_REFERENCE
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
          delta, @OLD_REFERENCE, newRef
        )
        expected = []
        expect(actual).toEqual(expected)

        # test without state
        delete newRef.state
        delta = @utils.diff @OLD_REFERENCE, newRef
        actual = @utils.actionsMapReferences(
          delta, @OLD_REFERENCE, newRef
        )
        expected = []
        expect(actual).toEqual(expected)

      it 'should build a transitionState action for a state change', ->
        delta = @utils.diff @OLD_REFERENCE, @NEW_REFERENCE
        actual = @utils.actionsMapReferences(
          delta, @OLD_REFERENCE, @NEW_REFERENCE
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
