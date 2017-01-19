_ = require 'underscore'
jsondiffpatch = require 'jsondiffpatch'

# Abstract: base utilities for sync objects
#
# This class should **not be exposed** and **must be extended** when defining a new `*Utils`.
class BaseUtils

  # Internal: Construct a `*Utils` object.
  constructor: ->
    @diffpatcher = jsondiffpatch.create
      # provide a hash function to work with objects in arrays
      objectHash: (obj) ->
        obj._MATCH_CRITERIA or obj.id or obj.name
      arrays:
        detectMove: true # detect items moved inside the array
        includeValueOnMove: false  # value of items moved is not included in deltas
      textDiff:
        # if value to diff has a bigger length, a text diffing algorithm is used
        # disable the text diffing algorithm by passing an unreachable minimum length
        # https://github.com/benjamine/jsondiffpatch/blob/master/docs/deltas.md#text-diffs
        minLength: 300

  # Internal: Compute the difference between given objects
  diff: (old_obj, new_obj) -> @diffpatcher.diff(old_obj, new_obj)

  # Internal: Patch the given object based on the delta
  patch: (obj, delta) -> @diffpatcher.patch(obj, delta)

  # Internal: Pick correct value based on delta format
  getDeltaValue: (arr, originalObject) ->
    throw new Error 'Expected array to extract delta value' unless _.isArray(arr)
    size = arr.length
    switch size
      when 1 #new
        arr[0]
      when 2 #update
        arr[1]
      when 3
        if arr[2] is 0 # delete
          undefined
        else if arr[2] is 2 # text diff
          throw new Error 'Cannot apply patch to long text diff. Missing original object.' unless originalObject
          # try to apply patch to given object based on delta value
          jsondiffpatch.patch(originalObject, arr)
        else if arr[2] is 3 # array move
          throw new Error 'Detected an array move, it should not happen as includeValueOnMove should be set to false'
        else
          throw new Error "Got unsupported number #{arr[2]} in delta value"

module.exports = BaseUtils
