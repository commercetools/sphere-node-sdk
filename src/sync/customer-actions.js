import {
  buildBaseAttributesActions,
  buildReferenceActions,
} from './utils/common-actions'

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

export function actionsMapAddresses (/* diff, oldObj, newObj */) {
  const actions = []
  return actions
}
