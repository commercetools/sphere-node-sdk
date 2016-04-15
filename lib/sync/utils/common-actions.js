import clone from './clone'

export function buildBaseAttributesAction (
  item, diff, oldObj, newObj, patchFn
) {
  const key = item.key // e.g.: name, description, ...
  const delta = diff[key]
  const before = oldObj[key]
  const now = newObj[key]

  if (!delta) return undefined

  if (!now && !before) return undefined

  if (now && !before) // no value previously set
    return { action: item.action, [key]: now }

  if (!now && !newObj.hasOwnProperty(key)) // no new value
    return undefined

  if (!now && newObj.hasOwnProperty(key)) // value unset
    return { action: item.action }

  // We need to clone `before` as `patch` will mutate it
  const patched = patchFn(clone(before), delta)
  return { action: item.action, [key]: patched }
}
