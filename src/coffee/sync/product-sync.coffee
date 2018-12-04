_ = require 'underscore'
BaseSync = require './base-sync'
ProductUtils = require './utils/product'

# Public: Define a `ProductSync` to provide basic methods to sync SPHERE.IO products.
#
# Action groups for products are:
# - `base` (name, slug, description)
# - `references` (taxCategory)
# - `prices`
# - `attributes`
# - `images`
# - `variants`
# - `categories`
#
# Examples
#
#   {ProductSync} = require 'sphere-node-sdk'
#   sync = new ProductSync
#   syncedActions = sync.buildActions(newProduct, existingProduct)
#   if syncedActions.shouldUpdate()
#     client.products.byId(syncedActions.getUpdatedId())
#     .update(syncedActions.getUpdatePayload())
#   else
#     # do nothing
class ProductSync extends BaseSync

  @actionGroups = ['base', 'references', 'prices', 'attributes', 'images', 'variants', 'categories', 'categoryOrderHints']

  # Public: Construct a `ProductSync` object.
  constructor: ->
    # Override base utils
    @_utils = new ProductUtils

  buildActions: (new_obj, old_obj, sameForAllAttributeNames = []) ->
    @sameForAllAttributeNames = sameForAllAttributeNames
    super new_obj, old_obj

  _ensureDefaultProperties: (variant) ->
    variant.images = [] unless variant.images
    variant.assets = [] unless variant.assets
    variant.prices = [] unless variant.prices
    variant.attributes = [] unless variant.attributes

  _diffVariant: (newVariant, oldVariant) ->
    # add default properties so we always compare arrays to arrays
    @_ensureDefaultProperties(newVariant)
    @_ensureDefaultProperties(oldVariant)

    actions = []
    diff = @_utils.diff(oldVariant, newVariant)

    if diff
      actions = []
        .concat @_mapActionOrNot 'attributes', => @_utils.buildVariantBaseAction(diff, oldVariant)
        .concat @_mapActionOrNot 'attributes', => @_utils.buildVariantAttributesActions(diff.attributes, oldVariant, newVariant, @sameForAllAttributeNames)
        .concat @_mapActionOrNot 'prices', => @_utils.buildVariantPriceActions(diff.prices, oldVariant, newVariant)
        .concat @_mapActionOrNot 'images', => @_utils.buildVariantImagesAction(diff.images, oldVariant, newVariant)
        .filter(Boolean)
    actions

  _postProcessVariantUpdateActions: (actions) ->
    # put addPrice actions to the end of the list (first remove price then add)
    actions = _.sortBy(actions, (a) -> a.action is 'addPrice')

    # filter out duplicate update actions - eg multiple sameForAll update actions
    actions = _.unique(actions, (a) -> JSON.stringify a)
    actions

  _doMapVariantActions: (newObj, oldObj) ->
    addVariantActions = []
    variantUpdateActions = []

    # group all variants to one list
    newVariants = [newObj.masterVariant].concat(newObj.variants or []).filter Boolean
    oldVariants = [oldObj.masterVariant].concat(oldObj.variants or []).filter Boolean

    # generate changeMasterVariantAction
    changeMasterVariantAction = @_utils.buildChangeMasterVariantAction(
      newObj.masterVariant, oldObj.masterVariant
    )

    # generate remove variant actions
    removeVariantActions = @_utils.buildRemoveVariantActions(newVariants, oldVariants)

    # generate set attribute/image/assets actions for all changed variants
    # if variant does not exist yet, create also addVariant action
    newVariants.forEach (newVariant) =>
      # find existing variant
      oldVariant = @_utils.findVariantInList(newVariant, oldVariants)

      # if variant does not exist, add it
      if not oldVariant
        addVariantActions.push(@_utils.buildAddVariantActions(newVariant))
      else
        variantUpdateActions.push.apply(variantUpdateActions, @_diffVariant(newVariant, oldVariant))

    variantUpdateActions = @_postProcessVariantUpdateActions(variantUpdateActions.filter(Boolean))

    return {
      variantUpdateActions
      addVariantActions
      removeVariantActions
      changeMasterVariantAction
    }

  _doMapActions: (diff, newObj, oldObj) ->
    # Update actions needs to be sorted and executed in particular order.
    allActions =  []

    # base product data update actions
    allActions.push @_mapActionOrNot 'base', => @_utils.actionsMapBase(diff, oldObj)
    allActions.push @_mapActionOrNot 'references', => @_utils.actionsMapReferences(diff, newObj, oldObj)
    allActions.push @_mapActionOrNot 'categories', => @_utils.actionsMapCategories(diff)
    allActions.push @_mapActionOrNot 'categoryOrderHints', => @_utils.actionsMapCategoryOrderHints(diff, oldObj)

    # generate variant related update actions
    variantActionGroups = @_doMapVariantActions(newObj, oldObj)

    # apply remove/add/changeMaster variant in the following order:
    # - remove all variants except master variant
    # - apply setAttribute/image .. update actions
    # - add new variants
    # - promote a new masterVariant
    # - remove masterVariant

    # divide removeVariant actions to two groups - one for masterVariant, second for normal variants
    partitionedRemoveActionsByMasterVariant = _.partition variantActionGroups.removeVariantActions, (action) =>
      oldObj.masterVariant and @_utils.matchesByIdOrKeyOrSku(action, oldObj.masterVariant)

    allActions.push @_mapActionOrNot 'variants', => partitionedRemoveActionsByMasterVariant[1] # normal variants
    allActions.push variantActionGroups.variantUpdateActions # already white/black listed from @_diffVariant
    allActions.push @_mapActionOrNot 'variants', => variantActionGroups.addVariantActions
    allActions.push @_mapActionOrNot 'variants', => variantActionGroups.changeMasterVariantAction
    allActions.push @_mapActionOrNot 'variants', => partitionedRemoveActionsByMasterVariant[0] # masterVariant

    _.flatten(allActions).filter(Boolean)

module.exports = ProductSync
