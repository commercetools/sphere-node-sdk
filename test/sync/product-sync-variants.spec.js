import test from 'tape'
import productsSyncFn from '../../lib/sync/products'

/* eslint-disable max-len */
test('Sync::product::variants', t => {

  let productsSync
  function setup () {
    productsSync = productsSyncFn()
  }

  t.test('should build attribute actions', t => {
    setup()

    const before = {
      id: '123',
      masterVariant: {
        id: 1, attributes: [
          { name: 'uid', value: '20063672' },
          { name: 'length', value: 160 },
          { name: 'wide', value: 85 },
          { name: 'bulkygoods', value: { label: 'Ja', key: 'YES' } },
          { name: 'ean', value: '20063672' }
        ]
      },
      variants: [
        {
          id: 2, attributes: [
            { name: 'uid', value: '20063672' },
            { name: 'length', value: 160 },
            { name: 'wide', value: 85 },
            { name: 'bulkygoods', value: { label: 'Ja', key: 'YES' } },
            { name: 'ean', value: '20063672' }
          ]
        },
        { id: 3, attributes: [] },
        {
          id: 4, attributes: [
            { name: 'uid', value: '1234567' },
            { name: 'length', value: 123 },
            { name: 'bulkygoods', value: { label: 'Si', key: 'SI' } }
          ]
        }
      ]
    }

    const now = {
      id: '123',
      masterVariant: {
        id: 1, attributes: [
          { name: 'uid', value: '20063675' }, // changed
          { name: 'length', value: 160 },
          { name: 'wide', value: 10 }, // changed
          { name: 'bulkygoods', value: 'NO' }, // changed
          { name: 'ean', value: '20063672' }
        ]
      },
      variants: [
        {
          id: 2, attributes: [
            { name: 'uid', value: '20055572' }, // changed
            { name: 'length', value: 333 }, // changed
            { name: 'wide', value: 33 }, // changed
            { name: 'bulkygoods', value: 'YES' }, // changed
            { name: 'ean', value: '20063672' }
          ]
        },
        {
          id: 3, attributes: [ // new
            { name: 'uid', value: '00001' },
            { name: 'length', value: 500 },
            { name: 'bulkygoods', value: 'SI' }
          ]
        },
        { id: 4, attributes: [] } // removed
      ]
    }

    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      { action: 'setAttribute', variantId: 1, name: 'uid', value: '20063675' },
      { action: 'setAttribute', variantId: 1, name: 'wide', value: 10 },
      { action: 'setAttribute', variantId: 1, name: 'bulkygoods', value: 'NO' },

      { action: 'setAttribute', variantId: 2, name: 'uid', value: '20055572' },
      { action: 'setAttribute', variantId: 2, name: 'length', value: 333 },
      { action: 'setAttribute', variantId: 2, name: 'wide', value: 33 },
      { action: 'setAttribute', variantId: 2, name: 'bulkygoods', value: 'YES' },

      { action: 'setAttribute', variantId: 3, name: 'uid', value: '00001' },
      { action: 'setAttribute', variantId: 3, name: 'length', value: 500 },
      { action: 'setAttribute', variantId: 3, name: 'bulkygoods', value: 'SI' },

      { action: 'setAttribute', variantId: 4, name: 'uid', value: undefined },
      { action: 'setAttribute', variantId: 4, name: 'length', value: undefined },
      { action: 'setAttribute', variantId: 4, name: 'bulkygoods', value: undefined }
    ])
    t.end()
  })

  t.test('should build SameForAll attribute actions', t => {
    setup()

    const before = {
      id: '123',
      masterVariant: {
        id: 1, attributes: [
          { name: 'color', value: 'red' }
        ]
      },
      variants: []
    }

    const now = {
      id: '123',
      masterVariant: {
        id: 1, attributes: [
          { name: 'vendor', value: 'ferrari' },
          { name: 'color', value: 'yellow' }
        ]
      },
      variants: []
    }

    const actions = productsSync.buildActions(now, before, {
      sameForAllAttributeNames: ['vendor']
    })

    t.deepEqual(actions, [
      { action: 'setAttributeInAllVariants', name: 'vendor', value: 'ferrari' },
      { action: 'setAttribute', variantId: 1, name: 'color', value: 'yellow' }
    ])
    t.end()
  })

  t.test('should build `addVariant` action', t => {
    setup()

    const newVariant = {
      sku: 'ccc',
      attributes: [{ name: 'color', value: 'red' }],
      images: [{ url: 'http://foo.com', label: 'foo' }],
      prices: [{ value: { centAmount: 300, currencyCode: 'USD' } }]
    }

    const before = { variants: [
      {
        id: 2,
        sku: 'aaa',
        attributes: [{ name: 'color', value: 'green' }],
        prices: [{ value: { centAmount: 100, currencyCode: 'EUR' } }]
      },
      {
        id: 3,
        sku: 'bbb',
        attributes: [{ name: 'color', value: 'yellow' }],
        prices: [{ value: { centAmount: 200, currencyCode: 'GBP' } }]
      }
    ] }
    const now = { variants: before.variants.slice(0, 1).concat(newVariant) }

    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      { action: 'removeVariant', id: 3 },
      Object.assign({ action: 'addVariant' }, newVariant)
    ])
    t.end()
  })

  t.test('should handle mapping actions for new variants without ids', t => {
    setup()

    const before = {
      id: '123',
      masterVariant: {
        id: 1, sku: 'v1', attributes: [{ name: 'foo', value: 'bar' }]
      },
      variants: [
        { id: 2, sku: 'v2', attributes: [{ name: 'foo', value: 'qux' }] },
        { id: 3, sku: 'v3', attributes: [{ name: 'foo', value: 'baz' }] }
      ]
    }

    const now = {
      id: '123',
      masterVariant: {
        sku: 'v1', attributes: [{ name: 'foo', value: 'new value' }]
      },
      variants: [
        { id: 2, sku: 'v2', attributes: [{ name: 'foo', value: 'another value' }] },
        { id: 3, sku: 'v4', attributes: [{ name: 'foo', value: 'i dont care' }] },
        { sku: 'v3', attributes: [{ name: 'foo', value: 'yet another' }] }
      ]
    }

    const actions = productsSync.buildActions(now, before)
    t.deepEqual(actions, [
      { action: 'addVariant', sku: 'v3', attributes: [{ name: 'foo', value: 'yet another' }] },
      { action: 'setAttribute', variantId: 1, name: 'foo', value: 'new value' },
      { action: 'setAttribute', variantId: 2, name: 'foo', value: 'another value' },
      { action: 'setSKU', sku: 'v4', variantId: 3 },
      { action: 'setAttribute', variantId: 3, name: 'foo', value: 'i dont care' }
    ])
    t.end()
  })

  t.test('should build attribute actions for all types', t => {
    setup()

    const before = {
      id: '123',
      masterVariant: {
        id: 1,
        attributes: [
          { name: 'foo', value: 'bar' }, // text
          { name: 'dog', value: { en: 'Dog', de: 'Hund', es: 'perro' } }, // ltext
          { name: 'num', value: 50 }, // number
          { name: 'count', value: { label: 'One', key: 'one' } }, // enum
          { name: 'size', value: { label: { en: 'Medium' }, key: 'medium' } }, // lenum
          { name: 'color', value: { label: { en: 'Color' }, key: 'red' } }, // lenum
          { name: 'cost', value: { centAmount: 990, currencyCode: 'EUR' } }, // money
          { name: 'reference', value: { typeId: 'product', id: '111' } }, // reference
          { name: 'welcome', value: [ 'hello', 'world' ] }, // set text
          { name: 'welcome2', value: [ { en: 'hello', 'it': 'ciao' }, { en: 'world', 'it': 'mondo' } ] }, // set ltext
          { name: 'multicolor', value: [ 'red' ] }, // set enum
          { name: 'multicolor2', value: [{ key: 'red', label: { en: 'red', it: 'rosso' } }] } // set lenum
        ]
      }
    }

    const now = {
      id: '123',
      masterVariant: {
        id: 1,
        attributes: [
          { name: 'foo', value: 'qux' }, // text
          { name: 'dog', value: { en: 'Doggy', it: 'Cane', es: 'perro' } }, // ltext
          { name: 'num', value: 100 }, // number
          { name: 'count', value: { label: 'Two', key: 'two' } }, // enum
          { name: 'size', value: { label: { en: 'Small' }, key: 'small' } }, // lenum
          { name: 'color', value: { label: { en: 'Blue' }, key: 'blue' } }, // lenum
          { name: 'cost', value: { centAmount: 550, currencyCode: 'EUR' } }, // money
          { name: 'reference', value: { typeId: 'category', id: '222' } }, // reference
          { name: 'welcome', value: ['hello'] }, // set text
          { name: 'welcome2', value: [{ en: 'hello', 'it': 'ciao' }] }, // set ltext
          { name: 'multicolor', value: [ 'red', 'yellow' ] }, // set enum
          { name: 'multicolor2', value: [ { key: 'red', label: { en: 'red', it: 'rosso' } }, { key: 'yellow', label: { en: 'yellow', it: 'giallo' } } ] } // set lenum
        ]
      }
    }

    const actions = productsSync.buildActions(now, before)
    t.deepEqual(actions, [
      { action: 'setAttribute', variantId: 1, name: 'foo', value: 'qux' },
      { action: 'setAttribute', variantId: 1, name: 'dog', value: { en: 'Doggy', it: 'Cane', de: undefined, es: 'perro' } },
      { action: 'setAttribute', variantId: 1, name: 'num', value: 100 },
      { action: 'setAttribute', variantId: 1, name: 'count', value: 'two' },
      { action: 'setAttribute', variantId: 1, name: 'size', value: 'small' },
      { action: 'setAttribute', variantId: 1, name: 'color', value: 'blue' },
      { action: 'setAttribute', variantId: 1, name: 'cost', value: { centAmount: 550, currencyCode: 'EUR' } },
      { action: 'setAttribute', variantId: 1, name: 'reference', value: { typeId: 'category', id: '222' } },
      { action: 'setAttribute', variantId: 1, name: 'welcome', value: ['hello'] },
      { action: 'setAttribute', variantId: 1, name: 'welcome2', value: [{ en: 'hello', 'it': 'ciao' }] },
      { action: 'setAttribute', variantId: 1, name: 'multicolor', value: [ 'red', 'yellow' ] },
      { action: 'setAttribute', variantId: 1, name: 'multicolor2', value: [ { key: 'red', label: { en: 'red', it: 'rosso' } }, { key: 'yellow', label: { en: 'yellow', it: 'giallo' } } ] } // set lenum
    ])
    t.end()
  })
})
