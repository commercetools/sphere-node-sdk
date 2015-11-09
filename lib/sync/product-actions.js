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

function allVariants (product) {
  const { masterVariant, variants } = product

  if (masterVariant && variants)
    return [masterVariant].concat(variants)

  return []
}

/**
 * PATCH FUNCTIONS
 */

// Patch 'prices' to have an identifier in order for the diff
// to be able to match nested objects in arrays
// e.g.: prices: [ { _MATCH_CRITERIA: x, value: {} } ]
function patchPrices (variant) {
  if (!variant || !variant.prices) return

  forEach(variant.prices, (price, index) => {
    price._MATCH_CRITERIA = `${index}`
    delete price.discounted // discount values should not be diffed
    delete price.id // ids should not be diffed
  })
}

// Let's compare variants with their SKU, if present.
// Otherwise let's use the provided id.
// If there is no SKU and no ID present, throw an error
function patchVariantId (variant) {
  if (!variant) return

  if (variant.id)
    variant._MATCH_CRITERIA = `${variant.id}`
  if (variant.sku)
    variant._MATCH_CRITERIA = variant.sku

  if (!variant._MATCH_CRITERIA)
    throw new Error('A variant must either have an ID or an SKU.')
}

function isEnum (value) {
  return value.hasOwnProperty('key') && value.hasOwnProperty('label')
}

// Setting an lenum via the API support only to set the key of the enum.
// Thus we delete the original value (containing key and label) and set
// the key as value at the attribute.
// This way (l)enum attributes are handled the same way as text attributes.
function patchEnums (variant) {
  if (!variant || !variant.attributes) return

  forEach(variant.attributes, attribute => {
    if (attribute.value)
      if (isEnum(attribute.value)) {
        const val = attribute.value.key
        delete attribute.value
        attribute.value = val
      } else if (Array.isArray(attribute.value))
        forEach(attribute.value, (val, index) => {
          if (isEnum(val))
            attribute.value[index] = val.key
          // If we can't find key and label it isn't an (l)enum set
          // and we can stop immediately
          else return false
        })
  })
}

function patchSetLText (variant) {
  if (!variant || !variant.attributes) return

  forEach(variant.attributes, attribute => {
    if (attribute.value && Array.isArray(attribute.value))
      forEach(attribute.value, (val, index) => {
        if (typeof val !== 'string')
          val._MATCH_CRITERIA = `${index}`
      })
  })
}

function patchImages (variant) {
  if (!variant || !variant.images) return

  forEach(variant.images, (image, index) => {
    image._MATCH_CRITERIA = `${index}`
  })
}

function patch (obj, arrayIndexFieldName) {
  const variants = allVariants(obj)

  forEach(variants, (variant, index) => {
    patchEnums(variant)
    patchImages(variant)
    patchSetLText(variant)
    patchPrices(variant)
    patchVariantId(variant, index)
    if (index > 0)
      // for variants we store the actual index in the array
      variant[arrayIndexFieldName] = `${index - 1}`
  })
}


/**
 * SYNC FUNCTIONS
 */

export function diff (oldObj, newObj) {
  // patch(oldObj, '_EXISTING_ARRAY_INDEX')
  // patch(newObj, '_NEW_ARRAY_INDEX')

  return diffpatcher.diff(oldObj, newObj)
}

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
      const action = { action: 'addVariant' }

      if (newVariant.sku)
        action.sku = newVariant.sku

      if (newVariant.prices)
        action.prices = newVariant.prices.map(price => {
          // delete price._MATCH_CRITERIA
          return price
        })

      if (newVariant.attributes)
        action.attributes = newVariant.attributes

      addVariantActions.push(action)

    } else if (REGEX_UNDERSCORE_NUMBER.test(index) && Array.isArray(variant))
      // If array move, do nothing
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
        // TODO: remove when moving to new version of
        // jsondiffpath (issue #9)
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
        // const indexOld = variant._EXISTING_ARRAY_INDEX[0]
        // const indexNew = variant._NEW_ARRAY_INDEX[0]
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

// export function actionsMapPrices (diff, oldObj, newObj) {
//   const addPriceActions = []
//   const changePriceActions = []
//   const removePriceActions = []

//   function _mapVariantPrices (price, key, oldVariant, newVariant) {
//     let index
//     if (REGEX_NUMBER.test(key))
//       // key is index of new price
//       index = key
//     else if (REGEX_UNDERSCORE_NUMBER.test(key))
//       // key is index of old price
//       index = key.substring(1)

//     if (index) {
//       // we don't need this for mapping the action
//       delete price.discounted

//       if (price.length === 1 && price.value.length === 1 &&
//         price.value.hasOwnProperty('centAmount')) {
//         const changeAction = _buildChangePriceAction(
//           price.value.centAmount, oldVariant, index)

//         if (changeAction) changePriceActions.push(changeAction)
//       } else {
//         const removeAction = _buildRemovePriceAction(oldVariant, index)
//         if (removeAction) removePriceActions.push(removeAction)

//         const addAction =
//           _buildAddPriceAction(oldVariant, newVariant, index)
//         if (addAction) addPriceActions.push(addAction)
//       }
//     }
//   }

//   if (diff.masterVariant) {
//     const prices = diff.masterVariant.prices
//     if (prices)
//       forEach(prices, (price, index) => {
//         _mapVariantPrices(price, index,
//           oldObj.masterVariant, newObj.masterVariant)
//       })
//   }

//   if (diff.variants)
//     forEach(diff.variants, (variant, index) => {
//       if (REGEX_NUMBER.test(index) && !Array.isArray(variant)) {
//         const indexOld = variant._EXISTING_ARRAY_INDEX[0]
//         const indexNew = variant._NEW_ARRAY_INDEX[0]

//         const prices = variant.prices
//         if (prices)
//           forEach(prices, (price, index) => {
//             const oldVariant = oldObj.variants[indexOld]
//             const newVariant = newObj.variants[indexNew]
//             _mapVariantPrices(price, index, oldVariant, newVariant)
//           })
//       }
//     })

//   return changePriceActions.concat(
//     removePriceActions.concat(addPriceActions))
// }

// export function actionsMapImages (diff, oldObj, newObj) {
//   actions = []
//   masterVariant = diff.masterVariant
//   if masterVariant
//     mActions = @_buildVariantImagesAction masterVariant.images, oldObj.masterVariant, newObj.masterVariant
//     actions = actions.concat mActions

//   if diff.variants
//     _.each diff.variants, (variant, key) =>
//       if REGEX_NUMBER.test key
//         if not _.isArray variant
//           index_old = variant._EXISTING_ARRAY_INDEX[0]
//           index_new = variant._NEW_ARRAY_INDEX[0]
//           if not _.isArray variant
//             vActions = @_buildVariantImagesAction variant.images, oldObj.variants[index_old], newObj.variants[index_new]
//             actions = actions.concat vActions

//   # this will sort the actions ranked in asc order (first 'remove' then 'add')
//   _.sortBy actions, (a) -> a.action is 'addExternalImage'
// }


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


// function _buildChangePriceAction (centAmountDiff, variant, index) {
//   const price = variant.prices[index]
//   if (!price) return undefined

//   delete price._MATCH_CRITERIA
//   price.value.centAmount = diffpatcher.getDeltaValue(centAmountDiff)
//   const action = {
//     action: 'changePrice',
//     variantId: variant.id,
//     price: price
//   }
//   return action
// }


// function _buildRemovePriceAction (variant, index) {
//   price = variant.prices[index]
//   if price
//     delete price._MATCH_CRITERIA
//     action =
//       action: 'removePrice'
//       variantId: variant.id
//       price: price
//   action
// }

// function _buildAddPriceAction (oldVariant, newVariant, index) {
//   price = newVariant.prices[index]
//   if price
//     delete price._MATCH_CRITERIA
//     action =
//       action: 'addPrice'
//       variantId: oldVariant.id
//       price: price
//   action
// }

// function _buildVariantImagesAction (images, oldVariant, newVariant) {
//   actions = []
//   _.each images, (image, key) =>
//     delete image._MATCH_CRITERIA
//     if REGEX_NUMBER.test key
//       unless _.isEmpty oldVariant.images
//         action = @_buildRemoveImageAction oldVariant, oldVariant.images[key]
//         actions.push action if action
//       unless _.isEmpty newVariant.images
//         action = @_buildAddExternalImageAction oldVariant, newVariant.images[key]
//         actions.push action if action
//     else if REGEX_UNDERSCORE_NUMBER.test key
//       index = key.substring(1)
//       unless _.isEmpty oldVariant.images
//         action = @_buildRemoveImageAction oldVariant, oldVariant.images[index]
//         actions.push action if action
//   actions
// }

// function _buildAddExternalImageAction (variant, image) {
//   if image
//     delete image._MATCH_CRITERIA
//     action =
//       action: 'addExternalImage'
//       variantId: variant.id
//       image: image
//   action
// }

// function _buildRemoveImageAction (variant, image) {
//   if image
//     action =
//       action: 'removeImage'
//       variantId: variant.id
//       imageUrl: image.url
//   action
// }


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
        // TODO: remove when moving to new version of jsondiffpath (issue #9)
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
