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
        {
          action: 'setDefaultBillingAddress',
          key: 'defaultBillingAddressId',
          actionKey: 'addressId',
        },
        {
          action: 'setDefaultShippingAddress',
          key: 'defaultShippingAddressId',
          actionKey: 'addressId',
        },
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

  t.test('should build `setDefaultBillingAddress` action', (t) => {
    setup()

    const before = {
      defaultBillingAddressId: 'abc123',
    }
    const now = {
      defaultBillingAddressId: 'def456',
    }

    const actual = customerSync.buildActions(now, before)
    const expected = [
      {
        action: 'setDefaultBillingAddress',
        addressId: now.defaultBillingAddressId,
      },
    ]

    t.deepEqual(
      actual,
      expected,
      'should generate setDefaultBillingAddress action'
    )
    t.end()
  })

  t.test('should build `setDefaultShippingAddress` action', (t) => {
    setup()

    const before = {
      defaultShippingAddressId: 'abc123',
    }
    const now = {
      defaultShippingAddressId: 'def456',
    }

    const actual = customerSync.buildActions(now, before)
    const expected = [
      {
        action: 'setDefaultShippingAddress',
        addressId: now.defaultShippingAddressId,
      },
    ]

    t.deepEqual(
      actual,
      expected,
      'should generate setDefaultShippingAddress action'
    )
    t.end()
  })

  t.test('should build `addAddress` action', (t) => {
    setup()

    const before = { addresses: [] }
    const now = {
      addresses: [
        { streetName: 'some name', streetNumber: '5' },
      ],
    }

    const actual = customerSync.buildActions(now, before)
    const expected = [{ action: 'addAddress', address: now.addresses[0] }]
    t.deepEqual(actual, expected, 'should create `addAddress` action')
    t.end()
  })

  t.test('should build `changeAddress` action', (t) => {
    setup()

    const before = {
      addresses: [
        {
          id: 'somelongidgoeshere199191',
          streetName: 'some name',
          streetNumber: '5',
        },
      ],
    }
    const now = {
      addresses: [
        {
          id: 'somelongidgoeshere199191',
          streetName: 'some different name',
          streetNumber: '5',
        },
      ],
    }

    const actual = customerSync.buildActions(now, before)
    const expected = [
      {
        action: 'changeAddress',
        addressId: before.addresses[0].id,
        address: now.addresses[0],
      },
    ]

    t.deepEqual(actual, expected, 'should create `changeAddress` action')
    t.end()
  })

  t.test('should build `removeAddress` action', (t) => {
    setup()

    const before = {
      addresses: [
        { id: 'somelongidgoeshere199191' },
      ],
    }
    const now = { addresses: [] }

    const actual = customerSync.buildActions(now, before)
    const expected = [
      {
        action: 'removeAddress',
        addressId: before.addresses[0].id,
      },
    ]
    t.deepEqual(actual, expected, 'should create `removeAddress` action')
    t.end()
  })

  t.test('should build complex mixed actions', (t) => {
    setup()

    const before = {
      addresses: [
        {
          id: 'addressId1',
          title: 'mr',
          streetName: 'address 1 street',
          postalCode: 'postal code 1',
        },
        {
          id: 'addressId2',
          title: 'mr',
          streetName: 'address 2 street',
          postalCode: 'postal code 2',
        },
        {
          id: 'addressId4',
          title: 'mr',
          streetName: 'address 4 street',
          postalCode: 'postal code 4',
        },
      ],
    }
    const now = {
      addresses: [
        {
          id: 'addressId1',
          title: 'mr',
          streetName: 'address 1 street changed', // CHANGED
          postalCode: 'postal code 1',
        },
        // REMOVED ADDRESS 2
        { // UNCHANGED ADDRESS 4
          id: 'addressId4',
          title: 'mr',
          streetName: 'address 4 street',
          postalCode: 'postal code 4',
        },
        { // ADD NEW ADDRESS
          id: 'addressId3',
          title: 'mr',
          streetName: 'address 3 street',
          postalCode: 'postal code 3',
        },
      ],
    }

    const actual = customerSync.buildActions(now, before)
    const expected = [
      { // CHANGE ACTIONS FIRST
        action: 'changeAddress',
        addressId: 'addressId1',
        address: now.addresses[0],
      },
      { // REMOVE ACTIONS NEXT
        action: 'removeAddress',
        addressId: 'addressId2',
      },
      { // CREATE ACTIONS LAST
        action: 'addAddress',
        address: now.addresses[2],
      },
    ]

    t.deepEqual(actual, expected, 'should build multiple actions')
    t.end()
  })
})
