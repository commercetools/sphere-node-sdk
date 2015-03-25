_ = require 'underscore'
BaseSync = require './base-sync'
CategoryUtil = require './utils/category'

# Public: Define a `CategorySync` to provide basic methods to sync SPHERE.IO categories.
#
# Currently there are no action groups for categories.
#
# Examples
#
#   {CategorySync} = require 'sphere-node-sdk'
#   sync = new CategorySync
#   syncedActions = sync.buildActions(newCategory, existingCategory)
#   if syncedActions.shouldUpdate()
#     client.categories.byId(syncedActions.getUpdatedId())
#     .update(syncedActions.getUpdatePayload())
#   else
#     # do nothing
class CategorySync extends BaseSync

  # Public: Construct a `CategorySync` object.
  constructor: ->
    # Override base utils
    @_utils = new CategoryUtil()

  _doMapActions: (diff, new_obj, old_obj) ->
    actions = @_utils.actionsMap diff, new_obj

  _doUpdate: ->
    @_client.categories.byId(@_data.updateId).update(@_data.update)

module.exports = CategorySync
