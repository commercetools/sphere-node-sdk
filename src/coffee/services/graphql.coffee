Promise = require 'bluebird'
BaseService = require './base'

# Public: Define a `GraphQLService`.
class GraphQLService extends BaseService

  # Internal: {String} The HTTP endpoint for `GraphQL`
  @baseResourceEndpoint: '/graphql'

  # Public: Save a new resource defined by the `Service` by passing the payload {Object}.
  #
  # body - {Object} The payload described by the related API resource as JSON
  #
  # Throws an {Error} if `body` is missing
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  #
  # Examples
  #
  #   client.graphql.query
  #     query: """
  #       query Sphere {
  #         channels(sort: "createdAt asc", limit: 2) {
  #           total,
  #           results {
  #             createdAt, key
  #           }
  #         },
  #         products(limit: 1, skus: ["sku1444727363571_7"]) {
  #           ...StagedProduct,
  #           ...CurrentProduct
  #         }
  #       }
  #
  #       fragment Product on ProductData {
  #         skus, name(locale: "en")
  #       }
  #
  #       fragment StagedProduct on ProductQueryResult {
  #         results {
  #           id, masterData { staged { ...Product } }
  #         }
  #       }
  #
  #       fragment CurrentProduct on ProductQueryResult {
  #         results {
  #           id, masterData { current { ...Product } }
  #         }
  #       }
  #     """
  query: (body) ->
    unless body
      throw new Error "Body payload is required for querying GraphQL resources."

    endpoint = @constructor.baseResourceEndpoint
    @_save(endpoint, body)

  # Public Unsupported: Not supported by the API
  fetch: -> # noop

  # Public Unsupported: Not supported by the API
  save: -> # noop

  # Public Unsupported: Not supported by the API
  create: -> # noop

  # Public Unsupported: Not supported by the API
  update: -> # noop

  # Public Unsupported: Not supported by the API
  delete: -> # noop

  # Public Unsupported: Not supported by the API
  process: -> # noop

  # Public Unsupported: Not supported by the API
  byId: -> # noop

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

  # Public Unsupported: Not supported by the API
  where: -> # noop

  # Public Unsupported: Not supported by the API
  whereOperator: -> # noop

  # Public Unsupported: Not supported by the API
  last: -> # noop

  # Public Unsupported: Not supported by the API
  sort: -> # noop

  # Public Unsupported: Not supported by the API
  page: -> # noop

  # Public Unsupported: Not supported by the API
  perPage: -> # noop

  # Public Unsupported: Not supported by the API
  all: -> # noop

  # Public Unsupported: Not supported by the API
  expand: -> # noop

  # Public Unsupported: Not supported by the API
  byQueryString: -> # noop

module.exports = GraphQLService
