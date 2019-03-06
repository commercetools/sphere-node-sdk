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

          if not (data.action.match(/^change.*$/) and _.isUndefined(data[key]))
            actions.push data

    actions

  # Private: map actions for managing custom fields
  #
  # new_obj - {Object} The new category draft
  # old_obj - {Object} The old category object
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapCustomFields: (new_obj, old_obj) ->
    actions = []
    newCustom = new_obj.custom
    oldCustom = old_obj.custom

    if newCustom and oldCustom and @referencesAreEqual(newCustom.type, oldCustom.type)
      # compare single fields one by one

      # handle new and changed fields
      _.mapObject(newCustom.fields, (val, name) =>
        if not _.isEqual val, oldCustom.fields[name]
          action =
            action: 'setCustomField'
            name: name

          if val
            action.value = JSON.parse(JSON.stringify(val))

          actions.push action
      )

      # handle removed fields
      _.mapObject(oldCustom.fields, (val, name) =>
        if not newCustom.fields[name]
          actions.push
            action: 'setCustomField'
            name: name
      )

    else if newCustom or oldCustom # or both but different customTypes
      action = if newCustom then JSON.parse(JSON.stringify(newCustom)) else {}
      action.action = 'setCustomType'
      actions.push action

    actions

  referencesAreEqual: (refA, refB) ->
    (refA.id and refA.id == refB.id) or (refA.key and refA.key == refB.key)

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
    },
    {
      action: 'setKey'
      key: 'key'
    }

  ]

