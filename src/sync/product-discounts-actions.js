import { buildBaseAttributesActions } from './utils/common-actions'

export const baseActionsList = [
  { action: 'changeName', key: 'name' },
  { action: 'setDescription', key: 'description' },
  { action: 'changeSortOrder', key: 'sortOrder' },
  { action: 'changeIsActive', key: 'isActive' },
  { action: 'changePredicate', key: 'predicate' },
  { action: 'changeValue', key: 'value' },
]

export function actionsMapBase (diff, oldObj, newObj) {
  return buildBaseAttributesActions({
    actions: baseActionsList,
    diff,
    oldObj,
    newObj,
  })
}
