import test from 'tape'
import customerSyncFn, { actionGroups } from '../../src/sync/customers'
import {
  baseActionsList,
  referenceActionsList,
} from '../../src/sync/customer-actions'

test('Sync::customer', (t) => {
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

  t.test('should define action lists', (t) => {
    t.deepEqual(
      baseActionsList,
      [
        { action: 'changeEmail', key: 'email' },
        { action: 'setFirstName', key: 'firstName' },
        { action: 'setLastName', key: 'lastName' },
        { action: 'setMiddleName', key: 'middleName' },
        { action: 'setTitle', key: 'title' },
        { action: 'setCustomerNumber', key: 'customerNumber' },
        { action: 'setExternalId', key: 'externalId' },
        { action: 'setCompanyName', key: 'companyName' },
        { action: 'setDateOfBirth', key: 'dateOfBirth' },
        { action: 'setVatId', key: 'vatId' },
      ],
      'correctly define base actions list'
    )

    t.deepEqual(
      referenceActionsList,
      [
        { action: 'setCustomerGroup', key: 'customerGroup' },
      ],
      'correctly define reference actions list'
    )

    t.end()
  })

  t.test('should build `changeEmail` action', (t) => {
    setup()

    const before = {
      email: 'john@doe.com',
    }
    const now = {
      email: 'jessy@jones.com',
    }

    const actual = customerSync.buildActions(now, before)
    const expected = [{ action: 'changeEmail', email: now.email }]
    t.deepEqual(actual, expected)

    t.end()
  })
})
