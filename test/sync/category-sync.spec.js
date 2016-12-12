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

  t.test('should build `setCustomField` action with Enum values', t => {
    setup()
    const before = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1'
        },
        fields: {
          enumField1: 'old_enum_value_1', // will change
          enumField2: 'enum_value_2', // will be removed
        }
      }
    }

    const now = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1'
        },
        fields: {
          enumField1: 'new_enum_value_1',
          enumField3: 'enum_value_3'
        }
      }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      {
        action: 'setCustomField',
        name: 'enumField1',
        value: 'new_enum_value_1'
      },
      {
        action: 'setCustomField',
        name: 'enumField2',
        value: undefined
      },
      {
        action: 'setCustomField',
        name: 'enumField3',
        value: 'enum_value_3'
      }
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setCustomField` action with LocalizedEnum values',
    t => {
      setup()
      const before = {
        custom: {
          type: {
            typeId: 'type',
            id: 'customType1'
          },
          fields: {
            localizedEnumField1: {
              "en": "lenum_en_1",
              "de": "lenum_de_1" // will change
            },
            localizedEnumField2: { // will be removed
              "en": "lenum_en_2",
              "de": "lenum_de_2"
            },
          }
        }
      }

      const now = {
        custom: {
          type: {
            typeId: 'type',
            id: 'customType1'
          },
          fields: {
            localizedEnumField1: {
              "en": "lenum_en_1",
              "de": "lenum_de_2"
            },
            localizedEnumField3: { // was added
              "en": "lenum_en_3",
              "de": "lenum_de_3"
            },
          }
        }
      }
      const actual = categorySync.buildActions(now, before)
      const expected = [
        {
          action: 'setCustomField',
          name: 'localizedEnumField1',
          value: {
            "en": "lenum_en_1",
            "de": "lenum_de_2"
          }
        },
        {
          action: 'setCustomField',
          name: 'localizedEnumField2',
          value: undefined
        },
        {
          action: 'setCustomField',
          name: 'localizedEnumField3',
          value: {
            "en": "lenum_en_3",
            "de": "lenum_de_3"
          }
        }
      ]
      t.deepEqual(actual, expected)
      t.end()
    })

  t.test('should build `setCustomField` action with Money values', t => {
    setup()
    const before = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1'
        },
        fields: {
          moneyField1: { // will change
            centAmount: 123000,
            currencyCode: 'EUR'
          },
          moneyField2: { // wil be removed
            centAmount: 213000,
            currencyCode: 'EUR'
          }
        }
      }
    }

    const now = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1'
        },
        fields: {
          moneyField1: {
            centAmount: 123000,
            currencyCode: 'SEK'
          },
          moneyField3: {
            centAmount: 213000,
            currencyCode: 'USD'
          }
        }
      }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      {
        action: 'setCustomField',
        name: 'moneyField1',
        value: { centAmount: 123000, currencyCode: 'SEK' }
      },
      {
        action: 'setCustomField',
        name: 'moneyField2',
        value: undefined
      },
      {
        action: 'setCustomField',
        name: 'moneyField3',
        value: { centAmount: 213000, currencyCode: 'USD' }
      }
    ]
    t.deepEqual(actual, expected)
    t.end()
  })
})
