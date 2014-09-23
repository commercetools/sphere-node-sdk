_ = require 'underscore'
jsondiffpatch = require 'jsondiffpatch'

###
Base Utils class
###
class BaseUtils

  diff: (old_obj, new_obj) ->
    # provide a hash function to work with objects in arrays
    jsondiffpatch.config.objectHash = (obj) -> obj._MATCH_CRITERIA or obj.id or obj.name
    jsondiffpatch.diff(old_obj, new_obj)

  getDeltaValue: (arr) ->
    size = arr.length
    switch size
      when 1 #new
        arr[0]
      when 2 #update
        arr[1]
      when 3 #delete
        undefined

###
Exports object
###
module.exports = BaseUtils
