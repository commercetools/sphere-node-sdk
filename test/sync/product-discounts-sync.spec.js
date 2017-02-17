import test from 'tape'
import productDiscountsSyncFn, {
  actionGroups,
} from '../../src/sync/product-discounts'
import { baseActionsList } from '../../src/sync/product-discounts-actions'

test('Sync::productDiscounts', (t) => {
  function setup () {
    return productDiscountsSyncFn()
  }

  t.test('should export action group list', (t) => {
    t.deepEqual(actionGroups, ['base'])
    t.end()
  })

  t.test('should define action lists', (t) => {
    t.deepEqual(
      baseActionsList,
      [
        { action: 'changeName', key: 'name' },
        { action: 'setDescription', key: 'description' },
        { action: 'changeSortOrder', key: 'sortOrder' },
        { action: 'changeIsActive', key: 'isActive' },
        { action: 'changePredicate', key: 'predicate' },
        { action: 'changeValue', key: 'value' },
      ],
      'correct defined base actions list'
    )
    t.end()
  })

  t.test('should build "changeName" action', (t) => {
    const productDiscountsSync = setup()
    const before = {
      name: { en: 'en-name-before', de: 'de-name-before' },
    }

    const now = {
      name: { en: 'en-name-now', de: 'de-name-now' },
    }

    const expected = [
      {
        action: 'changeName',
        name: { en: 'en-name-now', de: 'de-name-now' },
      },
    ]

    const actual = productDiscountsSync.buildActions(now, before)
    t.deepEqual(actual, expected, 'correctly build "changeName"')
    t.end()
  })

  t.test('should build "setDescription"', (t) => {
    const productDiscountsSync = setup()
    const before = {
      description: { en: 'en-description-before', de: 'de-description-before' },
    }

    const now = {
      description: { en: 'en-description-now', de: 'de-description-now' },
    }

    const expected = [
      {
        action: 'setDescription',
        description: { en: 'en-description-now', de: 'de-description-now' },
      },
    ]

    const actual = productDiscountsSync.buildActions(now, before)
    t.deepEqual(
      actual,
      expected,
      'correctly build "setDescription"'
    )
    t.end()
  })

  t.test('should build "changeIsActive"', (t) => {
    const productDiscountsSync = setup()
    const before = {
      isActive: false,
    }

    const now = {
      isActive: true,
    }

    const expected = [
      {
        action: 'changeIsActive',
        isActive: true,
      },
    ]

    const actual = productDiscountsSync.buildActions(now, before)
    t.deepEqual(actual, expected, 'correctly build "changeIsActive"')
    t.end()
  })

  t.test('should build "changePredicate"', (t) => {
    const productDiscountsSync = setup()
    const before = { predicate: 'categoryId = "1"' }
    const now = { predicate: 'categoryId = "2"' }

    const expected = [
      {
        action: 'changePredicate',
        predicate: now.predicate,
      },
    ]

    const actual = productDiscountsSync.buildActions(now, before)
    t.deepEqual(actual, expected, 'correctly build "changePredicate"')
    t.end()
  })

  t.test('should build "changeValue"', (t) => {
    const productDiscountsSync = setup()
    const before = {
      value: {
        type: 'relative',
        permyriad: 3000,
      },
    }
    const now = {
      value: {
        type: 'absolute',
        money: {
          centAmount: 40000,
          currencyCode: 'EUR',
        },
      },
    }

    const expected = [
      {
        action: 'changeValue',
        value: now.value,
      },
    ]

    const actual = productDiscountsSync.buildActions(now, before)
    t.deepEqual(actual, expected, 'correctly build "changeValue"')
    t.end()
  })
})
