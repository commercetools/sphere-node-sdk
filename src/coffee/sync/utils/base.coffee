_ = require 'underscore'
jsondiffpatch = require 'jsondiffpatch'

###
Base Utils class
###
class BaseUtils

  diff: (old_obj, new_obj) ->
    diffpatcher = jsondiffpatch.create
      # provide a hash function to work with objects in arrays
      objectHash: (obj) ->
        obj._MATCH_CRITERIA or obj.id or obj.name
      arrays:
        detectMove: true # detect items moved inside the array
        includeValueOnMove: false  # value of items moved is not included in deltas

    diffpatcher.diff(old_obj, new_obj)

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
