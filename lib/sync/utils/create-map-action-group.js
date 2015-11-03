export default function createMapActionGroup (actionGroups = []) {

  return function mapActionGroup (type, fn) {
    if (!Object.keys(actionGroups).length) return fn()

    const found = actionGroups.find(c => c.type === type)
    if (!found) return []

    if (found.group === 'black') return []
    if (found.group === 'white') return fn()

    throw new Error(`Action group '${found.group}' not supported. ` +
      `Please use black or white.`)
  }
}
