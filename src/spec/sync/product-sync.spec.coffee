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
  categoryOrderHints:
    categoryId2: 0.3
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
  categories: [
    'myFancyCategoryId'
  ],
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
    { sku: 'new', key: 'foobar2', attributes: [ { name: 'what', value: 'no ID' } ] }
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

describe 'ProductSync', ->

  beforeEach ->
    @sync = new ProductSync

  describe 'Removing/Adding/Moving variants', ->

    it 'should change the masterVariant to a freshly added variant', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
          sku: 'sku1'
        variants: [
          { id: 2, sku: 'sku2' }
        ]

      newProduct =
        id: '123'
        version: 1
        masterVariant:
          sku: 'sku3'
        variants: [
          { sku: 'sku2' }
        ]

      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()
      expected_update =
        actions: [
          {
            sku: 'sku3',
            action: 'addVariant'
          }, {
            action: 'changeMasterVariant',
            sku: 'sku3'
          }, {
            action: 'removeVariant',
            sku: 'sku1'
          }
        ]
        version: oldProduct.version
      expect(update).toEqual expected_update

    it 'should change the masterVariant', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
          sku: 'sku1'
        variants: [
          { id: 2, sku: 'sku2' }
        ]

      newProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 2
          sku: 'sku2'
        variants: [
          { id: 1, sku: 'sku1' }
        ]

      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'changeMasterVariant', sku: 'sku2' }
        ]
        version: oldProduct.version
      expect(update).toEqual expected_update

    it 'should not do any action when variant order changed when id is provided', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
        variants: [
          { id: 2 }
          { id: 3 }
        ]

      newProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
        variants: [
          { id: 3 }
          { id: 2 }
        ]

      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()
      expect(update).toEqual undefined

    it 'should not do any action when variant order changed when sku is provided', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
          sku: 'sku1'
        variants: [
          { id: 2, sku: 'sku2' }
          { id: 3, sku: 'sku3' }
        ]

      newProduct =
        id: '123'
        version: 1
        masterVariant:
          sku: 'sku1'
        variants: [
          { sku: 'sku3' }
          { sku: 'sku2' }
        ]

      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()
      # no action
      expect(update).toEqual undefined

    it 'should throw an error when no id or sku is provided', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
          key: 'sku1'
        variants: [
          { id: 2, key: 'sku2' }
          { id: 3, key: 'sku3' }
        ]

      newProduct =
        id: '123'
        version: 1
        masterVariant:
          key: 'sku1'
        variants: [
          { key: 'sku3' }
          { key: 'sku2' }
        ]

      expect(=> @sync.buildActions(newProduct, oldProduct)).toThrow new Error 'A variant must either have an ID or an SKU.'

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
          { action: 'setDescription', description: undefined }
          { action: 'setSearchKeywords', searchKeywords: en: [{text: 'new'}, {text: 'search'}, {text: 'keywords'}], "fr-BE": [{text: 'bruxelles'}, {text:'liege'}, {text: 'brugge'}] }
        ]
        version: OLD_PRODUCT.version
      expect(update).toEqual expected_update


  describe ':: _doMapVariantActions', ->

    describe 'price actions', ->

      it 'should build price actions by ignoring discounts', ->
        oldProduct =
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
        newProduct =
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

        update = @sync._doMapVariantActions newProduct, oldProduct

        expect(update.variantUpdateActions).toEqual [
          {action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
          {action: 'addPrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}
        ]

      it 'should build prices actions', ->
        oldProduct =
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

        newProduct =
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

        update = @sync._doMapVariantActions newProduct, oldProduct
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
        expect(update.variantUpdateActions).toEqual expected_update

      it 'should build prices actions (even with missing new variant id)', ->
        oldProduct =
          masterVariant: { id: 1 }
          variants: [
            {
              id: 2
              sku: 'foo'
              prices: []
            }
          ]
        newProduct =
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

        update = @sync._doMapVariantActions newProduct, oldProduct
        expect(update.variantUpdateActions).toEqual [
          {action: 'addPrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
          {action: 'addPrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}
        ]

      it 'should build change price actions', ->
        oldProduct =
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
        newProduct =
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

        update = @sync._doMapVariantActions newProduct, oldProduct
        expect(update.variantUpdateActions).toEqual [
          {action: 'changePrice', priceId: 'p-1', price: {value: {currencyCode: 'EUR', centAmount: 5}}}
          {action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}
          {action: 'changePrice', priceId: 'p-3', price: {value: {currencyCode: 'EUR', centAmount: 5}, customerGroup: {id: '987', typeId: 'customer-group'}}}
          {action: 'changePrice', priceId: 'p-4', price: {value: {currencyCode: 'EUR', centAmount: 20}, country: 'DE'}}
        ]

      it 'should build change price actions with priceId', ->
        oldProduct =
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
        newProduct =
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

        update = @sync._doMapVariantActions newProduct, oldProduct
        expect(update.variantUpdateActions).toEqual [
          {action: 'changePrice', priceId: 'p-1', price: {value: {currencyCode: 'EUR', centAmount: 50}}}
          {action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 1000}, country: 'FR'}}
          {action: 'changePrice', priceId: 'p-3', price: {value: {currencyCode: 'EUR', centAmount: 567}, customerGroup: {id: '123', typeId: 'new-customer-group'}}}
          {action: 'changePrice', priceId: 'p-4', price: {value: {currencyCode: 'EUR', centAmount: 243}, country: 'DE'}}
        ]

    describe 'image actions', ->

      it 'should build actions for images', ->
        oldImageProduct =
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

        newImageProduct =
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

        update = @sync._doMapVariantActions newImageProduct, oldImageProduct

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
          expect(update.variantUpdateActions).toNotContain notExpectedAction
        )
        _.each(expected_update, (expectedAction) ->
          expect(update.variantUpdateActions).toContain expectedAction
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

        update = @sync._doMapVariantActions newProduct, oldProduct
        expected_update = []
        expect(update.variantUpdateActions).toEqual expected_update

    describe 'attribute actions', ->

      it 'should build actions for set attributes', ->
        oldProduct =
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

        newProduct =
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

        actions = @sync.buildActions(newProduct, oldProduct).getUpdateActions()
        expected_update =
          [
            { action: 'setAttribute', variantId: 1, name: 'colors', value: [ 'pink', 'orange' ] }
            { action: 'setAttribute', variantId: 3, name: 'colors' }
            { action: 'setAttribute', variantId: 4, name: 'colors', value: [ 'gray' ] }
          ]
        expect(actions).toEqual expected_update

      it 'should build update actions', ->
        oldProduct =
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

        newProduct =
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

        actions = @sync.buildActions(newProduct, oldProduct).getUpdateActions()

        expect(actions).toEqual [
          { action: 'removeVariant', sku: 'v4' }
          { action: 'removeVariant', id: 5 }
          { action: 'setSku', variantId: 2, sku: 'SKUadded' }
          { action: 'setAttribute', variantId: 3, name: 'foo', value: 'CHANGED' }
          { action: 'setSku', variantId: 6, sku: 'SKUchanged!' }
          { action: 'setSku', variantId: 7, sku: undefined }
          { id: 8, attributes: [ { name: 'some', value: 'thing' } ], action: 'addVariant' }
          { id: 9, attributes: [ { name: 'yet', value: 'another' } ], action: 'addVariant' }
          { sku: 'v10', attributes: [ { name: 'something', value: 'else' } ], action: 'addVariant' }
          { id: 100, sku: 'SKUwins', action: 'addVariant' }
        ]

        # TODO check result, before it was:
  #      expected_update = [
  #        { action: 'removeVariant', id: 2 }
  #        { action: 'removeVariant', id: 4 }
  #        { action: 'removeVariant', id: 5 }
  #        { action: 'removeVariant', id: 6 }
  #        { action: 'removeVariant', id: 7 }
  #        { action: 'addVariant', sku: 'SKUadded' }
  #        { action: 'addVariant', sku: 'SKUchanged!' }
  #        { action: 'addVariant', attributes: [ { name: 'foo', value: 'bar' } ] }
  #        { action: 'addVariant', attributes: [ { name: 'some', value: 'thing' } ] }
  #        { action: 'addVariant', attributes: [ { name: 'yet', value: 'another' } ] }
  #        { action: 'addVariant', sku: 'v10', attributes: [ { name: 'something', value: 'else' } ] }
  #        { action: 'addVariant', sku: 'SKUwins' }
  #      ]

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

        variantActionTypes = @sync._doMapVariantActions(NEW, OLD)

        expected_update = [
          { action: 'setProductVariantKey', variantId: 1, key: 'newKey' }
          { action: 'setProductVariantKey', variantId: 2, key: 'newVariantKey' }
          { action: 'setProductVariantKey', variantId: 3, key: undefined }
          { action: 'setProductVariantKey', variantId: 4, key: 'newVariantKey3' }
        ]
        expect(variantActionTypes.variantUpdateActions).toEqual expected_update

      it 'should build setAttributeInAllVariants actions', ->
        oldProduct =
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

        newProduct =
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

        @sync.sameForAllAttributeNames = ['brand', 'tags']
        update = @sync._doMapVariantActions newProduct, oldProduct
        expected_update =
          [
            { action: 'setAttributeInAllVariants', name: 'brand', value: 'Cool Shirts' }
            { action: 'setAttributeInAllVariants', name: 'tags', value: [ 'tag2' ] }
          ]
        expect(update.variantUpdateActions).toEqual expected_update

      it 'should build attribute actions for all types', ->
        update = @sync._doMapVariantActions(NEW_ALL_ATTRIBUTES, OLD_ALL_ATTRIBUTES)
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
        expect(update.variantUpdateActions).toEqual expected_update

      it 'should build attribute especially for (l)enum', ->
        oldProduct =
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

        newProduct =
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

        update = @sync._doMapVariantActions newProduct, oldProduct
        expected_update =
          [
            { action: 'setAttribute', variantId: 1, name: 'size', value: 'small' }
            { action: 'setAttribute', variantId: 1, name: 'color' }
            { action: 'setAttribute', variantId: 2, name: 'tags', value: [ 'tag2' ] }
          ]
        expect(update.variantUpdateActions).toEqual expected_update

      it 'should build action for set attributes (ltext)', ->
        oldProduct =
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

        newProduct =
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


        actionTypes = @sync._doMapVariantActions(_.deepClone(oldProduct), oldProduct)
        expect(actionTypes.variantUpdateActions).toEqual []

        # build actions
        actionTypes = @sync._doMapVariantActions(newProduct, oldProduct)

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
        expect(actionTypes.variantUpdateActions).toEqual expected_update

      it 'should unset original attribute ', ->
        oldProduct =
          masterVariant:
            id: 1
            sku: 'test_sku_1'
            attributes: [
              {
                name: 'testAttribute2',
                value: 'testValue'
              }
            ]
        oldProductClone = _.deepClone(oldProduct)

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

        update = @sync._doMapVariantActions newProduct, oldProduct
        expected_update =
          [
            { action: 'setAttribute', variantId: 1, name: 'testAttribute1', value: false },
            { action: 'setAttribute', variantId: 1, name: 'testAttribute2' }
          ]
        # should not modify original old project
        expect(oldProductClone.masterVariant.attributes).toEqual oldProduct.masterVariant.attributes
        # should generate expected update actions
        expect(update.variantUpdateActions).toEqual expected_update
        expect(update.addVariantActions).toEqual [
          { id: 2, sku: 'test_sku_2', attributes: [{ name: 'testAttribute1', value: false }], action: 'addVariant' }
        ]

      it 'should build actions for set attributes', ->
        oldProduct =
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

        newProduct =
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

        update = @sync._doMapVariantActions newProduct, oldProduct
        expected_update =
          [
            { action: 'setAttribute', variantId: 1, name: 'colors', value: [ 'pink', 'orange' ] }
            { action: 'setAttribute', variantId: 3, name: 'colors' }
            { action: 'setAttribute', variantId: 4, name: 'colors', value: [ 'gray' ] }
          ]
        expect(update.variantUpdateActions).toEqual expected_update

      it 'should build attribute actions', ->
        ###
        Match different attributes on variant level
        ###
        oldProduct =
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
        newProduct =
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

        actionTypes = @sync._doMapVariantActions(newProduct, oldProduct)
        expected_actions =
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
        expect(actionTypes.variantUpdateActions).toEqual expected_actions

  describe ':: buildActions', ->

    it 'should build the action update', ->
      update = @sync.buildActions(NEW_PRODUCT, OLD_PRODUCT).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'changeName', name: {en: 'Foo', de: undefined, it: 'Boo'} }
          { action: 'changeSlug', slug: {en: 'foo', it: 'boo'} }
          { action: 'setDescription', description: undefined }
          { action: 'setSearchKeywords', searchKeywords: en: [{text: 'new'}, {text: 'search'}, {text: 'keywords'}], "fr-BE": [{text: 'bruxelles'}, {text:'liege'}, {text: 'brugge'}]}
          { action: 'transitionState', state: { typeId: 'state', id: 'new-state-id' } }
          { action: 'addToCategory', category: 'myFancyCategoryId' }
          { action: 'setCategoryOrderHint', categoryId: 'categoryId2', orderHint: undefined }
          { action: 'setCategoryOrderHint', categoryId : 'myFancyCategoryId', orderHint : '0.9' }
          { action: 'removeVariant', id: 4 }
          { action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 3800}} }
          { action: 'removePrice', priceId: 'p-3'}
          { action: 'removePrice', priceId: 'p-4'}
          { action: 'removePrice', priceId: 'p-8'}
          { action: 'removePrice', priceId: 'p-9'}
          { action: 'removePrice', priceId: 'p-11'}
          { action: 'removePrice', priceId: 'p-12'}
          { action: 'removePrice', priceId: 'p-13'}
          { action: 'addPrice', variantId: 1, price: {value: {currencyCode: 'EUR', centAmount: 1100}, country: 'IT'} }
          { action: 'addPrice', variantId: 1, price: {value: {currencyCode: 'JPY', centAmount: 9001}, custom: {type: {typeId: 'type', id: 'decaf-f005ba11-abaca', fields: {superCustom: 'super true'}}}} }
          { action: 'addPrice', variantId: 2, price: {value: {currencyCode: 'EUR', centAmount: 2200}, customerGroup: {id: '59c64f80-6472-474e-b5be-dc57b45b2faf', typeId: 'customer-group'}} }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 4790 }, country: 'DE', customerGroup: { id: 'special-price-id', typeId: 'customer-group' } } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 5889 }, country: 'AT' } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 4790 }, country: 'AT', customerGroup: { id: 'special-price-id', typeId: 'customer-group' } } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 6559 }, country: 'FR' } }
          { action: 'addPrice', variantId: 77, price: { value: { currencyCode: 'EUR', centAmount: 13118 }, country: 'BE' } }
          { action: 'addVariant', sku: 'new', key: 'foobar2', attributes: [ { name: 'what', value: 'no ID' } ] }
          { action: 'addVariant', id: 7, attributes: [ { name: 'what', value: 'no SKU' } ] }
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
          { id: 4, sku: 'v4', attributes: [{name: 'foo', value: 'i dont care'}] }
          { id: 3, sku: 'v3', attributes: [{name: 'foo', value: 'yet another'}] }
        ]
      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()
      expected_update =
        actions: [
          { action: 'setAttribute', variantId: 1, name: 'foo', value: 'new value' }
          { action: 'setAttribute', variantId: 2, name: 'foo', value: 'another value' }
          { action: 'setAttribute', variantId: 3, name: 'foo', value: 'yet another' }
          { action: 'addVariant', id: 4, sku: 'v4', attributes: [{ name: 'foo', value: 'i dont care' }] }
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
          { action: 'addVariant', id: 2, sku: 'v2', attributes: [{ name: 'foo', value: 'new variant' }] }
        ]
        version: oldProduct.version
      expect(update).toEqual expected_update

    it 'should create `changePrice` action if new price has id', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
          sku: 'v1'
          prices: [
            {id: 'p-1', value: {currencyCode: 'EUR', centAmount: 100}},
            {id: 'p-2', value: {currencyCode: 'EUR', centAmount: 1000}},
          ]
        variants: [
          {
            id: 2
            prices: [
              {id: 'p-7', value: {currencyCode: 'EUR', centAmount: 2000}},
              {id: 'p-8', value: {currencyCode: 'EUR', centAmount: 2100}, country: 'FR'},
            ]
          }
          {
            id: 3
            prices: [
              {id: 'p-10', value: {currencyCode: 'EUR', centAmount: 5889}, country: 'DE'},
            ]
          }
        ]

      newProduct =
        id: '123'
        masterVariant:
          sku: 'v1'
          prices: [
            {id: 'p-1', value: {currencyCode: 'GBP', centAmount: 555}},
            {id: 'p-2', value: {currencyCode: 'GBP', centAmount: 245}},
          ]
        variants: [
          {
            id: 2
            prices: [
              {id: 'p-7', value: {currencyCode: 'USD', centAmount: 4444}},
              {id: 'p-8', value: {currencyCode: 'USD', centAmount: 5555}, country: 'US'},
            ]
          }
          {
            id: 3
            prices: [
              {id: 'p-10', value: {currencyCode: 'USD', centAmount: 1257}, country: 'US'},
            ]
          }
        ]
      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()

      expected_update =
        actions: [
          { action: 'changePrice', priceId: 'p-1', price: {value: {currencyCode: 'GBP', centAmount: 555} }}
          { action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'GBP', centAmount: 245} }}
          { action: 'changePrice', priceId: 'p-7', price: {value: {currencyCode: 'USD', centAmount: 4444} }}
          { action: 'changePrice', priceId: 'p-8', price: {value: {currencyCode: 'USD', centAmount: 5555}, country: 'US' }}
          { action: 'changePrice', priceId: 'p-10', price: {value: {currencyCode: 'USD', centAmount: 1257}, country: 'US' }}
        ]
        version: oldProduct.version
      expect(update).toEqual expected_update

    it 'should create `changePrice` action based on price selection', ->
      oldProduct =
        id: '123'
        version: 1
        masterVariant:
          id: 1
          sku: 'v1'
          prices: [
            {id: 'p-1', value: {currencyCode: 'EUR', centAmount: 100}, validUntil: '2019-10-16'},
            {id: 'p-2', value: {currencyCode: 'EUR', centAmount: 1000}, country: 'DE'},
            {id: 'p-3', value: {currencyCode: 'GBP', centAmount: 1000}},
          ]
        variants: [
          {
            id: 2
            prices: [
              {id: 'p-8', value: {currencyCode: 'USD', centAmount: 2100}, country: 'US', customerGroup: {id: 'special-price-id', typeId: 'customer-group'}},
            ]
          }
        ]

      newProduct =
        id: '123'
        masterVariant:
          sku: 'v1'
          prices: [
            {value: {currencyCode: 'EUR', centAmount: 555}, validUntil: '2020-12-14'},
            {value: {currencyCode: 'EUR', centAmount: 245}, country: 'DE'},
            {value: {currencyCode: 'GBP', centAmount: 2300}}
          ]
        variants: [
          {
            id: 2
            prices: [
              {value: {currencyCode: 'USD', centAmount: 5555}, country: 'US', customerGroup: {id: 'special-price-id', typeId: 'customer-group'}},
            ]
          }
        ]
      update = @sync.buildActions(newProduct, oldProduct).getUpdatePayload()

      expected_update =
        actions: [
          { action: 'changePrice', priceId: 'p-1', price: {value: {currencyCode: 'EUR', centAmount: 555}, validUntil: '2020-12-14' }}
          { action: 'changePrice', priceId: 'p-2', price: {value: {currencyCode: 'EUR', centAmount: 245}, country: 'DE' }}
          { action: 'changePrice', priceId: 'p-3', price: {value: {currencyCode: 'GBP', centAmount: 2300}}}
          { action: 'changePrice', priceId: 'p-8', price: {value: {currencyCode: 'USD', centAmount: 5555}, country: 'US', customerGroup: {id: 'special-price-id', typeId: 'customer-group'} }}
        ]
        version: oldProduct.version
      expect(update).toEqual expected_update

    it 'should create update actions in correct order', ->
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
          attributes: [
            { name: 'foo', value: 'new value' },
            { name: 'new attribute', value: 'sameForAllAttribute' }
          ]
        variants: [
          { id: 2, sku: 'v2', attributes: [{name: 'foo', value: 'another value'}] }
          { id: 4, sku: 'v4', attributes: [{name: 'foo', value: 'yet another'}] }
        ]
      actions = @sync.buildActions(newProduct, oldProduct, ['new attribute']).getUpdateActions()

      actionNames = actions.map((a) -> a.action)
      setAttrPos = actionNames.indexOf('setAttributeInAllVariants')
      removeVariantPos = actionNames.indexOf('removeVariant')
      addVariantPos = actionNames.indexOf('addVariant')

      expect(setAttrPos).toBeGreaterThan removeVariantPos
      expect(setAttrPos).toBeLessThan addVariantPos
