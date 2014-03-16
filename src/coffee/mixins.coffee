Q = require 'q'
_ = require 'underscore'
_.mixin percentage: (x, tot) -> Math.round(x * 100 / tot)

# TODO: move to `sphere-node-utils` ?
module.exports =

  ###*
   * Process promises in batches using a recursive function.
   * Supports promise subscription of progress notifications.
   *
   * @param {Array} [promises] A list of promises
   * @param {Number} [limit] Number of parallel requests to be sent in batch
   *
   * @example
   * 1) simple batch process
   *   allPromises = [p1, p2, p3, ...]
   *   batch(allPromises)
   *   .then (results) ->
   *   .fail (error) ->
   *
   * 2) batch process with custom limit
   *   allPromises = [p1, p2, p3, ...]
   *   batch(allPromises, 30)
   *   .then (results) ->
   *   .fail (error) ->
   *
   * 3) batch process with notification subscription
   *   allPromises = [p1, p2, p3, ...]
   *   batch(allPromises)
   *   .then (results) ->
   *   .progress (progress) -> console.log "#{progress.percentage}% processed"
   *   .fail (error) ->
  ###
  batch: (promises, limit = 50) ->
    # TODO: define a hard limit?
    deferred = Q.defer()
    totalPromises = _.size(promises)

    _processInBatches = (currentPromises, limit, accumulator = []) ->
      current = _.take currentPromises, limit
      # TODO: use `allSettled` ?
      Q.all(current).then (results) ->
        # notify any handler registered to the promise with
        # the progress percentage and the current results
        deferred.notify
          percentage: _.percentage(_.size(currentPromises), totalPromises)
          value: results

        allResults = _.union accumulator, results
        if _.size(current) < limit
          # return if there are no more batches
          deferred.resolve allResults
        else
          _processInBatches _.tail(currentPromises, limit), limit, allResults
      .fail (err) -> deferred.reject err
    _processInBatches(promises, limit)

    deferred.promise
