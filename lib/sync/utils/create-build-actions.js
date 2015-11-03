import clone from 'clone'

export default function createBuildActions (diff, doMapActions) {

  return function buildActions (newObj, oldObj, options = {}) {
    if (!newObj || !oldObj)
      throw new Error('Missing either `newObj` or `oldObj` ' +
        'in order to build update actions')

    const now = clone(newObj)
    const before = clone(oldObj)

    // diff 'em
    const diffed = diff(before, now)
    if (!diffed) return []

    return doMapActions(diffed, now, before, options)
  }
}
