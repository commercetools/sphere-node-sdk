import test from 'tape'
import customerSyncFn, { actionGroups } from '../../src/sync/customers'

test.only('Sync::customer', (t) => {
  let customerSync
  function setup () {
    customerSync = customerSyncFn()
  }

  t.test('should export action group list', (t) => {
    t.deepEqual(actionGroups, [
      'base', 'references', 'addresses',
    ])
    t.end()
  })

  t.test('::base', (t) => {
    const expectedActions = [
      {
        action: 'changeEmail',
        key: 'email',
        before: 'john@doe.com',
        now: 'jessy2@jones.com',
      },
      {
        action: 'setFirstName',
        key: 'firstName',
        before: 'John',
        now: 'Jessy',
      },
      {
        action: 'setLastName',
        key: 'lastName',
        before: 'Doe',
        now: 'Jones',
      },
      {
        action: 'setMiddleName',
        key: 'middleName',
        before: 'Figaro',
        now: 'Amanda',
      },
      {
        action: 'setTitle',
        key: 'title',
        before: 'Mr',
        now: 'Mrs',
      },
      {
        action: 'setCustomerNumber',
        key: 'customerNumber',
        before: 'a1',
        now: 'b1',
      },
      {
        action: 'setExternalId',
        key: 'externalId',
        before: '001',
        now: '002',
      },
      {
        action: 'setCompanyName',
        key: 'companyName',
        before: 'DC',
        now: 'Marvel',
      },
      {
        action: 'setDateOfBirth',
        key: 'dateOfBirth',
        before: '1980-05-15',
        now: '1988-02-21',
      },
      {
        action: 'setVatId',
        key: 'vatId',
        before: 'U-123',
        now: 'D-123',
      },
    ]

    expectedActions.forEach((expectedAction) => {
      t.test(`should build \`${expectedAction.action}\` action`, (t) => {
        setup()

        const before = { [expectedAction.key]: expectedAction.before }
        const now = { [expectedAction.key]: expectedAction.now }

        const actual = customerSync.buildActions(now, before)
        const expected = [{
          action: expectedAction.action,
          [expectedAction.key]: expectedAction.now,
        }]
        t.deepEqual(actual, expected)
        t.end()
      })

      t.test(`should build \`${expectedAction.action}\` action (unset)`,
      (t) => {
        setup()

        const before = { [expectedAction.key]: expectedAction.before }
        const now = { [expectedAction.key]: null }

        const actual = customerSync.buildActions(now, before)
        const expected = [{ action: expectedAction.action }]
        t.deepEqual(actual, expected)
        t.end()
      })
    })
  })


  t.test('::references', (t) => {
    t.test('should build `setCustomerGroup` action', (t) => {
      setup()

      const before = {}
      const now = {
        customerGroup: {
          id: '1',
          typeId: 'customer-group',
        },
      }
      const actual = customerSync.buildActions(now, before)
      const expected = [
        Object.assign({ action: 'setCustomerGroup' }, now),
      ]
      t.deepEqual(actual, expected)
      t.end()
    })

    t.test('should build `setCustomerGroup` action (unset)', (t) => {
      setup()

      const before = {
        customerGroup: {
          id: '1',
          typeId: 'customer-group',
        },
      }
      const now = {
        customerGroup: null,
      }
      const actual = customerSync.buildActions(now, before)
      const expected = [{ action: 'setCustomerGroup', customerGroup: null }]
      t.deepEqual(actual, expected)
      t.end()
    })

    t.test('should ignore expansion for existing `customerGroup`', (t) => {
      setup()

      const before = {
        customerGroup: {
          id: '1',
          typeId: 'customer-group',
          obj: {
            id: '1',
          },
        },
      }
      const now = {
        customerGroup: {
          id: '1',
          typeId: 'customer-group',
        },
      }
      const actual = customerSync.buildActions(now, before)
      const expected = []
      t.deepEqual(actual, expected)
      t.end()
    })
  })
})
