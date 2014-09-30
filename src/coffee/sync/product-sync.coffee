_ = require 'underscore'
BaseSync = require './base-sync'
ProductUtils = require './utils/product'

###*
 * Product Sync class
###
class ProductSync extends BaseSync

  constructor: ->
    # Override base utils
    @_utils = new ProductUtils

  ###*
   * @override
  ###
  buildActions: (new_obj, old_obj, sameForAllAttributeNames = []) ->
    @sameForAllAttributeNames = sameForAllAttributeNames
    super new_obj, old_obj

  ###*
   * @override
  ###
  _doMapActions: (diff, new_obj, old_obj) ->
    allActions = []
    allActions.push @_mapActionOrNot 'base', => @_utils.actionsMapBase(diff, old_obj)
    allActions.push @_mapActionOrNot 'references', => @_utils.actionsMapReferences(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'prices', => @_utils.actionsMapPrices(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'attributes', => @_utils.actionsMapAttributes(diff, old_obj, new_obj, @sameForAllAttributeNames)
    allActions.push @_mapActionOrNot 'images', => @_utils.actionsMapImages(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'variants', => @_utils.actionsMapVariants(diff, old_obj, new_obj)
    allActions.push @_mapActionOrNot 'metaAttributes', => @_utils.actionsMapMetaAttributes(diff, old_obj, new_obj)
    _.flatten allActions

module.exports = ProductSync
