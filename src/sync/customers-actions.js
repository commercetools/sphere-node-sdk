import forEach from 'lodash.foreach'
import { buildBaseAttributesAction } from './utils/common-actions'
import * as diffpatcher from './utils/diffpatcher'

function actionsBaseList () {
  return [
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
}

/**
 * SYNC FUNCTIONS
 */

export function actionsMapBase (diff, oldObj, newObj) {
  const actions = []

  forEach(actionsBaseList(), (item) => {
    const action = buildBaseAttributesAction(
      item, diff, oldObj, newObj, diffpatcher.patch
    )
    if (action) actions.push(action)
  })

  return actions
}

export function actionsMapReferences (diff, oldObj, newObj) {
  const actions = []

  if (diff.customerGroup && !(
    // If the only change relates to the expansion `obj`, simply ignore it.
    diff.customerGroup.obj &&
    Object.keys(diff.customerGroup).length === 1
  )) {
    const newValue = Array.isArray(diff.customerGroup)
      ? diffpatcher.getDeltaValue(diff.customerGroup)
      : newObj.customerGroup

    actions.push({
      action: 'setCustomerGroup',
      customerGroup: newValue,
    })
  }

  return actions
}

export function actionsMapAddresses (/* diff, oldObj, newObj */) {
  const actions = []
  return actions
}
