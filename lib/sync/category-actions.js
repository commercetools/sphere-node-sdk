import forEach from 'lodash.foreach'
import { buildBaseAttributesAction } from './utils/common-actions'
import * as diffpatcher from './utils/diffpatcher'

function actionsBaseList () {
  return [
    { action: 'changeName', key: 'name' },
    { action: 'changeSlug', key: 'slug' },
    { action: 'setDescription', key: 'description' },
    { action: 'changeOrderHint', key: 'orderHint' },
    { action: 'setExternalId', key: 'externalId' },
  ]
}

function actionsMetaList () {
  return [
    { action: 'setMetaTitle', key: 'metaTitle' },
    { action: 'setMetaKeywords', key: 'metaKeywords' },
    { action: 'setMetaDescription', key: 'metaDescription' },
  ]
}

/**
 * SYNC FUNCTIONS
 */

export function actionsMapBase (diff, oldObj, newObj) {
  const actions = []

  forEach(actionsBaseList(), item => {
    const action = buildBaseAttributesAction(
      item, diff, oldObj, newObj, diffpatcher.patch
    )
    if (action) actions.push(action)
  })

  return actions
}

export function actionsMapReferences (diff, oldObj, newObj) {
  const actions = []

  if (diff.parent) {
    const newValue = Array.isArray(diff.parent)
      ? diffpatcher.getDeltaValue(diff.parent)
      : newObj.parent

    actions.push({
      action: 'changeParent',
      parent: newValue,
    })
  }

  return actions
}

export function actionsMapMeta (diff, oldObj, newObj) {
  const actions = []

  forEach(actionsMetaList(), item => {
    const action = buildBaseAttributesAction(
      item, diff, oldObj, newObj, diffpatcher.patch
    )
    if (action) actions.push(action)
  })

  return actions
}

export function actionsMapCustom (diff, oldObj, newObj) {
  let actions = []
  if (!diff.custom) return actions

  if (diff.custom.type && diff.custom.type.id)
    actions.push({
      action: 'setCustomType',
      type: {
        typeId: 'type',
        id: Array.isArray(diff.custom.type.id)
          ? diffpatcher.getDeltaValue(diff.custom.type.id)
          : newObj.custom.type.id,
      },
      fields: Array.isArray(diff.custom.fields) ?
        diffpatcher.getDeltaValue(diff.custom.fields) : newObj.custom.fields,
    })
  else if (diff.custom.fields) {
    const customFieldsActions = Object.keys(diff.custom.fields).map(name => ({
      action: 'setCustomField',
      name,
      value: Array.isArray(diff.custom.fields[name])
        ? diffpatcher.getDeltaValue(diff.custom.fields[name])
        : newObj.custom.fields[name],
    }))
    actions = actions.concat(customFieldsActions)
  }

  return actions
}
