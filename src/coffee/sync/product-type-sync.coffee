_ = require 'underscore'
BaseSync = require './base-sync'
ProductTypeUtils = require './utils/product-type'

# Public: Define a `ProductTypeSync` to provide basic methods to sync SPHERE.IO product types.
#
# Action groups for products are:
# - `base` (name, slug, description)
# - `attributes`
#
# Examples: TODO
#
#   {ProductSync} = require 'sphere-node-sdk'
#   sync = new ProductSync
#   syncedActions = sync.buildActions(newCategory, existingCategory)
#   if syncedActions.shouldUpdate()
#     client.products.byId(syncedActions.getUpdatedId())
#     .update(syncedActions.getUpdatePayload())
#   else
#     # do nothing
class ProductTypeSync extends BaseSync

  # Public: Construct a `ProductTypeSync` object.
  constructor: ->
    # Override base utils
    @_utils = new ProductTypeUtils

  _doMapActions: (diff, new_obj, old_obj) ->
    actions = @_utils.actionsForEnumValues diff, new_obj

  _doUpdate: ->
    @_client.productTypes.byId(@_data.updateId).update(@_data.update)


module.exports = ProductTypeSync
