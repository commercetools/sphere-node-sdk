_ = require('underscore')._

module.exports =

  buildQueryString: (opts = {})->
    { where, whereOperator, sort, page, perPage } = _.defaults opts,
      where: []
      whereOperator: "and"
      perPage: 100 # default API limit

    # where param
    whereParam = where.join(encodeURIComponent(" #{whereOperator} "))

    # sort param
    # TODO: add implementation
    sortParam = undefined

    # limit param
    perPage = 100 if perPage < 0

    # offset param
    page = 1 if page < 1
    offsetParam = perPage * (page - 1)

    queryString = []
    queryString.push "where=#{whereParam}" if whereParam
    queryString.push "limit=#{perPage}" if perPage >= 0
    queryString.push "offset=#{offsetParam}" if offsetParam > 0
    queryString.join('&')
