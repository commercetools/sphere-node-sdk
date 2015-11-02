import clone from 'clone'
import BaseUtils from './base'

const REGEX_NUMBER = new RegExp(/^\d+$/)
const REGEX_UNDERSCORE_NUMBER = new RegExp(/^\_\d+$/)

export default class ProductUtils extends BaseUtils {

  diff (oldObj, newObj) {
    // Patch 'prices' to have an identifier in order for the diff
    // to be able to match nested objects in arrays
    // e.g.: prices: [ { _MATCH_CRITERIA: x, value: {} } ]
    function patchPrices (variant) {
      if (!variant) return

      if (variant.prices)
        for (let i = 0; i < variant.prices.length; i++) {
          const price = variant.prices[i]
          price._MATCH_CRITERIA = `${i}`
          delete price.discounted // discount values should not be diffed
          delete price.id // ids should not be diffed
        }
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
      if (!variant) return

      if (variant.attributes)
        for (let attribute of variant.attributes) {
          if (attribute.value)
            if (isEnum(attribute.value)) {
              const val = attribute.value.key
              delete attribute.value
              attribute.value = val
            } else if (Array.isArray(attribute.value))
              for (let i = 0; i < attribute.value.length; i++) {
                const val = attribute.value[i]
                if (isEnum(val))
                  attribute.value[i] = val.key
                // If we can't find key and label it isn't an (l)enum set
                // and we can stop immediately
                else return
              }
        }
    }

    function patchSetLText (variant) {
      if (!variant) return

      if (variant.attributes)
        for (let attribute of variant.attributes) {
          if (attribute.value && Array.isArray(attribute.value))
            for (let i = 0; i < attribute.value.length; i++) {
              const val = attribute.value[i]
              if (typeof val !== 'string')
                val._MATCH_CRITERIA = `${i}`
            }
        }
    }

    function patchImages (variant) {
      if (!variant) return

      if (variant.images)
        for (let i = 0; i < variant.images.length; i++) {
          const image = variant.images[i]
          image._MATCH_CRITERIA = `${i}`
        }
    }

    function patch (obj, arrayIndexFieldName) {
      const variants = allVariants(obj)
      for (let i = 0; i < variants.length; i++) {
        const variant = variants[i]

        patchPrices(variant)
        patchEnums(variant)
        patchSetLText(variant)
        patchImages(variant)
        patchVariantId(variant, i)
        if (i > 0)
          // for variants we store the actual index in the array
          variant[arrayIndexFieldName] = `${i - 1}`
      }
    }

    patch(oldObj, '_EXISTING_ARRAY_INDEX')
    patch(newObj, '_NEW_ARRAY_INDEX')

    return super.diff(oldObj, newObj)
  }

  actionsMapBase (diff, oldObj) {
    let actions = []
    for (let item of actionsBaseList()) {
      const action = this._buildBaseAttributesAction(item, diff, oldObj)
      if (action) actions.push(action)
    }

    return actions
  }

  actionsMapVariants (diff, oldObj, newObj) {
    const actions = []

    if (diff.variants)
      for (let i = 0; i < diff.variants.length; i++) {
        const variant = diff.variants[i]
        if (REGEX_NUMBER.test(i) && Array.isArray(variant)) {
          const newVariant = newObj.variants[i]
          const action = { action: 'addVariant' }

          if (newVariant.sku)
            action.sku = newVariant.sku

          if (newVariant.prices)
            action.prices = newVariant.prices.map(price => {
              delete price._MATCH_CRITERIA
              return price
            })

          if (newVariant.attributes)
            action.attributes = newVariant.attributes

          actions.push(action)

        } else if (REGEX_UNDERSCORE_NUMBER.test(i) && Array.isArray(variant))
          if (variant.length === 3 && variant[2] === 3)
            // only array move - do nothing
            continue
          else
            actions.push({ action: 'removeVariant', id: variant[0].id })
      }

    // TODO: make sure it's sorted with `removeVariant` first
    return actions.sort((left, right) => {
      const a = left.action
      const b = right.action
      if (a < b) return -1
      if (a > b) return 1
      return 0
    })
  }

  actionsMapReferences (diff, oldObj, newObj) {
    const actions = []
    if (diff.taxCategory)
      actions.push({
        action: 'setTaxCategory',
        taxCategory: Array.isArray(diff.taxCategory) ?
          this.getDeltaValue(diff.taxCategory) : newObj.taxCategory
      })

    return actions
  }

  actionsMapCategories (diff) {
    const actions = []

    if (diff.categories)
      for (let category of diff.categories) {
        if (Array.isArray(category)) {
          const action = { category: category[0] }

          if (category.length === 3)
            // Ignore pure array moves!
            // TODO: remove when moving to new version of
            // jsondiffpath (issue #9)
            if (category[2] !== 3)
              action.action = 'removeFromCategory'

          else if (category.length === 1)
            action.action = 'addToCategory'

          if (action.action)
            actions.push(action)
        }
      }

    // TODO: make sure it's sorted with `removeFromCategory` first
    return actions.sort((left, right) => {
      const a = left.action
      const b = right.action
      if (a < b) return -1
      if (a > b) return 1
      return 0
    })
  }


  actionsMapPrices (diff, oldObj, newObj) {
    const actions = []

    function _mapVariantPrices (price, key, oldVariant, newVariant) {
      let index
      if (REGEX_NUMBER.test(key))
        // key is index of new price
        index = key
      else if (REGEX_UNDERSCORE_NUMBER.test(key))
        // key is index of old price
        index = key.substring(1)

      if (index) {
        // we don't need this for mapping the action
        delete price.discounted

        if (price.length === 1 && price.value.length === 1 &&
          price.value.hasOwnProperty('centAmount')) {
          const changeAction = this._buildChangePriceAction(
            price.value.centAmount, oldVariant, index)

          if (changeAction) actions.push(changeAction)
        } else {
          const removeAction = this._buildRemovePriceAction(oldVariant, index)
          if (removeAction) actions.push(removeAction)

          const addAction =
            this._buildAddPriceAction(oldVariant, newVariant, index)
          if (addAction) actions.push(addAction)
        }
      }
    }

    if (diff.masterVariant) {
      const prices = diff.masterVariant.prices
      if (prices)
        for (let i = 0; i < prices.length; i++) {
          const price = prices[i]
          _mapVariantPrices(price, i,
            oldObj.masterVariant, newObj.masterVariant)
        }
    }

    if (diff.variants)
      for (let i = 0; i < diff.variants.length; i++) {
        const variant = diff.variants[i]
        if (REGEX_NUMBER.test(i) && !Array.isArray(variant)) {
          const indexOld = variant._EXISTING_ARRAY_INDEX[0]
          const indexNew = variant._NEW_ARRAY_INDEX[0]

          const prices = variant.prices
          if (prices)
            for (let i = 0; i < prices.length; i++) {
              const price = prices[i]
              const oldVariant = oldObj.variants[indexOld]
              const newVariant = newObj.variants[indexNew]
              _mapVariantPrices(price, i, oldVariant, newVariant)
            }
        }
      }

    // TODO: make sure it's sorted with `removeRemove` first
    return actions.sort((left, right) => {
      const a = left.action
      const b = right.action
      if (a < b) return -1
      if (a > b) return 1
      return 0
    })
  }

  actionsMapAttributes (diff, oldObj, newObj, sameForAllAttributeNames = []) {
    // # TODO: validate ProductType between products
    // actions = []
    // masterVariant = diff.masterVariant
    // if masterVariant
    //   skuAction = @_buildSkuActions(masterVariant, oldObj.masterVariant)
    //   actions.push(skuAction) if skuAction?
    //   attributes = masterVariant.attributes
    //   attrActions = @_buildVariantAttributesActions attributes, oldObj.masterVariant, newObj.masterVariant, sameForAllAttributeNames
    //   actions = actions.concat attrActions

    // if diff.variants
    //   _.each diff.variants, (variant, key) =>
    //     if REGEX_NUMBER.test key
    //       if not _.isArray variant
    //         index_old = variant._EXISTING_ARRAY_INDEX[0]
    //         index_new = variant._NEW_ARRAY_INDEX[0]
    //         skuAction = @_buildSkuActions(variant, oldObj.variants[index_old])
    //         actions.push(skuAction) if skuAction?
    //         attributes = variant.attributes
    //         attrActions = @_buildVariantAttributesActions attributes, oldObj.variants[index_old], newObj.variants[index_new], sameForAllAttributeNames
    //         actions = actions.concat attrActions

    // # Ensure we have each action only once per product. Use string representation of object to allow `===` on array objects
    // _.unique actions, (action) -> JSON.stringify action
  }

  actionsMapImages (diff, oldObj, newObj) {
    // actions = []
    // masterVariant = diff.masterVariant
    // if masterVariant
    //   mActions = @_buildVariantImagesAction masterVariant.images, oldObj.masterVariant, newObj.masterVariant
    //   actions = actions.concat mActions

    // if diff.variants
    //   _.each diff.variants, (variant, key) =>
    //     if REGEX_NUMBER.test key
    //       if not _.isArray variant
    //         index_old = variant._EXISTING_ARRAY_INDEX[0]
    //         index_new = variant._NEW_ARRAY_INDEX[0]
    //         if not _.isArray variant
    //           vActions = @_buildVariantImagesAction variant.images, oldObj.variants[index_old], newObj.variants[index_new]
    //           actions = actions.concat vActions

    // # this will sort the actions ranked in asc order (first 'remove' then 'add')
    // _.sortBy actions, (a) -> a.action is 'addExternalImage'
  }


  _buildBaseAttributesAction (item, diff, oldObj) {
    let action
    const key = item.key
    const obj = diff[key]

    if (obj) {
      let updated = {}
      if (Array.isArray(obj))
        updated = this.getDeltaValue(obj)
      else {
        const keys = Object.keys(obj)
        for (let k of keys) {
          // We pass also the value of the correspondent key of the
          // original object in case we need to patch for long text diffs
          updated[k] = this.getDeltaValue(obj[k], oldObj[key][k])
        }
      }

      let old
      if (oldObj[key])
        // Extend values of original object with possible new values
        // of the diffed object
        // e.g.:
        //   old = {en: 'foo'}
        //   updated = {de: 'bar', en: undefined}
        //   => old = {en: undefined, de: 'bar'}
        old = Object.assign({}, oldObj[key], updated)

      else old = updated

      action = { action: item.action }

      if (updated) action[key] = old
      else action[key] = undefined
    }

    return action
  }


  _buildChangePriceAction (centAmountDiff, variant, index) {
    let action
    const price = variant.prices[index]

    if (price) {
      delete price._MATCH_CRITERIA
      price.value.centAmount = this.getDeltaValue(centAmountDiff)
      action = {
        action: 'changePrice',
        variantId: variant.id,
        price: price
      }
    }

    return action
  }


  _buildRemovePriceAction (variant, index) {
    // price = variant.prices[index]
    // if price
    //   delete price._MATCH_CRITERIA
    //   action =
    //     action: 'removePrice'
    //     variantId: variant.id
    //     price: price
    // action
  }

  _buildAddPriceAction (oldVariant, newVariant, index) {
    // price = newVariant.prices[index]
    // if price
    //   delete price._MATCH_CRITERIA
    //   action =
    //     action: 'addPrice'
    //     variantId: oldVariant.id
    //     price: price
    // action
  }

  _buildVariantImagesAction (images, oldVariant, newVariant) {
    // actions = []
    // _.each images, (image, key) =>
    //   delete image._MATCH_CRITERIA
    //   if REGEX_NUMBER.test key
    //     unless _.isEmpty oldVariant.images
    //       action = @_buildRemoveImageAction oldVariant, oldVariant.images[key]
    //       actions.push action if action
    //     unless _.isEmpty newVariant.images
    //       action = @_buildAddExternalImageAction oldVariant, newVariant.images[key]
    //       actions.push action if action
    //   else if REGEX_UNDERSCORE_NUMBER.test key
    //     index = key.substring(1)
    //     unless _.isEmpty oldVariant.images
    //       action = @_buildRemoveImageAction oldVariant, oldVariant.images[index]
    //       actions.push action if action
    // actions
  }

  _buildAddExternalImageAction (variant, image) {
    // if image
    //   delete image._MATCH_CRITERIA
    //   action =
    //     action: 'addExternalImage'
    //     variantId: variant.id
    //     image: image
    // action
  }

  _buildRemoveImageAction (variant, image) {
    // if image
    //   action =
    //     action: 'removeImage'
    //     variantId: variant.id
    //     imageUrl: image.url
    // action
  }

  _buildSetAttributeAction (diffed_value, oldVariant, attribute, sameForAllAttributeNames) {
    // return unless attribute
    // if attribute
    //   action =
    //     action: 'setAttribute'
    //     variantId: oldVariant.id
    //     name: attribute.name

    //   if _.contains(sameForAllAttributeNames, attribute.name)
    //     action.action = 'setAttributeInAllVariants'
    //     delete action.variantId

    //   if _.isArray(diffed_value)
    //     action.value = @getDeltaValue(diffed_value, attribute.value)
    //   else
    //     # LText: value: {en: "", de: ""}
    //     # Money: value: {centAmount: 123, currencyCode: ""}
    //     # *: value: ""
    //     if _.isString(diffed_value)
    //       # normal
    //       action.value = @getDeltaValue(diffed_value, attribute.value)
    //     else if diffed_value.centAmount
    //       # Money
    //       if diffed_value.centAmount
    //         centAmount = @getDeltaValue(diffed_value.centAmount)
    //       else
    //         centAmount = attribute.value.centAmount
    //       if diffed_value.currencyCode
    //         currencyCode = @getDeltaValue(diffed_value.currencyCode)
    //       else
    //         currencyCode = attribute.value.currencyCode
    //       action.value =
    //         centAmount: centAmount
    //         currencyCode: currencyCode
    //     else if _.isObject(diffed_value)
    //       if _.has(diffed_value, '_t') and diffed_value['_t'] is 'a'
    //         # set-typed attribute
    //         _.each attribute.value, (v) ->
    //           delete v._MATCH_CRITERIA unless _.isString(v)
    //         action.value = attribute.value
    //       else
    //         # LText
    //         attrib = _.find oldVariant.attributes, (attrib) ->
    //           attrib.name is attribute.name
    //         text = _.extend {}, attrib?.value
    //         _.each diffed_value, (localValue, lang) =>
    //           text[lang] = @getDeltaValue(localValue)
    //         action.value = text
    // action
  }


  _buildNewSetAttributeAction (id, el, sameForAllAttributeNames) {
    // attributeName = el?.name
    // return unless attributeName
    // action =
    //   action: "setAttribute"
    //   variantId: id
    //   name: attributeName
    //   value: el.value

    // if _.isArray(action.value)
    //   _.each action.value, (v) ->
    //     delete v._MATCH_CRITERIA unless _.isString(v)

    // if _.contains(sameForAllAttributeNames, attributeName)
    //   action.action = 'setAttributeInAllVariants'
    //   delete action.variantId
    // action
  }

  _buildVariantAttributesActions (attributes, oldVariant, newVariant, sameForAllAttributeNames) {
    // actions = []
    // if attributes
    //   _.each attributes, (value, key) =>
    //     if REGEX_NUMBER.test key
    //       if _.isArray value
    //         deltaValue = @getDeltaValue(value)
    //         id = oldVariant.id
    //         setAction = @_buildNewSetAttributeAction(id, deltaValue, sameForAllAttributeNames)
    //         actions.push setAction if setAction
    //       else
    //         # key is index of attribute
    //         index = key
    //         if newVariant.attributes?
    //           setAction = @_buildSetAttributeAction(value.value, oldVariant, newVariant.attributes[index], sameForAllAttributeNames)
    //           actions.push setAction if setAction
    //     else if REGEX_UNDERSCORE_NUMBER.test key
    //       if _.isArray value
    //         # ignore pure array moves! TODO: remove when moving to new version of jsondiffpath (issue #9)
    //         if _.size(value) is 3 and value[2] is 3
    //           return
    //         deltaValue = @getDeltaValue(value)
    //         unless deltaValue
    //           deltaValue = value[0]
    //           delete deltaValue.value
    //         id = oldVariant.id
    //         setAction = @_buildNewSetAttributeAction(id, deltaValue, sameForAllAttributeNames)
    //         actions.push setAction if setAction
    //       else
    //         index = key.substring(1)
    //         if newVariant.attributes?
    //           setAction = @_buildSetAttributeAction(value.value, oldVariant, newVariant.attributes[index], sameForAllAttributeNames)
    //           actions.push setAction if setAction
    // actions
  }

  _buildSkuActions (variantDiff, oldVariant) {
    // if _.has variantDiff, 'sku'
    //   action =
    //     action: 'setSKU'
    //     variantId: oldVariant.id
    //     sku: @getDeltaValue(variantDiff.sku)
  }
}


function actionsBaseList () {
  return [
    { action: 'changeName', key: 'name' },
    { action: 'changeSlug', key: 'slug' },
    { action: 'setDescription', key: 'description' },
    { action: 'setMetaTitle', key: 'metaTitle' },
    { action: 'setMetaDescription', key: 'metaDescription' },
    { action: 'setMetaKeywords', key: 'metaKeywords' }
  ]
}

function allVariants (product) {
  const { masterVariant, variants } = product

  if (masterVariant && variants)
    return [masterVariant].concat(variants)

  return []
}
