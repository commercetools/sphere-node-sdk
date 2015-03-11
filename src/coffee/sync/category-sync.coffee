_ = require 'underscore'
BaseSync = require './base-sync'
CategoryUtil = require './utils/category'

###*
 * CategorySync Sync class
###
class CategorySync extends BaseSync

  constructor: ->
    # Override base utils
    @_utils = new CategoryUtil()

  _doMapActions: (diff, new_obj, old_obj) ->
    actions = @_utils.actionsMap diff, new_obj

  _doUpdate: ->
    @_client.categories.byId(@_data.updateId).update(@_data.update)


module.exports = CategorySync
