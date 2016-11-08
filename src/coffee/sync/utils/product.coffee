debug = require('debug')('sphere-sync:product')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
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
          delete price.id # ids should not be diffed

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

    patch = (obj, arrayIndexFieldName) ->
      debug 'patching product: %j', obj
      _allVariants = allVariants(obj)
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

  # Private: map base product actions
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapBase: (diff, old_obj) ->
    actions = []
    _.each actionsBaseList(), (item) =>
      action = @_buildBaseAttributesAction(item, diff, old_obj)
      if action?.action is "setCategoryOrderHint"
        # if the the category order hint was changed from {} to not existant
        if action.categoryOrderHints is undefined
          return
        orderHintActions = Object.keys(action.categoryOrderHints)
          .map((categoryId) ->
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
          )
        actions = actions.concat(orderHintActions)
      else
        actions.push action if action
    actions

  # Private: map product variants
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  # new_obj - {Object} The product to be updated
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapVariants: (diff, old_obj, new_obj) ->
    actions = []
    if diff.variants
      _.each diff.variants, (variant, key) ->
        if REGEX_NUMBER.test(key) and _.isArray(variant)
          newVariant = new_obj.variants[key]
          action =
            action: 'addVariant'
          action.sku = newVariant.sku if newVariant.sku
          action.prices = _.map(newVariant.prices, (price) ->
            delete price._MATCH_CRITERIA
            price
          ) if newVariant.prices
          action.attributes = newVariant.attributes if newVariant.attributes
          actions.push action
        else if REGEX_UNDERSCORE_NUMBER.test(key) and _.isArray(variant)
          if _.size(variant) is 3 and variant[2] is 3
             # only array move - do nothing
          else
            action =
              action: 'removeVariant'
              id: variant[0].id
            actions.push action

    _.sortBy actions, (a) -> a.action is 'addVariant'

  # Private: map product references
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  # new_obj - {Object} The product to be updated
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapReferences: (diff, old_obj, new_obj) ->
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

  # Private: map product categories
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

  # Private: map product prices
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  # new_obj - {Object} The product to be updated
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapPrices: (diff, old_obj, new_obj) ->
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
        if _.size(price) is 1 and _.size(price.value) is 1 and _.has(price.value, 'centAmount')
          changeAction = @_buildChangePriceAction(price.value.centAmount, old_variant, index)
          actions.push changeAction if changeAction
        else
          removeAction = @_buildRemovePriceAction(old_variant, index)
          actions.push removeAction if removeAction
          addAction = @_buildAddPriceAction(old_variant, new_variant, index)
          actions.push addAction if addAction

    if diff.masterVariant
      prices = diff.masterVariant.prices
      if prices
        _.each prices, (value, key) ->
          _mapVariantPrices(value, key, old_obj.masterVariant, new_obj.masterVariant)

    if diff.variants
      _.each diff.variants, (variant, key) =>
        if REGEX_NUMBER.test key
          if not _.isArray variant
            index_old = variant._EXISTING_ARRAY_INDEX[0]
            index_new = variant._NEW_ARRAY_INDEX[0]
            if not _.isArray variant
              prices = variant.prices
              if prices
                _.each prices, (value, key) ->
                  oldVariant = old_obj.variants[index_old]
                  newVariant = new_obj.variants[index_new]
                  _mapVariantPrices(value, key, oldVariant, newVariant)

    # this will sort the actions ranked in asc order (first 'remove' then 'add')
    _.sortBy actions, (a) -> a.action is 'addPrice'

  # Private: map product attributes
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  # new_obj - {Object} The product to be updated
  # sameForAllAttributeNames - {Array} A list of names of `SameForAll` attributes
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapAttributes: (diff, old_obj, new_obj, sameForAllAttributeNames = []) ->
    # TODO: validate ProductType between products
    actions = []
    masterVariant = diff.masterVariant
    if masterVariant
      skuAction = @_buildSkuActions(masterVariant, old_obj.masterVariant)
      actions.push(skuAction) if skuAction?
      attributes = masterVariant.attributes
      attrActions = @_buildVariantAttributesActions attributes, old_obj.masterVariant, new_obj.masterVariant, sameForAllAttributeNames
      actions = actions.concat attrActions

    if diff.variants
      _.each diff.variants, (variant, key) =>
        if REGEX_NUMBER.test key
          if not _.isArray variant
            index_old = variant._EXISTING_ARRAY_INDEX[0]
            index_new = variant._NEW_ARRAY_INDEX[0]
            skuAction = @_buildSkuActions(variant, old_obj.variants[index_old])
            actions.push(skuAction) if skuAction?
            attributes = variant.attributes
            attrActions = @_buildVariantAttributesActions attributes, old_obj.variants[index_old], new_obj.variants[index_new], sameForAllAttributeNames
            actions = actions.concat attrActions

    # Ensure we have each action only once per product. Use string representation of object to allow `===` on array objects
    _.unique actions, (action) -> JSON.stringify action

  # Private: map product images
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing product
  # new_obj - {Object} The product to be updated
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapImages: (diff, old_obj, new_obj) ->
    actions = []
    masterVariant = diff.masterVariant
    if masterVariant
      mActions = @_buildVariantImagesAction masterVariant.images, old_obj.masterVariant, new_obj.masterVariant
      actions = actions.concat mActions

    if diff.variants
      _.each diff.variants, (variant, key) =>
        if REGEX_NUMBER.test key
          if not _.isArray variant
            index_old = variant._EXISTING_ARRAY_INDEX[0]
            index_new = variant._NEW_ARRAY_INDEX[0]
            if not _.isArray variant
              vActions = @_buildVariantImagesAction variant.images, old_obj.variants[index_old], new_obj.variants[index_new]
              actions = actions.concat vActions

    # this will sort the actions ranked in asc order (first 'remove' then 'add')
    _.sortBy actions, (a) -> a.action is 'addExternalImage'

  # Private: map price custom type and fields
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing inventory
  # new_obj - {Object} The new inventory
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapPriceCustom: (diff, old_obj, new_obj) =>
    actions = []
    if !diff.custom
      return actions

    # if custom is new in itself it's placed in an array we need to unwrap
    if diff.custom.type
      diff.custom.type = diff.custom.type[0] || diff.custom.type
    else
      diff.custom.type = {}

    if diff.custom.type.id || diff.custom.priceId || diff.custom.staged
      actions.push
        action: 'setProductPriceCustomType'
        type:
          typeId: 'type',
          id: @getNewDiffValue(diff.custom.type.id, new_obj.custom.type.id)
        priceId: @getNewDiffValue(diff.custom.priceId, new_obj.custom.priceId)
        staged: @getNewDiffValue(diff.custom.staged, new_obj.custom.staged)
        fields: @getNewDiffValue(diff.custom.fields, new_obj.custom.fields)
    else if diff.custom.fields
      customFieldsActions = Object.keys(diff.custom.fields).map((name) =>
        {
          action: 'setProductPriceCustomField'
          name: name
          value: @getNewDiffValue(diff.custom.fields[name], new_obj.custom.fields[name])
        }
      )
      actions = actions.concat(customFieldsActions)
    actions

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

      if old_obj[key]
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
      if updated
        action[key] = old
      else
        action[key] = undefined
      if _.isEmpty(updated) and key is "searchKeywords"
        action = undefined
    action

  _buildChangePriceAction: (centAmountDiff, variant, index) ->
    price = variant.prices[index]
    if price
      delete price._MATCH_CRITERIA
      price.value.centAmount = @getDeltaValue(centAmountDiff)
      action =
        action: 'changePrice'
        variantId: variant.id
        price: price
    action

  _buildRemovePriceAction: (variant, index) ->
    price = variant.prices[index]
    if price
      delete price._MATCH_CRITERIA
      action =
        action: 'removePrice'
        variantId: variant.id
        price: price
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

  _buildVariantImagesAction: (images, old_variant, new_variant) ->
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

  _buildSetAttributeAction: (diffed_value, old_variant, attribute, sameForAllAttributeNames) ->
    return unless attribute
    if attribute
      action =
        action: 'setAttribute'
        variantId: old_variant.id
        name: attribute.name

      if _.contains(sameForAllAttributeNames, attribute.name)
        action.action = 'setAttributeInAllVariants'
        delete action.variantId

      if _.isArray(diffed_value)
        action.value = @getDeltaValue(diffed_value, attribute.value)
      else
        # LText: value: {en: "", de: ""}
        # Money: value: {centAmount: 123, currencyCode: ""}
        # *: value: ""
        if _.isString(diffed_value)
          # normal
          action.value = @getDeltaValue(diffed_value, attribute.value)
        else if diffed_value.centAmount
          # Money
          if diffed_value.centAmount
            centAmount = @getDeltaValue(diffed_value.centAmount)
          else
            centAmount = attribute.value.centAmount
          if diffed_value.currencyCode
            currencyCode = @getDeltaValue(diffed_value.currencyCode)
          else
            currencyCode = attribute.value.currencyCode
          action.value =
            centAmount: centAmount
            currencyCode: currencyCode
        else if _.isObject(diffed_value)
          if _.has(diffed_value, '_t') and diffed_value['_t'] is 'a'
            # set-typed attribute
            _.each attribute.value, (v) ->
              delete v._MATCH_CRITERIA unless _.isString(v)
            action.value = attribute.value
          else
            # LText
            attrib = _.find old_variant.attributes, (attrib) ->
              attrib.name is attribute.name
            text = _.extend {}, attrib?.value
            _.each diffed_value, (localValue, lang) =>
              # make sure to support long text diff patching
              text[lang] = @getDeltaValue(localValue, attrib.value[lang])
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

  _buildVariantAttributesActions: (attributes, old_variant, new_variant, sameForAllAttributeNames) ->
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
              deltaValue = value[0]
              delete deltaValue.value
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

module.exports = ProductUtils

#################
# Product helper methods
#################

actionsBaseList = ->
  [
    {
      action: 'changeName'
      key: 'name'
    },
    {
      action: 'changeSlug'
      key: 'slug'
    },
    {
      action: 'setCategoryOrderHint',
      key: 'categoryOrderHints'
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
