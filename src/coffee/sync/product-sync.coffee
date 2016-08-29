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

  @actionGroups = ['base', 'references', 'prices', 'attributes', 'images', 'variants', 'categories']

  # Public: Construct a `ProductSync` object.
  constructor: ->
    # Override base utils
    @_utils = new ProductUtils

  buildActions: (new_obj, old_obj, sameForAllAttributeNames = []) ->
    @sameForAllAttributeNames = sameForAllAttributeNames
    super new_obj, old_obj

  _doMapActions: (diff, new_obj, old_obj) ->
    allActions = []
    allActions.push @_mapActionOrNot 'variants', => @_utils.actionsMapVariants(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'base', => @_utils.actionsMapBase(diff, old_obj)
    allActions.push @_mapActionOrNot 'references', => @_utils.actionsMapReferences(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'prices', => @_utils.actionsMapPrices(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'attributes', => @_utils.actionsMapAttributes(diff, old_obj, new_obj, @sameForAllAttributeNames)
    allActions.push @_mapActionOrNot 'images', => @_utils.actionsMapImages(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'categories', => @_utils.actionsMapCategories(diff)
    _.flatten allActions

module.exports = ProductSync
