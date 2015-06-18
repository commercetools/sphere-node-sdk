_ = require 'underscore'
BaseUtils = require './base'

# Private: utilities for category sync
class CategoryUtils extends BaseUtils

  # Private: map base category actions
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # new_obj - {Object} The category to be updated
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMap: (diff, new_obj) ->
    actions = []
    if diff
      _.each actionsList(), (item) =>
        key = item.key
        obj = diff[key]
        if obj
          data =
            action: item.action
          if _.isArray obj
            data[key] = @getDeltaValue(obj)
          else
            data[key] = new_obj[key]

          actions.push data
    actions

module.exports = CategoryUtils

#################
# Category helper methods
#################

actionsList = ->
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
      action: 'setDescription'
      key: 'description'
    },
    {
      action: 'changeParent'
      key: 'parent'
    },
    {
      action: 'changeOrderHint'
      key: 'orderHint'
    },
    {
      action: 'setExternalId'
      key: 'externalId'
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
    }

  ]

