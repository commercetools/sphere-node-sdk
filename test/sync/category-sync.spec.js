import test from 'tape'
import categorySyncFn, { actionGroups } from '../../src/sync/categories'
import {
  baseActionsList,
  metaActionsList,
  referenceActionsList,
} from '../../src/sync/category-actions'

test('Sync::category', (t) => {
  let categorySync
  function setup () {
    categorySync = categorySyncFn()
  }

  t.test('should export action group list', (t) => {
    t.deepEqual(actionGroups, [
      'base', 'references', 'meta', 'custom',
    ])
    t.end()
  })

  t.test('should define action lists', (t) => {
    t.deepEqual(
      baseActionsList,
      [
        { action: 'changeName', key: 'name' },
        { action: 'changeSlug', key: 'slug' },
        { action: 'setDescription', key: 'description' },
        { action: 'changeOrderHint', key: 'orderHint' },
        { action: 'setExternalId', key: 'externalId' },
      ],
      'correctly define base actions list'
    )

    t.deepEqual(
      metaActionsList,
      [
        { action: 'setMetaTitle', key: 'metaTitle' },
        { action: 'setMetaKeywords', key: 'metaKeywords' },
        { action: 'setMetaDescription', key: 'metaDescription' },
      ],
      'correctly define meta actions list'
    )

    t.deepEqual(
      referenceActionsList,
      [
        { action: 'changeParent', key: 'parent' },
      ],
      'correctly define reference actions list'
    )

    t.end()
  })

  t.test('should build `setCustomType` action', (t) => {
    setup()

    const before = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1',
        },
        fields: {
          customField1: true,
        },
      },
    }
    const now = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType2',
        },
        fields: {
          customField1: true,
        },
      },
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setCustomType' }, now.custom),
    ]
    t.deepEqual(actual, expected)

    t.end()
  })

  t.test('should build `setCustomField` action', (t) => {
    setup()

    const before = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1',
        },
        fields: {
          customField1: true, // will change
          customField2: true, // will stay unchanged
          customField3: false, // will be removed
        },
      },
    }
    const now = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1',
        },
        fields: {
          customField1: false,
          customField2: true,
          customField4: true, // was added
        },
      },
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      {
        action: 'setCustomField',
        name: 'customField1',
        value: false,
      },
      {
        action: 'setCustomField',
        name: 'customField3',
        value: undefined,
      },
      {
        action: 'setCustomField',
        name: 'customField4',
        value: true,
      },
    ]
    t.deepEqual(actual, expected)

    t.end()
  })
})
