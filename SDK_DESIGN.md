SPHERE NODE.JS SDK
==================

# Usage

```coffeescript
Sphere = require('sphere-node-client')

# create client
client = Sphere.createClient credentials
or
client = new Sphere credentials

# services (using promises)
client.products.all().fetch().then()
client.products.byId('').fetch().then()

# queries (`where`, `sort`, `limit`, `offset`, `staged`)
client.products.where().sort().page().pageSize().staged()

limit = pageSize or DEFAULT_SIZE
offset = limit * (page - 1)

# reference expansion (noop on base service)
```


# Implementation

```coffeescript
class Sphere
  constructor: (config)->
    @_rest = new Rest config
    @products = new Products @_rest


class Products
  constructor: (@_rest)->
    @_projectEndpoint = '/products'

  all: ->
    @_projectEndpoint = '/products'
    this

  byId: (id)->
    @_projectEndpoint = '/products/' + id
    this

  fetch: ->
    deferred = Q.defer()
    @_rest @_projectEndpoint, (e, r, b)->
      if e
        deferred.reject e
      else
        deferred.resolve JSON.parse b
    deferred.promise

  query: ->

  search: ->
```


# References

- https://github.com/commercetools/sphere-play-sdk
- https://github.com/paymill/paymill-js
- https://github.com/joyent/node-manta
- https://github.com/paypal/rest-api-sdk-nodejs
- http://blog.parse.com/2012/10/11/the-javascript-sdk-in-node-js/
- https://www.parse.com/questions/nodejs-sdk-initialization-in-multiple-files