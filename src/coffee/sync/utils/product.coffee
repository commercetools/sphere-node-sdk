debug = require('debug')('sphere-sync:product')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
isNil = require 'lodash.isnil'
BaseUtils = require './base'

REGEX_NUMBER = new RegExp /^\d+$/
REGEX_UNDERSCORE_NUMBER = new RegExp /^\_\d+$/

# Private: utilities for product sync
class ProductUtils extends BaseUtils

  # Private: configure the diff function
  diff: (old_obj, new_obj) ->
    # patch 'prices' to have an identifier in order for the diff
    # to be able to match nested objects in arrays
    # e.g.: prices: [ { _MATCH_CRITERIA: x, value: {} } ]
    patchPrices = (variant) ->
      if variant.prices
        _.each variant.prices, (price, index) ->
          price._MATCH_CRITERIA = "#{index}"
          delete price.discounted # discount values should not be diffed

    # Let's compare variants with their SKU, if present.
    # Otherwise let's use the provided id.
    # If there is no SKU and no ID present, throw an error
    patchVariantId = (variant, index) ->
      if variant.sku?
        variant._MATCH_CRITERIA = variant.sku
      else if variant.id?
        variant._MATCH_CRITERIA = "#{variant.id}"
      debug 'patched id (with criteria %s) for variant: %j', variant._MATCH_CRITERIA, variant
      if not variant._MATCH_CRITERIA?
        throw new Error 'A variant must either have an ID or an SKU.'

    isEnum = (value) -> _.has(value, 'key') and _.has(value, 'label')

    # setting an lenum via the API support only to set the key of the enum.
    # Thus we delete the original value (containing key and label) and set
    # the key as value at the attribute.
    # This way (l)enum attributes are handled the same way as text attributes.
    patchEnums = (variant) ->
      if variant.attributes
        _.each variant.attributes, (attribute) ->
          if attribute.value?
            if isEnum attribute.value
              v = attribute.value.key
              delete attribute.value
              attribute.value = v
            else if _.isArray(attribute.value)
              for val, index in attribute.value
                if isEnum val
                  attribute.value[index] = val.key
                else # if we can't find key and label it isn't an (l)enum set and we can stop immediately
                  return

    patchSetLText = (variant) ->
      if variant.attributes
        _.each variant.attributes, (attribute) ->
          if attribute.value and _.isArray attribute.value
            _.each attribute.value, (v, index) ->
              v._MATCH_CRITERIA = "#{index}" unless _.isString(v)

    patchImages = (variant) ->
      if variant.images
        _.each variant.images, (image, index) ->
          image._MATCH_CRITERIA = "#{index}"

    isProduct = (obj) -> obj.masterVariant or obj.variants

    patch = (obj, arrayIndexFieldName) ->
      debug 'patching product: %j', obj

      # check if we are patching product or variant
      _allVariants = if isProduct(obj) then allVariants(obj) else [obj]
      _.each _allVariants, (variant, index) ->
        return variant unless variant?
        patchPrices variant
        patchEnums variant
        patchSetLText variant
        patchImages variant
        patchVariantId variant, index
        if index > 0
          variant[arrayIndexFieldName] = "#{index - 1}" # for variants we store the actual index in the array

    patch old_obj, '_EXISTING_ARRAY_INDEX'
    patch new_obj, '_NEW_ARRAY_INDEX'
    super old_obj, new_obj

  # Map base product actions
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapBase: (diff, old_obj) ->
    actions = []
    _.each actionsBaseList(), (item) =>
      action = @_buildBaseAttributesAction(item, diff, old_obj)
      actions.push action if action
    actions

  matchesBySkuOrKeyOrId: (variant1, variant2) ->
    @matchesBySku(variant1, variant2) or @matchesByKey(variant1, variant2) or @matchesById(variant1, variant2)

  matchesById: (variant1, variant2) ->
    variant1 and variant2 and not isNil(variant1.id) and variant1.id == variant2.id

  matchesByKey: (variant1, variant2) ->
    variant1 and variant2 and not isNil(variant1.key) and variant1.key == variant2.key

  matchesBySku: (variant1, variant2) ->
    variant1 and variant2 and not isNil(variant1.sku) and variant1.sku == variant2.sku

  # match variant against variants in list - match first by sku, then by key and then by id
  findVariantInList: (variant, variantList) ->
    return variantList.find((oldVariant) => @matchesBySku(variant, oldVariant)) or
      variantList.find((oldVariant) => @matchesByKey(variant, oldVariant)) or
      variantList.find((oldVariant) => @matchesById(variant, oldVariant)) or
      undefined # if not found, return undefined

  buildChangeMasterVariantAction: (newMasterVariant, oldMasterVariant) ->
    if newMasterVariant and oldMasterVariant and not @matchesBySkuOrKeyOrId(newMasterVariant, oldMasterVariant)
      action =
        action: 'changeMasterVariant'

      if newMasterVariant.sku
        action.sku = newMasterVariant.sku
      else if newMasterVariant.id
        action.variantId = newMasterVariant.id
      else
        throw new Error(
          'ProductSync needs at least one of "id" or "sku" to generate changeMasterVariant update action'
        )
      action

  buildRemoveVariantActions: (newVariants, oldVariants) ->
    actions = []
    oldVariants.forEach (oldVariant) =>
      if not @findVariantInList(oldVariant, newVariants)
        removeAction =
          action: 'removeVariant'

        if oldVariant.sku
          removeAction.sku = oldVariant.sku
        else if oldVariant.id
          removeAction.id = oldVariant.id
        else
          throw new Error('ProductSync does need at least one of "id" or "sku" to generate a remove action')

        actions.push(removeAction)
    actions

  buildAddVariantActions: (newVariant) ->
    addAction = _.deepClone(newVariant)
    delete addAction._NEW_ARRAY_INDEX
    delete addAction._MATCH_CRITERIA
    addAction.action = 'addVariant'
    addAction

  # Map categoryOrderHints actions
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapCategoryOrderHints: (diff, old_obj) ->
    actions = []
    actionCategoryOrderHint = {
      action: 'setCategoryOrderHint',
      key: 'categoryOrderHints'
    }

    action = @_buildBaseAttributesAction(actionCategoryOrderHint, diff, old_obj)
    if action and action.categoryOrderHints isnt undefined
      # if the the category order hint was changed from {} to not existant
      actions = Object.keys(action.categoryOrderHints)
        .map (categoryId) ->
          orderHint = action.categoryOrderHints[categoryId]
          if orderHint is null or orderHint is undefined
            orderHint = undefined
          else
            # stringify the order hint so that javascript numbers also get
            # accepted as values
            # for empty string we assume that the orderHint should be unset
            orderHint = "#{orderHint}" || undefined
          action: 'setCategoryOrderHint'
          categoryId: categoryId
          orderHint: orderHint
    actions

  # Map product references
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  # new_obj - {Object} The product to be updated
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapReferences: (diff, new_obj, old_obj) ->
    actions = []
    if diff.taxCategory
      if _.isArray diff.taxCategory
        action =
          action: 'setTaxCategory'
        action.taxCategory = @getDeltaValue diff.taxCategory
        actions.push action
      else
        action =
          action: 'setTaxCategory'
          taxCategory: new_obj.taxCategory
        actions.push action
    if diff.state
      if _.isArray diff.state.id
        action =
          action: 'transitionState'
          state:
            typeId: 'state'
            id: @getDeltaValue diff.state.id
        actions.push action
      else
        # check if there is a new state to transition to
        # otherwise no transition action is generated
        # since transitioning to an empty state is not allowed
        # this adds incosistency to some degree because for all other actions
        # passing null as the new value results in a remove action
        # which does not exist for states
        if !!new_obj.state
          action =
            action: 'transitionState'
            state:
              typeId: 'state'
              id: new_obj.state.id
          actions.push action
    actions

  # Map product categories
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapCategories: (diff) ->
    actions = []
    if diff.categories
      _.each diff.categories, (category) ->
        if _.isArray category
          action =
            category: category[0]
          if _.size(category) is 3
            # ignore pure array moves! TODO: remove when moving to new version of jsondiffpath (issue #9)
            if category[2] isnt 3
              action.action = 'removeFromCategory'
          else if _.size(category) is 1
            action.action = 'addToCategory'

          if action.action?
            actions.push action

    _.sortBy actions, (a) -> a.action is 'addToCategory'

  # Map product prices
  #
  # pricesDiff - {Object} The result of variant.prices diff from `jsondiffpatch`
  # oldVariant - {Object} The existing variant
  # newVariant - {Object} The new variant
  #
  # Returns {Array} The list of actions, or empty if there are none
  buildVariantPriceActions: (pricesDiff, oldVariant, newVariant) ->
    actions = []

    _mapVariantPrices = (price, key, old_variant, new_variant) =>
      if REGEX_NUMBER.test key
        # key is index of new price
        index = key
      else if REGEX_UNDERSCORE_NUMBER.test key
        # key is index of old price
        index = key.substring(1)
      if index
        delete price.discounted # we don't need this for mapping the action
        # if id is unchanged, we initiate a changePrice action with priceId
        if not _.isArray(price) and not price.id and old_variant.prices.length > index
          changeAction = @_buildChangePriceAction(old_variant, new_variant, index)
          actions.push changeAction if changeAction
        else
          delete price.id # delete the id so it doesn't conflict with other actions

          # build changePrice update action with price selection
          # at this point, price must be a non-empty object with unchanged price
          # selection fields to build the chanePrice action
          if (
            not _.isArray(price) and _.size(price) and
            not _.has(price, 'country') and not _.has(price, 'channel') and
            not _.has(price, 'customerGroup') and
            not _.isArray(price.value?.currencyCode) and
            old_variant.prices.length > index
          )
            changeAction = @_buildChangePriceAction(old_variant, new_variant, index)
            actions.push changeAction if changeAction
          else if _.size(price)
            removeAction = @_buildRemovePriceAction(old_variant, index)
            actions.push removeAction if removeAction
            addAction = @_buildAddPriceAction(old_variant, new_variant, index)
            actions.push addAction if addAction

    if pricesDiff
      _.each pricesDiff, (value, key) ->
        _mapVariantPrices(value, key, oldVariant, newVariant)

    actions

  # Map product attributes
  #
  # diff - {Object} The result of variant diff from `jsondiffpatch`
  # oldVariant - {Object} The existing variant
  #
  # Returns {Array} The list of actions, or empty if there are none
  buildVariantBaseAction: (diff, oldVariant) ->
    # TODO: validate ProductType between products

    []
      .concat(@_buildSkuActions(diff, oldVariant))
      .concat(@_buildVariantKeyActions(diff, oldVariant))
      .filter(Boolean)

  _buildBaseAttributesAction: (item, diff, old_obj) ->
    key = item.key
    obj = diff[key]
    if obj
      updated = {}
      if _.isArray obj
        updated = @getDeltaValue(obj)
      else
        keys = _.keys obj
        _.each keys, (k) =>
          # we pass also the value of the correspondent key of the original object
          # in case we need to patch for long text diffs
          diffed_value = obj[k]
          if _.isArray diffed_value
            value = @getDeltaValue(diffed_value, old_obj[key][k])
            updated[k] = value unless _.find value, (val) ->
              _.has(val, 'text') and val['text'] is ""   #remove empty text
          else if _.isObject(diffed_value)
            # ok this is not an array - likely the searchKeywords - removing the garbage
            if _.has(diffed_value, '_t') and diffed_value['_t'] is 'a'
              diffed_keywords = []
              diffed_keys = _.keys diffed_value
              _.each diffed_keys, (v) ->
                if REGEX_NUMBER.test(v)
                  diffed_keywords.push(diffed_value[v])
              diffed_keywords = _.flatten(diffed_keywords)
              updated[k] = diffed_keywords unless _.isEqual(diffed_keywords, old_obj[key][k])
          else
            # no idea what this is but lets just use it for updating
            updated[k] = diffed_value

      # extend with an old object only if value is an object or an array
      # if the new value is not an array or an object, use just the new value
      if old_obj[key] and (_.isArray(old_obj[key]) or _.isObject(old_obj[key]))
        # extend values of original object with possible new values of the diffed object
        # e.g.:
        #   old = {en: 'foo'}
        #   updated = {de: 'bar', en: undefined}
        #   => old = {en: undefined, de: 'bar'}
        old = _.deepClone old_obj[key]
        _.extend old, updated
      else
        old = updated
      action =
        action: item.action
      # what if updated value is null, empty string or zero?
      if updated
        action[key] = old
      else
        action[key] = undefined
      if _.isEmpty(updated) and key is "searchKeywords"
        action = undefined
    action

  _buildChangePriceAction: (old_variant, new_variant, index) ->
    new_price = new_variant.prices[index]
    if new_price
      priceId = old_variant.prices[index].id
      delete new_price._MATCH_CRITERIA
      delete new_price.id if new_price.id
      action =
        action: 'changePrice'
        priceId: priceId
        price: new_price
    action

  _buildRemovePriceAction: (variant, index) ->
    price = variant.prices[index]
    if price
      delete price._MATCH_CRITERIA
      action =
        action: 'removePrice'
        priceId: price.id
    action

  _buildAddPriceAction: (old_variant, new_variant, index) ->
    price = new_variant.prices[index]
    if price
      delete price._MATCH_CRITERIA
      action =
        action: 'addPrice'
        variantId: old_variant.id
        price: price
    action

  buildVariantImagesAction: (images, old_variant, new_variant) ->
    actions = []
    _.each images, (image, key) =>
      delete image._MATCH_CRITERIA
      if REGEX_NUMBER.test key

        if _.isArray(image) and image.length
          actions.push(@_buildAddExternalImageAction(
            old_variant,
            new_variant.images[key]
          ))

        else if _.isObject image

          if _.has(image, 'url') and image.url.length == 2
            actions.push(@_buildRemoveImageAction(
              old_variant,
              old_variant.images[key]
            ))
            actions.push(@_buildAddExternalImageAction(
              old_variant,
              new_variant.images[key]
            ))

          else if _.has(image, 'label') and
          (image.label.length == 1 or image.label.length == 2)

            actions.push(
              action: 'changeImageLabel'
              variantId: old_variant.id
              imageUrl: old_variant.images[key].url
              label: new_variant.images[key].label
            )

      else if REGEX_UNDERSCORE_NUMBER.test key
        index = key.substring(1)
        unless _.isEmpty old_variant.images
          action = @_buildRemoveImageAction old_variant, old_variant.images[index]
          actions.push action if action
    actions

  _buildAddExternalImageAction: (variant, image) ->
    if image
      delete image._MATCH_CRITERIA
      action =
        action: 'addExternalImage'
        variantId: variant.id
        image: image
    action

  _buildRemoveImageAction: (variant, image) ->
    if image
      action =
        action: 'removeImage'
        variantId: variant.id
        imageUrl: image.url
    action

  _isExistingAttribute: (oldAttribute, newAttribute) ->
    oldValue = oldAttribute.value
    newValue = newAttribute.value
    if _.isArray(oldValue) && _.isArray(newValue)
      return _.difference(oldValue, newValue).length + _.difference(newValue, oldValue).length == 0
    else
      return false

  _buildSetAttributeAction: (diffed_value, old_variant, newAttribute, sameForAllAttributeNames) ->
    return unless newAttribute
    if newAttribute
      action =
        action: 'setAttribute'
        variantId: old_variant.id
        name: newAttribute.name
      oldAttribute = _.find old_variant.attributes, (attrib) ->
        attrib.name is newAttribute.name

      if @_isExistingAttribute(oldAttribute, newAttribute)
        action = null
      else
        if _.contains(sameForAllAttributeNames, newAttribute.name)
          action.action = 'setAttributeInAllVariants'
          delete action.variantId

        if _.isArray(diffed_value)
          action.value = @getDeltaValue(diffed_value, oldAttribute.value)
        else
          # LText: value: {en: "", de: ""}
          # Money: value: {centAmount: 123, currencyCode: ""}
          # *: value: ""
          if _.isString(diffed_value)
            # normal
            action.value = @getDeltaValue(diffed_value, oldAttribute.value)
          else if diffed_value.centAmount
            # Money
            if diffed_value.centAmount
              centAmount = @getDeltaValue(diffed_value.centAmount)
            else
              centAmount = newAttribute.value.centAmount
            if diffed_value.currencyCode
              currencyCode = @getDeltaValue(diffed_value.currencyCode)
            else
              currencyCode = newAttribute.value.currencyCode
            action.value =
              centAmount: centAmount
              currencyCode: currencyCode
          else if _.isObject(diffed_value)
            if _.has(diffed_value, '_t') and diffed_value['_t'] is 'a'
              # set-typed attribute
              _.each newAttribute.value, (v) ->
                delete v._MATCH_CRITERIA unless _.isString(v)
              action.value = newAttribute.value
            else
              # LText
              text = _.extend {}, oldAttribute?.value
              _.each diffed_value, (localValue, lang) =>
                # make sure to support long text diff patching
                text[lang] = @getDeltaValue(localValue, oldAttribute.value[lang])
              action.value = text
    action

  _buildNewSetAttributeAction: (id, el, sameForAllAttributeNames) ->
    attributeName = el?.name
    return unless attributeName
    action =
      action: "setAttribute"
      variantId: id
      name: attributeName
      value: el.value

    if _.isArray(action.value)
      _.each action.value, (v) ->
        delete v._MATCH_CRITERIA unless _.isString(v)

    if _.contains(sameForAllAttributeNames, attributeName)
      action.action = 'setAttributeInAllVariants'
      delete action.variantId
    action

  buildVariantAttributesActions: (attributes, old_variant, new_variant, sameForAllAttributeNames) ->
    actions = []
    if attributes
      _.each attributes, (value, key) =>
        if REGEX_NUMBER.test key
          if _.isArray value
            deltaValue = @getDeltaValue(value)
            id = old_variant.id
            setAction = @_buildNewSetAttributeAction(id, deltaValue, sameForAllAttributeNames)
            actions.push setAction if setAction
          else
            # key is index of attribute
            index = key
            if new_variant.attributes?
              setAction = @_buildSetAttributeAction(value.value, old_variant, new_variant.attributes[index], sameForAllAttributeNames)
              actions.push setAction if setAction
        else if REGEX_UNDERSCORE_NUMBER.test key
          if _.isArray value
            # ignore pure array moves! TODO: remove when moving to new version of jsondiffpath (issue #9)
            if _.size(value) is 3 and value[2] is 3
              return
            deltaValue = @getDeltaValue(value)
            unless deltaValue
              # Taken from https://github.com/commercetools/nodejs/blob/ab8edfb41bdc7d429f20554d3d8a45ef251228f8/packages/sync-actions/src/product-actions.js#L286
              if (value[0] && value[0].name)
                deltaValue = { name: value[0].name }
              else
                deltaValue = undefined
            id = old_variant.id
            setAction = @_buildNewSetAttributeAction(id, deltaValue, sameForAllAttributeNames)
            actions.push setAction if setAction
          else
            index = key.substring(1)
            if new_variant.attributes?
              setAction = @_buildSetAttributeAction(value.value, old_variant, new_variant.attributes[index], sameForAllAttributeNames)
              actions.push setAction if setAction
    actions

  _buildSkuActions: (variantDiff, old_variant) ->
    if _.has variantDiff, 'sku'
      action =
        action: 'setSku'
        variantId: old_variant.id
        sku: @getDeltaValue(variantDiff.sku)

  _buildVariantKeyActions: (variantDiff, old_variant) ->
    if _.has variantDiff, 'key'
      action =
        action: 'setProductVariantKey'
        variantId: old_variant.id
        key: @getDeltaValue(variantDiff.key)

module.exports = ProductUtils

#################
# Product helper methods
#################

actionsBaseList = ->
  [
    {
      action: 'setKey'
      key: 'key'
    },
    {
      action: 'changeName'
      key: 'name'
    },
    {
      action: 'changeSlug'
      key: 'slug'
    },
    {
      action: 'setDescription'
      key: 'description'
    },
    {
      action: 'setMetaTitle'
      key: 'metaTitle'
    },
    {
      action: 'setMetaDescription'
      key: 'metaDescription'
    },
    {
      action: 'setMetaKeywords'
      key: 'metaKeywords'
    },
    {
      action: 'setSearchKeywords'
      key: 'searchKeywords'
    }
  ]

allVariants = (product) ->
  {masterVariant, variants} = _.defaults product,
    masterVariant: undefined
    variants: []
  [masterVariant].concat variants
