import test from 'tape'
import categorySyncFn, { actionGroups } from '../../lib/sync/categories'

test('Sync::category', t => {

  let categorySync
  function setup () {
    categorySync = categorySyncFn()
  }

  t.test('should export action group list', t => {
    t.deepEqual(actionGroups, [
      'base', 'references', 'meta', 'custom'
    ])
    t.end()
  })

  t.test('should build `changeName` action', t => {
    setup()

    const before = {
      name: { en: 'pants', de: 'Hosen' }
    }
    const now = {
      name: { en: 'shirts' }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'changeName' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `changeSlug` action', t => {
    setup()

    const before = {
      slug: { en: 'skinny', de: 'eng' }
    }
    const now = {
      slug: { en: 'baggy' }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'changeSlug' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `changeParent` action', t => {
    setup()

    const before = {
      parent: {
        typeId: 'category',
        id: 'someCategoryId'
      }
    }
    const now = {
      parent: {
        typeId: 'category',
        id: 'someOtherCategoryId'
      }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'changeParent' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `changeOrderHint` action', t => {
    setup()

    const before = {
      orderHint: '1'
    }
    const now = {
      orderHint: '2'
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'changeOrderHint' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })
  t.test('should build `setDescription` action', t => {
    setup()

    const before = {
      description: {
        en: 'a jeans that is very tight',
        de: 'Eine Jeans-Hose, die sehr eng ist'
      }
    }
    const now = {
      description: {
        en: 'a jeans that is very loose',
        de: 'Eine Jeans-Hose, die sehr locker ist'
      }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setDescription' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setExternalId` action', t => {
    setup()

    const before = {
      externalId: 'externalId1'
    }
    const now = {
      externalId: 'externalId2'
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setExternalId' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setMetaTitle` action', t => {
    setup()

    const before = {
      metaTitle: { en: 'pants', de: 'Hosen' }
    }
    const now = {
      metaTitle: { en: 'shirts' }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setMetaTitle' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setMetaDescription` action', t => {
    setup()

    const before = {
      metaDescription: { en: 'pants', de: 'Hosen' }
    }
    const now = {
      metaDescription: { en: 'shirts' }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setMetaDescription' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setMetaKeywords` action', t => {
    setup()

    const before = {
      metaKeywords: { en: 'pants', de: 'Hosen' }
    }
    const now = {
      metaKeywords: { en: 'shirts' }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setMetaKeywords' }, now)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setCustomType` action', t => {
    setup()

    const before = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1'
        },
        fields: {
          customField1: true
        }
      }
    }
    const now = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType2'
        },
        fields: {
          customField1: true
        }
      }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setCustomType' }, now.custom)
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setCustomField` action', t => {
    setup()

    const before = {
      custom: {
        type: {
          typeId: 'type',
          id: 'customType1'
        },
        fields: {
          customField1: true, // will change
          customField2: true, // will stay unchanged
          customField3: false // will be removed
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
          customField1: false,
          customField2: true,
          customField4: true // was added
        }
      }
    }
    const actual = categorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setCustomField' }, {
        name: 'customField1',
        value: false
      }),
      Object.assign({ action: 'setCustomField' }, {
        name: 'customField3',
        value: undefined
      }),
      Object.assign({ action: 'setCustomField' }, {
        name: 'customField4',
        value: true
      })
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
