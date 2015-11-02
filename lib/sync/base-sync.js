import BaseUtils from './utils/base'

export default class BaseSync {

  constructor () {
    this._data = {}
    this._utils = new BaseUtils()
    this._syncConfig = []
  }

  config (actionGroups) {
    this._syncConfig = actionGroups || []
    return this
  }

  buildActions (newObj, oldObj) {
    let update

    if (!newObj || !oldObj)
      throw new Error('Missing either `newObj` or `oldObj` ' +
        'in order to build update actions')

    // diff 'em
    const diff = this._utils.diff(oldObj, newObj)

    if (diff) {
      const actions = this._doMapActions(diff, newObj, oldObj)
      if (actions.length > 0)
        update = {
          actions: actions,
          version: oldObj.version
        }
    }
    this._data = {
      update: update,
      updateId: oldObj.id
    }

    return this
  }

  filterActions (fn) {
    if (!fn) return this
    if (!this.data.update) return this

    const filtered = this._data.update.actions.filter(fn)

    if (Object.keys(filtered).length)
      this._data.update.actions = filtered
    else this._data.update = undefined

    return this
  }

  shouldUpdate () {
    return Boolean(Object.keys(this._data.update).length)
  }

  getUpdateId () {
    return this._data && this._data.updateId
  }

  getUpdateActions () {
    return this._data && this._data.update ? this._data.update.actions : []
  }

  getUpdatePayload () {
    return this._data && this._data.update
  }

  _mapActionOrNot (type, fn) {
    if (!Object.keys(this._syncConfig).length) return fn()

    const found = this._syncConfig.find(c => c.type === type)
    if (!found) return []

    if (found.group === 'black') return []
    if (found.group === 'white') return fn()

    throw new Error(`Action group '${found.group}' not supported. ` +
      `Please use black or white.`)
  }

  _doMapActions (/*diff, newObj, oldObj*/) {
    return []
  }

}
