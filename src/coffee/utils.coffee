_ = require 'underscore'
appRoot = require('app-root-path')

module.exports =

  ###*
   * Build a query string from given parameters
   * @param {Object} opts A JSON object containing query parameters
   * @throws {Error} If perPage is not a number >= 0
   * @throws {Error} If page is not a number >= 1
   * @return {String} The built encoded query string
  ###
  buildQueryString: (opts = {}) ->
    {where, whereOperator, sort, page, perPage, expand} = _.defaults opts,
      where: []
      whereOperator: 'and'
      sort: []
      expand: []

    # where param
    whereParam = where.join(encodeURIComponent(" #{whereOperator} "))

    # limit param
    throw new Error 'PerPage (limit) must be a number >= 0' if _.isNumber(perPage) and perPage < 0
    limitParam = perPage if _.isNumber(perPage)

    # offset param
    throw new Error 'Page must be a number >= 1' if _.isNumber(page) and page < 1
    offsetParam = (perPage or 100) * (page - 1)

    queryString = []
    queryString.push "where=#{whereParam}" if whereParam
    queryString.push "limit=#{limitParam}" if _.isNumber(limitParam)
    queryString.push "offset=#{offsetParam}" if offsetParam > 0
    queryString = queryString.concat _.map(sort, (s) -> "sort=#{s}")
    queryString = queryString.concat _.map(expand, (e) -> "expand=#{e}")
    queryString.join '&'

  ###*
   * Return the value time in milliseconds based on the given type
   * @param {Number} amount The given amount
   * @param {String} type The type of time unit
   *   s -> seconds
   *   m -> minutes
   *   h -> hours
   *   d -> days
   *   w -> weeks
   * @return {Number} The milliseconds value
  ###
  getTime: (amount, type) ->
    switch type
      when 's' then amount * 1000
      when 'm' then amount * 1000 * 60
      when 'h' then amount * 1000 * 60 * 60
      when 'd' then amount * 1000 * 60 * 60 * 24
      when 'w' then amount * 1000 * 60 * 60 * 24 * 7
      else 0

  ###*
   * Returns the header string with censored Bearer key
   * @param {String} header - the header string to censor
   * @return {String} the censored header string
  ###
  _censorHeaderStr: (header) ->
    header
    .replace(/Bearer [\w-]*/, 'Bearer **********')

  ###*
   * Returns the header obj with censored Bearer key
   * @param {Object} header - the header string to censor
   * @return {Object} the censored header obj
  ###
  _censorHeaderObj: (header) ->
    header.Authorization = "Bearer **********"
    return header

  ###*
   * Returns the version of this SDK 
   * @return {Object} the version number as determined from package.json
  ###
  getVersion: () ->
    pjson = require appRoot + '/package.json'
    return pjson.version