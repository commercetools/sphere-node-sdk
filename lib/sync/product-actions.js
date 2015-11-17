/* eslint-disable max-len */
import forEach from 'lodash.foreach'
import unique from 'lodash.uniq'
import clone from './utils/clone'
import { find } from './utils/array'
import * as diffpatcher from './utils/diffpatcher'

const REGEX_NUMBER = new RegExp(/^\d+$/)
const REGEX_UNDERSCORE_NUMBER = new RegExp(/^\_\d+$/)

function actionsBaseList () {
  return [
    { action: 'changeName', key: 'name' },
    { action: 'changeSlug', key: 'slug' },
    { action: 'setDescription', key: 'description' },
    { action: 'setMetaTitle', key: 'metaTitle' },
    { action: 'setMetaDescription', key: 'metaDescription' },
    { action: 'setMetaKeywords', key: 'metaKeywords' },
    { action: 'setSearchKeywords', key: 'searchKeywords' }
  ]
}


/**
 * SYNC FUNCTIONS
 */

export function actionsMapBase (diff, oldObj, newObj) {
  let actions = []

  forEach(actionsBaseList(), item => {
    const action = _buildBaseAttributesAction(item, diff, oldObj, newObj)
    if (action) actions.push(action)
  })

  return actions
}

export function actionsMapVariants (diff, oldObj, newObj) {
  const actions = []
  if (!diff.variants) return actions

  const addVariantActions = []
  const removeVariantActions = []
  forEach(diff.variants, (variant, index) => {
    if (REGEX_NUMBER.test(index) && Array.isArray(variant)) {
      const newVariant = newObj.variants[index]
      const action = Object.assign({ action: 'addVariant' }, newVariant)
      addVariantActions.push(action)

    } else if (REGEX_UNDERSCORE_NUMBER.test(index) && Array.isArray(variant))
      // If array move do nothing, otherwise remove the variant
      if (!(variant.length === 3 && variant[2] === 3))
        removeVariantActions.push({
          action: 'removeVariant', id: variant[0].id
        })
  })

  // Make sure `removeVariant` actions come first
  return removeVariantActions.concat(addVariantActions)
}

export function actionsMapReferences (diff, oldObj, newObj) {
  const actions = []
  if (!diff.taxCategory) return actions

  actions.push({
    action: 'setTaxCategory',
    taxCategory: Array.isArray(diff.taxCategory) ?
      diffpatcher.getDeltaValue(diff.taxCategory) : newObj.taxCategory
  })
  return actions
}

export function actionsMapCategories (diff) {
  const actions = []
  if (!diff.categories) return actions

  const addToCategoryActions = []
  const removeFromCategoryActions = []
  forEach(diff.categories, category => {
    if (Array.isArray(category)) {

      const action = { category: category[0] }

      if (category.length === 3) {
        // Ignore pure array moves!
        if (category[2] !== 3) {
          action.action = 'removeFromCategory'
          removeFromCategoryActions.push(action)
        }
      } else if (category.length === 1) {
        action.action = 'addToCategory'
        addToCategoryActions.push(action)
      }
    }
  })

  // Make sure `removeFromCategory` actions come first
  return removeFromCategoryActions.concat(addToCategoryActions)
}

export function actionsMapAttributes (diff, oldObj, newObj,
  sameForAllAttributeNames = []) {
  // TODO: validate ProductType between products
  let actions = []
  const { masterVariant, variants } = diff

  if (masterVariant) {
    const skuAction =
      _buildSkuActions(masterVariant, oldObj.masterVariant)
    if (skuAction) actions.push(skuAction)

    const { attributes } = masterVariant
    const attrActions = _buildVariantAttributesActions(
      attributes, oldObj.masterVariant, newObj.masterVariant,
      sameForAllAttributeNames)
    actions = actions.concat(attrActions)
  }

  if (variants)
    forEach(variants, (variant, key) => {
      if (REGEX_NUMBER.test(key) && !Array.isArray(variant)) {
        const skuAction =
          _buildSkuActions(variant, oldObj.variants[key])
        if (skuAction) actions.push(skuAction)

        const { attributes } = variant
        const attrActions = _buildVariantAttributesActions(
          attributes, oldObj.variants[key], newObj.variants[key],
          sameForAllAttributeNames)
        actions = actions.concat(attrActions)
      }
    })

  // Ensure we have each action only once per product.
  // Use string representation of object to allow `===` on array objects
  return unique(actions, action => JSON.stringify(action))
}

export function actionsMapImages (diff, oldObj, newObj) {
  let actions = []
  const { masterVariant, variants } = diff

  if (masterVariant) {
    const mActions = _buildVariantImagesAction(masterVariant.images,
      oldObj.masterVariant, newObj.masterVariant)
    actions = actions.concat(mActions)
  }

  if (variants)
    forEach(variants, (variant, key) => {
      const vActions = _buildVariantImagesAction(variant.images,
        oldObj.variants[key], newObj.variants[key])
      actions = actions.concat(vActions)
    })

  return actions
}

export function actionsMapPrices (diff, oldObj, newObj) {
  let addPriceActions = []
  let changePriceActions = []
  let removePriceActions = []

  const { masterVariant, variants } = diff

  if (masterVariant) {
    const [ a, c, r ] = _buildVariantPricesAction(masterVariant.prices,
      oldObj.masterVariant, newObj.masterVariant)
    addPriceActions = addPriceActions.concat(a)
    changePriceActions = changePriceActions.concat(c)
    removePriceActions = removePriceActions.concat(r)
  }

  if (variants)
    forEach(variants, (variant, key) => {
      const [ a, c, r ] = _buildVariantPricesAction(variant.prices,
      oldObj.variants[key], newObj.variants[key])

      addPriceActions = addPriceActions.concat(a)
      changePriceActions = changePriceActions.concat(c)
      removePriceActions = removePriceActions.concat(r)
    })

  return changePriceActions.concat(
    removePriceActions.concat(addPriceActions))
}


/**
 * HELPER FUNCTIONS
 */

function _buildBaseAttributesAction (item, diff, oldObj, newObj) {
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
  const patched = diffpatcher.patch(clone(before), delta)
  return { action: item.action, [key]: patched }
}


function _buildSkuActions (variantDiff, oldVariant) {
  if (variantDiff.hasOwnProperty('sku'))
    return {
      action: 'setSKU',
      variantId: oldVariant.id,
      sku: diffpatcher.getDeltaValue(variantDiff.sku)
    }
}

function _buildVariantAttributesActions (attributes, oldVariant, newVariant,
  sameForAllAttributeNames) {

  const actions = []

  if (!attributes) return actions

  forEach(attributes, (value, key) => {
    if (REGEX_NUMBER.test(key)) {

      if (Array.isArray(value)) {
        const { id } = oldVariant
        const deltaValue = diffpatcher.getDeltaValue(value)
        const setAction =
          _buildNewSetAttributeAction(id, deltaValue, sameForAllAttributeNames)

        if (setAction) actions.push(setAction)

      } else
        if (newVariant.attributes) {
          const setAction = _buildSetAttributeAction(value.value, oldVariant,
            newVariant.attributes[key], sameForAllAttributeNames)
          if (setAction) actions.push(setAction)
        }

    } else if (REGEX_UNDERSCORE_NUMBER.test(key))
      if (Array.isArray(value)) {
        // Ignore pure array moves!
        if (value.length === 3 && value[2] === 3)
          return

        const { id } = oldVariant
        const deltaValue = diffpatcher.getDeltaValue(value) ||
          // unset attribute if
          value[0] && value[0].name ? { name: value[0].name } : undefined
        const setAction =
          _buildNewSetAttributeAction(id, deltaValue, sameForAllAttributeNames)

        if (setAction) actions.push(setAction)
      } else {
        const index = key.substring(1)
        if (newVariant.attributes) {
          const setAction = _buildSetAttributeAction(value.value, oldVariant,
            newVariant.attributes[index], sameForAllAttributeNames)
          if (setAction) actions.push(setAction)
        }
      }
  })

  return actions
}

function _buildNewSetAttributeAction (id, el, sameForAllAttributeNames) {
  const attributeName = el && el.name
  if (!attributeName) return undefined

  const action = {
    action: 'setAttribute',
    variantId: id,
    name: attributeName,
    value: el.value
  }

  if (Array.isArray(action.value))
    forEach(action.value, v => {
      if (typeof v !== 'string')
        delete v._MATCH_CRITERIA
    })

  if (Boolean(~sameForAllAttributeNames.indexOf(attributeName))) {
    Object.assign(action, { action: 'setAttributeInAllVariants' })
    delete action.variantId
  }

  return action
}

function _buildSetAttributeAction (diffedValue, oldVariant, attribute,
  sameForAllAttributeNames) {
  if (!attribute) return undefined

  const action = {
    action: 'setAttribute',
    variantId: oldVariant.id,
    name: attribute.name
  }

  if (Boolean(~sameForAllAttributeNames.indexOf(attribute.name))) {
    Object.assign(action, { action: 'setAttributeInAllVariants' })
    delete action.variantId
  }

  if (Array.isArray(diffedValue))
    action.value = diffpatcher.getDeltaValue(diffedValue, attribute.value)

  else
    // LText: value: {en: "", de: ""}
    // Enum: value: {key: "foo", label: "Foo"}
    // LEnum: value: {key: "foo", label: {en: "Foo", de: "Foo"}}
    // Money: value: {centAmount: 123, currencyCode: ""}
    // *: value: ""

    if (typeof diffedValue === 'string')
      // normal
      action.value = diffpatcher.getDeltaValue(diffedValue, attribute.value)

    else if (diffedValue.centAmount || diffedValue.currencyCode)
      // Money
      action.value = {
        centAmount: diffedValue.centAmount
          ? diffpatcher.getDeltaValue(diffedValue.centAmount)
          : attribute.value.centAmount,
        currencyCode: diffedValue.currencyCode
          ? diffpatcher.getDeltaValue(diffedValue.currencyCode)
          : attribute.value.currencyCode
      }

    else if (diffedValue.key)
      // Enum / LEnum (use only the key)
      action.value = diffpatcher.getDeltaValue(diffedValue.key)

    else if (typeof diffedValue === 'object')

      if (diffedValue.hasOwnProperty('_t') && diffedValue['_t'] === 'a') {
        // set-typed attribute
        forEach(attribute.value), v => {
          if (typeof v !== 'string')
            delete v._MATCH_CRITERIA
        }
        action.value = attribute.value

      } else {
        // LText
        const attrib = find(oldVariant.attributes, attrib =>
          attrib.name === attribute.name)

        const text = Object.assign({}, attrib ? attrib.value : null)
        forEach(diffedValue, (localValue, lang) => {
          text[lang] = diffpatcher.getDeltaValue(localValue)
        })

        action.value = text
      }

  return action
}

function _buildVariantImagesAction (diffedImages, oldVariant, newVariant) {
  const actions = []

  forEach(diffedImages, (image, key) => {

    if (REGEX_NUMBER.test(key)) {
      // New image
      if (Array.isArray(image) && image.length)
        actions.push({
          action: 'addExternalImage',
          variantId: oldVariant.id,
          image: diffpatcher.getDeltaValue(image)
        })

      else if (typeof image === 'object')

        if (image.hasOwnProperty('url') && image.url.length === 2) {
          // There is a new image, remove the old one first
          actions.push({
            action: 'removeImage',
            variantId: oldVariant.id,
            imageUrl: oldVariant.images[key].url
          })
          actions.push({
            action: 'addExternalImage',
            variantId: oldVariant.id,
            imageUrl: newVariant.images[key].url
          })

        } else if (image.hasOwnProperty('label') && image.label.length === 2)
          actions.push({
            action: 'changeImageLabel',
            variantId: oldVariant.id,
            imageUrl: oldVariant.images[key].url,
            label: diffpatcher.getDeltaValue(image.label)
          })

    } else if (REGEX_UNDERSCORE_NUMBER.test(key)) {
      const index = key.substring(1)

      if (Array.isArray(image))
        actions.push({
          action: 'removeImage',
          variantId: oldVariant.id,
          imageUrl: oldVariant.images[index].url
        })
    }
  })

  return actions
}

function _buildVariantPricesAction (diffedPrices, oldVariant, newVariant) {
  const addPriceActions = []
  const changePriceActions = []
  const removePriceActions = []

  forEach(diffedPrices, (price, key) => {

    // Remove read-only fields
    delete price.discounted

    if (REGEX_NUMBER.test(key)) {

      if (Array.isArray(price) && price.length)

        addPriceActions.push({
          action: 'addPrice', price: diffpatcher.getDeltaValue(price)
        })

      else if (Object.keys(price).length) {
        // At this point price should have changed, simply pick the new one

        const newPrice = newVariant.prices[key]
        delete newPrice.id
        delete newPrice.discounted

        changePriceActions.push({
          action: 'changePrice',
          priceId: oldVariant.prices[key].id,
          price: newPrice
        })
      }

    } else if (REGEX_UNDERSCORE_NUMBER.test(key)) {
      const index = key.substring(1)

      removePriceActions.push({
        action: 'removePrice', priceId: oldVariant.prices[index].id
      })
    }

  })

  return [ addPriceActions, changePriceActions, removePriceActions ]
}
