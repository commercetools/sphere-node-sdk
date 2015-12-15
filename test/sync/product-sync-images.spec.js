import test from 'tape'
import productsSyncFn from '../../lib/sync/products'

/* eslint-disable max-len */
test('Sync::product::images', t => {

  let productsSync
  function setup () {
    productsSync = productsSyncFn()
  }

  t.test('should build actions for images', t => {
    setup()

    const before = {
      id: '123',
      masterVariant: {
        id: 1,
        images: []
      },
      variants: [
        {
          id: 2,
          images: [{
            url: '//example.com/image2.png', label: 'foo', dimensions: { h: 1024, w: 768 }
          }]
        },
        {
          id: 3,
          images: [
            { url: '//example.com/image3.png', label: 'foo', dimensions: { h: 1024, w: 768 } },
            { url: '//example.com/image4.png', dimensions: { h: 1024, w: 768 } },
            { url: '//example.com/image5.png', label: 'foo', dimensions: { h: 1024, w: 768 } }
          ]
        },
        {
          id: 4,
          images: [
            // Order is important!
            { url: '//example.com/old-remove.png', dimensions: { h: 400, w: 600 } },
            { url: '//example.com/old-keep.png', dimensions: { h: 608, w: 1000 } }
          ]
        }
      ]
    }

    const now = {
      id: '123',
      masterVariant: {
        id: 1,
        images: [
          // new image
          { url: 'http://cat.com', label: 'A cat' }
        ]
      },
      variants: [
        {
          id: 2,
          images: [
            // no changes
            { url: '//example.com/image2.png', label: 'foo', dimensions: { h: 1024, w: 768 } }
          ]
        },
        {
          id: 3,
          images: [
            // label changed
            { url: '//example.com/image3.png', label: 'CHANGED', dimensions: { h: 1024, w: 768 } },
            // label added
            { url: '//example.com/image4.png', label: 'ADDED', dimensions: { h: 400, w: 300 } },
            // url changed (new image)
            { url: '//example.com/CHANGED.jpg', label: 'foo', dimensions: { h: 400, w: 300 } }
          ]
        },
        // images removed
        {
          id: 4,
          images: [
            { url: '//example.com/old-keep.png', dimensions: { h: 608, w: 1000 } }
          ]
        }
      ]
    }

    const actions = productsSync.buildActions(now, before)
    t.deepEqual(actions, [
      { action: 'addExternalImage', variantId: 1, image: { url: 'http://cat.com', label: 'A cat' } },
      { action: 'changeImageLabel', variantId: 3, imageUrl: '//example.com/image3.png', label: 'CHANGED' },
      { action: 'changeImageLabel', variantId: 3, imageUrl: '//example.com/image4.png', label: 'ADDED' },
      { action: 'addExternalImage', variantId: 3, image: { url: '//example.com/CHANGED.jpg', label: 'foo', dimensions: { h: 400, w: 300 } } },
      { action: 'removeImage', variantId: 3, imageUrl: '//example.com/image5.png' },
      { action: 'removeImage', variantId: 4, imageUrl: '//example.com/old-remove.png' }
    ])
    t.end()
  })

  t.test('should not build actions if images are not set', t => {
    setup()

    const before = {
      id: '123-abc',
      masterVariant: { id: 1, images: [] },
      variants: []
    }
    const now = {
      id: '456-def',
      masterVariant: { id: 1 },
      variants: []
    }

    const actions = productsSync.buildActions(now, before)
    t.deepEqual(actions, [])
    t.end()
  })
})
