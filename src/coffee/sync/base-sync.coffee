debug = require('debug')('sphere-sync')
_ = require 'underscore'
BaseUtils = require './utils/base'

# Internal: Define a `BaseSync` to provide basic methods to sync SPHERE.IO resources.
#
# This class should **not be exposed** and **must be extended** when defining a new `*Sync`.
#
# Examples
#
#   class FooSync extends BaseSync
#     _doMapActions: (diff, new_obj, old_obj) ->
#     _doUpdate: ->
class BaseSync

  # Public: Construct a `*Sync` object.
  constructor: ->
    @_data = {}
    @_utils = new BaseUtils
    @_syncConfig = []

  # Public: Pass a list of `actions groups` in order to restrict the actions that will be built
  # Groups gives you the ability to configure the sync to include / exclude them when the actions
  # are [built]{.buildActions}. This concept can be expressed in terms of _blacklisting_ and _whitelisting_.
  #
  # See specific `*Sync` type for related list.
  #
  # options - {Array} A list of action groups for white/black-listing
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   options = [
  #     {type: 'base', group: 'black'}
  #     {type: 'prices', group: 'white'}
  #     {type: 'variants', group: 'black'}
  #   ]
  #   # => this will exclude 'base' and 'variants' mapping of actions and
  #   # include the rest (white group is actually implicit if not given)
  #
  #   sync.config(options).buildActions(...)
  config: (actionGroups) ->
    @_syncConfig = actionGroups or []
    this

  # Public: Build all actions related to the given resource by diffing the two given objects.
  # The actions mapped will be defined by overriding the `_doMapActions` function.
  #
  # new_obj - {Object} The newly object
  # old_obj - {Object} The existing object that needs to be updated (usually fetched from the API)
  #
  # Throws an {Error} if either arguments are missing
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   new_obj =
  #     name:
  #       en: 'Foo'
  #   old_obj =
  #     name:
  #       en: 'Bar'
  #   sync.buildActions(new_obj, old_obj)
  buildActions: (new_obj, old_obj) ->
    if not new_obj or not old_obj
      throw new Error 'Missing either new_obj or old_obj in order to build update actions'

    # diff 'em
    diff = @_utils.diff(old_obj, new_obj)
    debug 'JSON diff for %s Sync: %j', @constructor.name, diff
    update = undefined
    if diff
      actions = @_doMapActions(diff, new_obj, old_obj)
      if actions.length > 0
        update =
          actions: actions
          version: old_obj.version
    @_data =
      update: update
      updateId: old_obj.id
    debug 'JSON data update for %s Sync: %j', @constructor.name, @_data
    this

  # Public: Allow to pass a custom function to filter built actions
  #
  # fn - {Function} The function used to apply the filtering
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   sync.buildActions(new_obj, old_obj).filterActions (a) -> a.action is 'changeName'
  #   # => actions payload will now contain only 'changeName' action
  filterActions: (fn) ->
    return this unless fn
    return this unless @_data.update
    filtered = _.filter @_data.update.actions, fn
    if _.isEmpty filtered
      @_data.update = undefined
    else
      @_data.update.actions = filtered
    this

  # Public: Check if there is something to update or not
  #
  # Returns {Boolean} `true` if there are update actions, `false` if not
  shouldUpdate: -> not _.isEmpty(@_data.update)

  # Public: Retrieve the resource `id` that needs to be updated (`old_obj.id`)
  #
  # Returns {String} The resource `id`
  getUpdateId: -> @_data?.updateId

  # Public: Retrieve the generated actions that needs to be updated
  #
  # Returns {Array} The list of actions, or empty if there are none
  getUpdateActions: -> @_data?.update?.actions or []

  # Public: Retrieve the generated payload for the update (containing the `actions` list and `version`)
  #
  # Returns {Object} The udpate payload as JSON
  #
  # Examples
  #
  #   sync = new Sync
  #   syncedActions = sync.buildActions(new_obj, old_obj)
  #   if syncedActions.shouldUpdate()
  #     client.products().byId(syncedActions.getUpdatedId())
  #     .update(syncedActions.getUpdatePayload())
  #   else
  #     # do nothing
  getUpdatePayload: -> @_data?.update

  # Private: Whether to map or not to map actions defined in config.
  # This concept can be expressed in terms of blacklisting and whitelisting.
  _mapActionOrNot: (type, fn) ->
    return fn() if _.isEmpty @_syncConfig
    found = _.find @_syncConfig, (c) -> c.type is type
    return [] unless found
    switch found.group
      when 'black' then []
      when 'white' then fn()
      else throw new Error "Action group '#{found.group}' not supported. Please use black or white."

  # Private: Function to be overriden for mapping specific resource actions
  _doMapActions: (diff, new_obj, old_obj) ->
    # => Override to map actions
    []

module.exports = BaseSync
