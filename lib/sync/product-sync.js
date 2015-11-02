import BaseSync from './base-sync'
import ProductUtils from './utils/product'

function flatten (a) {
  return Array.isArray(a) ? [].concat(...a.map(flatten)) : a
}

class ProductSync extends BaseSync {

  constructor () {
    super()
    this._utils = new ProductUtils()
  }

  buildActions (newObj, oldObj, sameForAllAttributeNames = []) {
    this.sameForAllAttributeNames = sameForAllAttributeNames
    super.buildActions(newObj, oldObj)
  }

  _doMapActions (diff, newObj, oldObj) {
    const allActions = []

    allActions.push(this._mapActionOrNot('base', () =>
      this._utils.actionsMapBase(diff, oldObj)))

    allActions.push(this._mapActionOrNot('references', () =>
      this._utils.actionsMapReferences(diff, oldObj, newObj)))

    allActions.push(this._mapActionOrNot('prices', () =>
      this._utils.actionsMapPrices(diff, oldObj, newObj)))

    allActions.push(this._mapActionOrNot('attributes', () =>
      this._utils.actionsMapAttributes(diff, oldObj, newObj,
        this.sameForAllAttributeNames)))

    allActions.push(this._mapActionOrNot('images', () =>
      this._utils.actionsMapImages(diff, oldObj, newObj)))

    allActions.push(this._mapActionOrNot('variants', () =>
      this._utils.actionsMapVariants(diff, oldObj, newObj)))

    allActions.push(this._mapActionOrNot('categories', () =>
      this._utils.actionsMapCategories(diff)))

    return flatten(allActions)
  }

}

ProductSync.actionGroups = [
  'base', 'references', 'prices', 'attributes',
  'images', 'variants', 'categories'
]

export default ProductSync
