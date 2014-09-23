_ = require 'underscore'
BaseSync = require './base-sync'
OrderUtils = require './utils/order'

###*
 * Order Sync class
###
class OrderSync extends BaseSync

  constructor: ->
    # Override base utils
    @_utils = new OrderUtils

  ###*
   * @override
  ###
  _doMapActions: (diff, new_obj, old_obj) ->
    allActions = []
    allActions.push @_mapActionOrNot 'status', => @_utils.actionsMapStatusValues(diff, old_obj)
    allActions.push @_mapActionOrNot 'returnInfo', => @_utils.actionsMapReturnInfo(diff, old_obj)
    allActions.push @_mapActionOrNot 'deliveries', => @_utils.actionsMapDeliveries(diff, old_obj)
    _.flatten allActions

module.exports = OrderSync
