import flatten from 'lodash.flatten'
import baseSync from './base-sync'
import * as utils from './utils/product'

function buildActions (newObj, oldObj, sameForAllAttributeNames = []) {
  this.sameForAllAttributeNames = sameForAllAttributeNames
  return baseSync.buildActions.call(this, newObj, oldObj)
}

function _doMapActions (diff, newObj, oldObj) {
  const allActions = []

  allActions.push(this._mapActionOrNot('base', () =>
    utils.actionsMapBase(diff, oldObj)))

  // allActions.push(this._mapActionOrNot('references', () =>
  //   utils.actionsMapReferences(diff, oldObj, newObj)))

  // allActions.push(this._mapActionOrNot('prices', () =>
  //   utils.actionsMapPrices(diff, oldObj, newObj)))

  // allActions.push(this._mapActionOrNot('attributes', () =>
  //   utils.actionsMapAttributes(diff, oldObj, newObj,
  //     this.sameForAllAttributeNames)))

  // allActions.push(this._mapActionOrNot('images', () =>
  //   utils.actionsMapImages(diff, oldObj, newObj)))

  // allActions.push(this._mapActionOrNot('variants', () =>
  //   utils.actionsMapVariants(diff, oldObj, newObj)))

  allActions.push(this._mapActionOrNot('categories', () =>
    utils.actionsMapCategories(diff)))

  return flatten(allActions)
}

export default () => Object.assign({
  actionGroups: [
    'base', 'references', 'prices', 'attributes',
    'images', 'variants', 'categories'
  ]
}, baseSync, { diff: utils.diff, buildActions, _doMapActions })
