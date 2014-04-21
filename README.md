![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# Node.js Client

[![NPM](https://nodei.co/npm/sphere-node-client.png?downloads=true)](https://www.npmjs.org/package/sphere-node-client)

[![Build Status](https://secure.travis-ci.org/sphereio/sphere-node-client.png?branch=master)](http://travis-ci.org/sphereio/sphere-node-client) [![NPM version](https://badge.fury.io/js/sphere-node-client.png)](http://badge.fury.io/js/sphere-node-client) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-node-client/badge.png?branch=master)](https://coveralls.io/r/sphereio/sphere-node-client?branch=master) [![Dependency Status](https://david-dm.org/sphereio/sphere-node-client.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-node-client) [![devDependency Status](https://david-dm.org/sphereio/sphere-node-client/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-node-client#info=devDependencies)

[SPHERE.IO](http://sphere.io/) is the first **Platform-as-a-Service** solution for eCommerce.

This module is a standalone Node.js client for accessing the Sphere HTTP APIs.

## Table of Contents
* [Getting Started](#getting-started)
* [Documentation](#documentation)
  * [Services](#services)
  * [Types of requests](#types-of-requests)
    * [Task Queue](#task-queue)
    * [Query request](#query-request)
      * [Query all (limit 0)](#query-all-limit0)
      * [Query for modifications](#query-for-modifications)
      * [Query and process in batches](#query-and-process-in-batches)
      * [Staged products](#staged-products)
    * [Search request](#search-request)
    * [Create resource](#create-resource)
      * [Import orders](#import-orders)
    * [Update resource](#update-resource)
    * [Delete resource](#delete-resource)
  * [Types of responses](#types-of-responses)
  * [Error handling](#error-handling)
  * [Channels](#channels)
* [Examples](#examples)
* [Releasing](#releasing)
* [License](#license)


## Getting Started
Install the module with `npm install sphere-node-client`

```coffeescript
SphereClient = require 'sphere-node-client'
```

## Documentation
To start using the Sphere client you need to create an instance of the `SphereClient` by passing the credentials (and other options) in order to connect with the HTTP APIs. Project credentials can be found in the SPHERE.IO [Merchant Center](https://admin.sphere.io/) under `Developers > API clients` section.

> For a list of options to pass to the client, see [`sphere-node-connect`](https://github.com/sphereio/sphere-node-connect#documentation).

```coffeescript
client = new SphereClient
  config:
    client_id: "CLIENT_ID_HERE"
    client_secret: "CLIENT_SECRET_HERE"
    project_key: "PROJECT_KEY_HERE"
```

### Services
The `SphereClient` provides a set of Services to connect with the related API endpoints. Currently following services are supported:

- `carts`
- `categories`
- `channels`
- `comments`
- `customObjects`
- `customerGroups`
- `customers`
- `inventoryEntries`
- `messages`
- `orders`
- `productProjections`
- `productTypes`
- `products`
- `reviews`
- `shippingMethods`
- `states`
- `taxCategories`
- `zones`

### Types of requests
Requests to the HTTP API are obviously asynchronous and they all return a [`Q` promise](https://github.com/kriskowal/q).

```coffeescript
client = new SphereClient {...}

client.products.fetch()
.then (result) ->
  # a JSON object containing a statusCode and a body of either a result or a SPHERE.IO HTTP error
.fail (error) ->
  # either the request failed or was rejected (the response returned an error)
```

Current methods using promises are:

- `fetch` HTTP `GET` request
- `save` HTTP `POST` request
- `update` HTTP `POST` request (_alias for `save`_)
- `delete` HTTP `DELETE` request

#### Task Queue
To optimize processing lots of requests all together, e.g.: avoiding connection timeouts, we introduced [TaskQueue](https://github.com/sphereio/sphere-node-utils#taskqueue).

Every request is internally pushed in a queue which automatically starts resolving promises (requests) and will process concurrently some of them based on the `maxParallel` parameter. You can set this parameter by chaining the following method
- `parallel(n)` defines the number of max parallel requests to be processed by the [TaskQueue](https://github.com/sphereio/sphere-node-utils#taskqueue) (default is `20`). **If < 1 it throws an error**

```coffeescript
client = new SphereClient {...} # a TaskQueue is internally initialized at this point

# let's trigger 100 parallel requests with `Q.all`, but process them max 5 at a time
Q.all _.map [1..100], -> client.products.parallel(5).byId('123-abc').fetch()
.then (results) ->
```

> You can pass an existing `TaskQueue` object when initializing the `SphereClient`

```coffeescript
{TaskQueue} = require 'sphere-node-utils'
taskQueue = new TaskQueue maxParallel: 10
client = new SphereClient
  task: taskQueue
```

#### Query request
All resource endpoints support queries, returning a list of results of type [PagedQueryResponse](http://commercetools.de/dev/http-api.html#paged-query-response).

> Fetching and endpoint without specifying and `ID` returns a `PagedQueryResponse`

A query request can be configured with following query parameters:

- `where` ([Predicate](http://commercetools.de/dev/http-api.html#predicates))
- `sort` ([Sort](http://commercetools.de/dev/http-api.html#sorting))
- `limit` (Number)
- `offset` (Number)
- `expand` ([Expansion Path](http://commercetools.de/dev/http-api.html#reference-expansion))

The `SphereClient` helps you build those requests with following methods:

- `where(predicate)` defines a URI encoded predicate from the given string (can be set multiple times)
- `whereOperator(operator)` defines the logical operator to combine multiple where parameters
- `last(period)` defines a [time period](#query-for-modifications) for a query on the `lastModifiedAt` attribute of all resources
- `sort(path, ascending)` defines how the query result should be sorted - true (default) defines ascending where as false indicates descascending
- `page(n)` defines the page number to be requested from the complete query result (default is `1`). **If < 1 it throws an error**
- `perPage(n)` defines the number of results to return from a query (default is `100`). If set to `0` all results are returned (_more [info](https://github.com/sphereio/sphere-node-connect#paged-requests)_). **If < 0 it throws an error**
- `all()` alias for `perPage(0)`
- `expand(expansionPath)` defines a URI encoded expansion path from the given string (can be set multiple times) used for expanding references of a resource

> All these methods are chainable

```coffeescript
# example

client = new SphereClient {...}
client.products
.where('name(en="Foo")')
.where('id="1234567890"')
.whereOperator('or')
.page(3)
.perPage(25)
.sort('name', false)
.expand('masterData.staged.productType')
.expand('masterData.staged.categories[*]')
.fetch()

# HTTP request
# /{project_key}/products?where=name(en%3D%22Foo%22)%20or%20id%3D%221234567890%22&limit=25&offset=50&sort=name%20desc
```

##### Query all (limit=0)
If you want to retrieve all results of a resource, you can set the `perPage` param to `0`, or use the alias function `all()`.
In that case the results are recursively requested in chunks and returned all together once completed.

```coffeescript
client = new SphereClient {...}
client.perPage(0).fetch()
.then (result) -> # `results` is still a `PagedQueryResponse` containing all results of the query
.fail (error) ->
```

Since the request is executed recursively until all results are returned, you can **subscribe to the progress notification** in order to follow the progress

```coffeescript
client = new SphereClient {...}
client.perPage(0).fetch()
.then (result) ->
.progress (progress) ->
  # progress is an object containing the current progress percentage
  # and the value of the current results (array)
  # e.g. {percentage: 20, value: [r1, r2, r3, ...]}
  console.log "#{progress.percentage}% completed..."
.fail (error) ->
```

More info [here](https://github.com/sphereio/sphere-node-connect#paged-requests).

##### Query for modifications
If you want to retrieve only those resources that changed over a given time, you can chain the `last` functions,
that builds a query for you based on the `lastModifiedAt` attribute.

The format of the `period` parameter is a number followed by one of the following characters:
- `s` for seconds - eg. `30s`
- `m` for minutes - eg. `15m`
- `h` for hours - eg. `6h`
- `d` for days - eg. `7d`

```coffeescript
# example

client = new SphereClient {...}
client.orders.last('2h').fetch()
```

> Please be aware that `last` is just another `where` clause and thus depends on the `operator` you choose - default is `and`.

##### Query and process in batches
Sometimes you need to query all results (or some pages) of a resource and do some other operations with those infos.
That means that you would need to fetch lots of data (see [query with limit 0](#query-all-limit0)) and have it all saved in memory, which can be quite dangerous and not really performant.
To help you with that, we provide you a `process` function to work with batches.
> Batch processing allows to process a lot of resources in chunks. Using this approach you can balance between memory usage and parallelism.

The `process` function takes a function `fn` (which returns a _Promise_) and will start **fetching** resources in [pages](http://commercetools.de/dev/http-api.html#paged-query-response). On each page, the `fn` function will be executed and once it gets resolved, the next page will be fetched and so on.

```coffeescript
# Define your custom function, which returns a promise
fn = (payload) ->
  deferred = Q.defer()
  # do something with the payload
  if # something unexpected happens
    deferred.reject 'BAD'
  else # good case
    deferred.resolve 'OK'
  deferred.promise

client.products.perPage(20).process(fn)
.then (result) ->
  # here we get the total result, which is just an array of all pages accumulated
  # eg: ['OK', 'OK', 'OK'] if you have 41 to 60 products - the function fn is called three times
.fail (error) ->
  # eg: 'BAD'
```

You can pass some options as second argument:
- `accumulate` whether the results should be accumulated or not (default `true`). If not, an empty array will be returned from the resolved promise.

##### Staged products
The `ProductProjectionService` returns a representation of the products called [ProductProjection](http://commercetools.de/dev/http-api-projects-products.html#product-projection) which corresponds basically to a **catalog** or **staged** representation of a product. When using this service you can specify which projection of the product you would like to have by defining a `staged` parameter (default is `true`).

```coffeescript
# example

client = new SphereClient {...}
client.productProjections
.staged()
.fetch()

# HTTP request
# /{project_key}/products-projections?staged=true
```

#### Search request
The `ProductProjectionService` supports **searching**, returning a list of results of type [PagedQueryResponse](http://commercetools.de/dev/http-api.html#paged-query-response).

A search request can be configured with following query parameters:

- `lang` (ISO language tag)
- `text` (String)
- `filter` ([Filter](http://commercetools.de/dev/http-api-projects-products.html#search-filters))
- `filter.query` ([Filter](http://commercetools.de/dev/http-api-projects-products.html#search-filters))
- `filter.facets` ([Filter](http://commercetools.de/dev/http-api-projects-products.html#search-filters))
- `facet` ([Facet](http://commercetools.de/dev/http-api-projects-products.html#search-facets))
- `sort` ([Sort](http://commercetools.de/dev/http-api.html#sorting))
- `limit` (Number)
- `offset` (Number)
- `staged` (Boolean)

The `SphereClient` helps you build those requests with following methods:

- `lang(language)` defines the ISO language tag
- `text(text)` defines the text to analyze and search for
- `filter(filter)` defines a URI encoded string for the `filter` parameter (can be set multiple times)
- `filterByQuery(filter)` defines a URI encoded string for the `filter.query` parameter (can be set multiple times)
- `filterByFacets(filter)` defines a URI encoded string for the `filter.facets` parameter (can be set multiple times)
- `facet(facet)` defines a URI encoded string for the `facet` parameter (can be set multiple times)
- `sort(path, ascending)` defines how the query result should be sorted - true (default) defines ascending where as false indicates descascending
- `page(n)` defines the page number to be requested from the complete query result (default is `1`). **If < 1 it throws an error**
- `perPage(n)` defines the number of results to return from a query (default is `100`). If set to `0` all results are returned (_more [info](https://github.com/sphereio/sphere-node-connect#paged-requests)_). **If < 0 it throws an error**
- `staged(staged)` defines whether to search for staged or current projection (see [Staged products](#staged-products))

> All these methods are chainable

```coffeescript
# example

client = new SphereClient {...}
client.productProjections
.page(3)
.perPage(25)
.sort('createdAt')
.lang('de')
.text('T-shirt')
.filter('variants.attributes.color:red')
.filterByQuery('variants.attributes.color:red')
.filterByFacets('variants.attributes.color:red')
.facet('variants.attributes.color:red')
.search()
```

#### Create resource
All endpoints allow a resource to be created by posting a JSON `Representation` of the selected resource as a body payload.

```coffeescript
product =
  name:
    en: 'Foo'
  slug:
    en: 'foo'
  ...

client.products.save(product)
.then (result) ->
  # a JSON object containing either a result or a SPHERE.IO HTTP error
.fail (error) ->
  # either the request failed or was rejected (the response returned an error)
```

> You can use also `create` instead of `save` (it's an alias)

##### Import orders
The `OrderService` exposes a specific function to [import orders](http://commercetools.de/dev/http-api-projects-orders-import.html).
Use it as you would use the `save` function, just internally the correct API endpoint is set.

```coffeescript
client.orders.import(order)
```

#### Update resource
Updates are just a POST request to the endpoint specified by an `ID`, provided with a body payload of [Update Actions](http://commercetools.de/dev/http-api.html#partial-updates).

> The `update` method is just an alias for `save`, given the resource `ID`. If no `ID` is provided, it will try to send the request to the base resource endpoint, expecting a new resource to be created, so make sure that the **body** has the correct format (create or update).

```coffeescript
# new product
product =
  name:
    en: 'Foo'
  slug:
    en: 'foo'
  ...

# update action for product name
update =
  version: 1,
  actions: [
    {
      action: 'changeName'
      name:
        en: 'Foo'
    }
  ]

# this will try to create a new product with the correct body
# -> OK
client.products.save(product)
client.products.update(product)

# this will try to create a new product with a wrong body
# -> FAILS
client.products.save(update)
client.products.update(update)

# this will try to update a product with a correct body
# -> OK
client.products.byId('123-abc').save(update)
client.products.byId('123-abc').update(update)
```

#### Delete resource
Some endpoints (for now) allow a resource to be deleted by providing the `version` of current resource as a query parameter.

```coffeescript
# assume that we have a product
client.products.byId('123-abc').fetch()
.then (product) ->
  client.products.byId('123-abc').delete(product.version)
.then (result) ->
  # a JSON object containing either a result or a SPHERE.IO HTTP error
.fail (error) ->
  # either the request failed or was rejected (the response returned an error)
```

#### Types of responses
When a [`Q` promise](https://github.com/kriskowal/q) is resolved or rejected a JSON object is always returned and it contains a `statusCode` plus the response body or error messages

```coffeescript
# promise resolved
{
  statusCode: 200 # or other successful status codes
  body: { ... } # the body of the response coming from SPHERE.IO
}

# promise rejected
{
  statusCode: 400 # or other error codes
  message: 'Oops, something went wrong' # see http://commercetools.de/dev/http-api-errors.html
  ...
}
```

> When a promise is rejected, the response object contains a field `originalRequest`, providing some information about the related request (`endpoint`, `payload`). This is useful to better understand the error in relation with the failed request.

### Error handling
As the HTTP API [handles errors](https://github.com/sphereio/sphere-node-connect#error-handling) _gracefully_ by providing a JSON body with error codes and messages, the `SphereClient` handles that by providing an intuitive way of dealing with responses.

Since a Promise can be either resolved or rejected, the result is determined by valuating the `statusCode` of the response:
- `resolved` everything with a successful HTTP status code
- `rejected` everything else

**A rejected promise always contains a JSON object as following**

```javascript
// example
{
  "statusCode": 400,
  "message": "An error message",
  ... // other fields according to the SPHERE.IO API errors
}
```

The client application can then easily decide what to do

```coffeescript
client.products.save({})
.then (result) ->
  # we know the request was successful (e.g.: 2xx) and `result` is a JSON of a resource representation
.fail (error) ->
  # something went wrong, either an unexpected error or a HTTP API error response
  # here we can check the `statusCode` to differentiate the error
  switch error.statusCode
    when 400 then # do something
    when 500 then # do something
    ...
    else # do something else
```

### Channels

The channel service provides a convenience method to retrieve a channel with given key/role. The method ensures, that the requested channel can be returned in case it's not existing or doesn't have the requried role yet.

```coffeescript
# makes sure a channel with key 'OrderFileExport' and role 'OrderExport' exists
client.channels.ensure('OrderFileExport', 'OrderExport')
.then (result) ->
  # pretty print channel instance
  console.log _u.prettify(result.body)
.fail (error) ->
  # either the request failed or was rejected (the response returned an error)
```

## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).
More info [here](CONTRIBUTING.md)

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```

## License
Copyright (c) 2014 SPHERE.IO
Licensed under the [MIT license](LICENSE-MIT).
