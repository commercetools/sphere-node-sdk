import {
  buildBaseAttributesActions,
  buildReferenceActions,
} from './utils/common-actions'
import createBuildNestedObjectActions, {
  CREATE_ACTIONS,
  REMOVE_ACTIONS,
  CHANGE_ACTIONS,
} from './utils/create-build-nested-object-actions'

export const baseActionsList = [
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
]

export const referenceActionsList = [
  { action: 'setCustomerGroup', key: 'customerGroup' },
]

/**
 * SYNC FUNCTIONS
 */

export function actionsMapBase (diff, oldObj, newObj) {
  return buildBaseAttributesActions({
    actions: baseActionsList,
    diff,
    oldObj,
    newObj,
  })
}

export function actionsMapReferences (diff, oldObj, newObj) {
  return buildReferenceActions({
    actions: referenceActionsList,
    diff,
    oldObj,
    newObj,
  })
}

export function actionsMapAddresses (diff, oldObj, newObj) {
  function addAddressActionBuilder (oldArray, newArray, index) {
    return {
      action: 'addAddress',
      address: newArray[index],
    }
  }

  function removeAddressActionBuilder (oldArray, newArray, index) {
    return {
      action: 'removeAddress',
      addressId: oldArray[index].id,
    }
  }

  function changeAddressActionBuilder (oldArray, newArray, index) {
    return {
      action: 'changeAddress',
      addressId: oldArray[index].id,
      address: newArray[index],
    }
  }

  const handler = createBuildNestedObjectActions('addresses', {
    [CREATE_ACTIONS]: addAddressActionBuilder,
    [REMOVE_ACTIONS]: removeAddressActionBuilder,
    [CHANGE_ACTIONS]: changeAddressActionBuilder,
  })

  return handler(diff, oldObj, newObj)
}
