import * as base from './utils/base'

function config (actionGroups) {
  this._syncConfig = actionGroups || []
  return this
}

function buildActions (newObj, oldObj) {
  let update

  if (!newObj || !oldObj)
    throw new Error('Missing either `newObj` or `oldObj` ' +
      'in order to build update actions')

  // diff 'em
  const diff = this.diff(oldObj, newObj)

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

function filterActions (fn) {
  if (!fn) return this
  if (!this.data.update) return this

  const filtered = this._data.update.actions.filter(fn)

  if (Object.keys(filtered).length)
    this._data.update.actions = filtered
  else this._data.update = undefined

  return this
}

function shouldUpdate () {
  if (!this._data) return false

  return Boolean(Object.keys(this._data.update).length)
}

function getUpdateId () {
  return this._data && this._data.updateId
}

function getUpdateActions () {
  return this._data && this._data.update ? this._data.update.actions : []
}

function getUpdatePayload () {
  return this._data && this._data.update
}

function _mapActionOrNot (type, fn) {
  if (!Object.keys(this._syncConfig).length) return fn()

  const found = this._syncConfig.find(c => c.type === type)
  if (!found) return []

  if (found.group === 'black') return []
  if (found.group === 'white') return fn()

  throw new Error(`Action group '${found.group}' not supported. ` +
    `Please use black or white.`)
}

function _doMapActions (/*diff, newObj, oldObj*/) {
  return []
}

export default Object.assign({
  _data: {},
  _syncConfig: []
}, {
  config,
  buildActions,
  filterActions,
  shouldUpdate,
  getUpdateId,
  getUpdateActions,
  getUpdatePayload,
  _mapActionOrNot,
  _doMapActions,
  diff: base.diff
})
