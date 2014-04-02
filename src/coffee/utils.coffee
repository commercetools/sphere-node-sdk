_ = require 'underscore'

module.exports =

  buildQueryString: (opts = {}) ->
    { where, whereOperator, sort, page, perPage } = _.defaults opts,
      where: []
      whereOperator: 'and'
      sort: []

    # where param
    whereParam = where.join(encodeURIComponent(" #{whereOperator} "))

    # limit param
    throw new Error 'PerPage (limit) must be a number >= 0' if _.isNumber(perPage) and perPage < 0
    limitParam = perPage if _.isNumber(perPage)

    # offset param
    throw new Error 'Page must be a number >= 1' if page < 1
    offsetParam = (perPage or 100) * (page - 1)

    queryString = []
    queryString.push "where=#{whereParam}" if whereParam
    queryString.push "limit=#{limitParam}" if _.isNumber(limitParam)
    queryString.push "offset=#{offsetParam}" if offsetParam > 0
    queryString = queryString.concat _.map(sort, (s) -> "sort=#{s}")
    queryString.join '&'
