_ = require 'underscore'
BaseUtils = require './utils/base'

###*
 * Base Sync class, holding common functions. It should be extended for custom logic.
###
class BaseSync

  ###*
   * @constructor
   * Initialize the class with default values
  ###
  constructor: ->
    @_data = {}
    @_utils = new BaseUtils
    @_syncConfig = []

  ###*
   * Save the list of action groups
   * @param  {Array} [opts] A list of action groups for white/black-listing
   * @return {BaseSync} Chained instance of this class
  ###
  config: (opts) ->
    @_syncConfig = opts or []
    this

  ###*
   * Build all actions related to the given resource.
   * The actions mapped will be defined by overriding the `_doMapActions` function.
   * @param  {Object} new_obj The JSON object that needs to be updated.
   * @param  {Object} old_obj The JSON object that is used to find differences.
   *                          The resource id/version are read from the old_obj.
   * @return {BaseSync} Chained instance of this class
   * @throws {Error} If new_obj or old_obj are missing
  ###
  buildActions: (new_obj, old_obj) ->
    if not new_obj or not old_obj
      throw new Error 'Missing either new_obj or old_obj in order to build update actions'

    # diff 'em
    diff = @_utils.diff(old_obj, new_obj)
    @_logger.debug diff, "JSON diff for #{@constructor.name} object"
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
    @_logger.debug @_data, "Data update for #{@constructor.name} object"
    this

  ###*
   * Allow to pass a custom function to filter built actions
   * @param  {Function} fn The function used to apply the filtering
   * @return {BaseSync} Chained instance of this class
  ###
  filterActions: (fn) ->
    return this unless fn
    return this unless @_data.update
    filtered = _.filter @_data.update.actions, fn
    if _.isEmpty filtered
      @_data.update = undefined
    else
      @_data.update.actions = filtered
    this

  ###*
   * Whether it has something to update or not
   * @return {Boolean} True if there are update actions, false if not
  ###
  shouldUpdate: -> not _.isEmpty(@_data.update)

  ###*
   * Retrieve the resource id that needs to be updated (taken from old_obj)
   * @return {String} The resource id
  ###
  getUpdateId: -> @_data?.updateId

  ###*
   * Retrieve the actions that needs to be updated
   * @return {Array} The list of actions, or empty if there are none
  ###
  getUpdateActions: -> @_data?.update?.actions or []

  ###*
   * Retrieve the update payload containing the actions list and version
   * @return {Object} The update payload as JSON
  ###
  getUpdatePayload: -> @_data?.update

  ###*
   * @private
   * Whether to map or not to map actions defined in config.
   * This concept can be expressed in terms of blacklisting and whitelisting.
   * @param  {String} type The action type (see documentation for a detailed list)
   * @param  {Function} fn The function that builds the related action if whitelisted, otherwise an empty Array
   * @return {Array} The built list of actions or an empty array if blacklisted
  ###
  _mapActionOrNot: (type, fn) ->
    return fn() if _.isEmpty @_syncConfig
    found = _.find @_syncConfig, (c) -> c.type is type
    return [] unless found
    switch found.group
      when 'black' then []
      when 'white' then fn()
      else throw new Error "Action group '#{found.group}' not supported. Please use black or white."

  ###*
   * @private
   * Function to be overriden for mapping specific resource actions
   * @param  {Object} diff The JSON diff object.
   * @param  {Object} new_obj The JSON object that needs to be updated.
   * @param  {Object} old_obj The JSON object that is used to find differences.
   * @return {Array} The list of built actions
  ###
  _doMapActions: (diff, new_obj, old_obj) ->
    # => Override to map actions
    []

module.exports = BaseSync
