SPHERE CLIENT
---

```coffeescript
{SphereClient} = require 'sphere-node-sdk'
```

## Table of Contents
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
    * [Suggest request](#suggest-request)
    * [Create resource](#create-resource)
      * [Import orders](#import-orders)
      * [Ensure channels](#ensure-channels)
    * [Update resource](#update-resource)
    * [Delete resource](#delete-resource)
  * [Types of responses](#types-of-responses)
  * [Error handling](#error-handling)
    * [Error types](#error-types)
  * [Statistics](#statistics)
* [Logging & debugging](DEBUGGING.md)


## Documentation
To start using the client you need to create an instance of the `SphereClient` by passing the credentials (and other optional parameters) in order to connect with the HTTP APIs. Project credentials can be found in the SPHERE.IO [Merchant Center](https://admin.sphere.io/) under `Developers > API clients` section.

> For a list of options to pass to the client, see [SPHERE CONNECT](docs/CONNECT.md).

```coffeescript
client = new SphereClient
  config:
    client_id: "CLIENT_ID_HERE"
    client_secret: "CLIENT_SECRET_HERE"
    project_key: "PROJECT_KEY_HERE"
  task: {} # optional TaskQueue instance
  rest: {} # optional Rest instance (see SPHERE CONNECT)
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
- `productDiscounts`
- `productProjections`
- `productTypes`
- `products`
- `project`
- `reviews`
- `shippingMethods`
- `states`
- `taxCategories`
- `zones`

> Note that not all services support the common (CRUD) verbs, it depends on the resource endpoint itself. Please refer to the [HTTP API Documentation](http://dev.sphere.io/).

### Types of requests
Requests to the HTTP API are obviously asynchronous and they all return a [`Bluebird` promise](https://github.com/petkaantonov/bluebird).

```coffeescript
client = new SphereClient {...}

client.products.fetch()
.then (result) ->
  # a JSON object containing a statusCode and a body of either a result or a SPHERE.IO HTTP error
.catch (error) ->
  # either the request failed or was rejected (the response returned an error)
```

Current methods using promises are:

- `fetch` HTTP `GET` request
- `save` HTTP `POST` request
- `create` HTTP `POST` request (_alias for `save`_)
- `update` HTTP `POST` request
- `delete` HTTP `DELETE` request
- `process` HTTP `GET` request (in batches)

#### Task Queue
To optimize processing lots of requests all together, e.g.: avoiding connection timeouts, we introduced [TaskQueue](TASK-QUEUE.md).

Every request is internally pushed in a queue which automatically starts resolving promises (requests) and will process concurrently some of them based on the `maxParallel` parameter. You can set this parameter by calling the following method
- `setMaxParallel(n)` defines the number of max parallel requests to be processed by the [TaskQueue](TASK-QUEUE.md) (default is `20`). **If < 1 it throws an error**

```coffeescript
client = new SphereClient {...} # a TaskQueue is internally initialized at this point with maxParallel of 20
client.setMaxParallel 5

# let's trigger 100 parallel requests with `Promise.all`, but process them max 5 at a time
Promise.all _.map [1..100], -> client.products.byId('123-abc').fetch()
.then (results) ->
```

> You can pass an existing `TaskQueue` object when initializing the `SphereClient`

```coffeescript
{SphereClient, TaskQueue} = require 'sphere-node-sdk'
taskQueue = new TaskQueue maxParallel: 10
client = new SphereClient
  task: taskQueue
```

#### Query request
All resource endpoints support queries, returning a list of results of type [PagedQueryResponse](http://dev.sphere.io/http-api.html#paged-query-response).

> Fetching and endpoint without specifying and `ID` returns a `PagedQueryResponse`

A query request can be configured with following query parameters:

- `where` ([Predicate](http://dev.sphere.io/http-api.html#predicates))
- `sort` ([Sort](http://dev.sphere.io/http-api.html#sorting))
- `limit` (Number)
- `offset` (Number)
- `expand` ([Expansion Path](http://dev.sphere.io/http-api.html#reference-expansion))

The `SphereClient` helps you build those requests with following methods:

- `where(predicate)` defines a URI encoded predicate from the given string (can be set multiple times)
- `whereOperator(operator)` defines the logical operator to combine multiple where parameters
- `last(period)` defines a [time period](#query-for-modifications) for a query on the `lastModifiedAt` attribute of all resources
- `sort(path, ascending)` defines how the query result should be sorted - true (default) defines ascending where as false indicates descascending
- `page(n)` defines the page number to be requested from the complete query result (default is `1`). **If < 1 it throws an error**
- `perPage(n)` defines the number of results to return from a query (default is `100`). If set to `0` all results are returned (_more [info](CONNECT#paged-requests)_). **If < 0 it throws an error**
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
.catch (error) ->
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
.catch (error) ->
```

More info [here](CONNECT#paged-requests).

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

The `process` function takes a function `fn` (which returns a _Promise_) and will start **fetching** resources in [pages](http://dev.sphere.io/http-api.html#paged-query-response). On each page, the `fn` function will be executed and once it gets resolved, the next page will be fetched and so on.

```coffeescript
# Define your custom function, which returns a promise
fn = (payload) ->
  new Promise (resolve, reject) ->
    # do something with the payload
    if # something unexpected happens
      reject 'BAD'
    else # good case
      resolve 'OK'

client.products.perPage(20).process(fn)
.then (result) ->
  # here we get the total result, which is just an array of all pages accumulated
  # eg: ['OK', 'OK', 'OK'] if you have 41 to 60 products - the function fn is called three times
.catch (error) ->
  # eg: 'BAD'
```

You can pass some options as second argument:
- `accumulate` whether the results should be accumulated or not (default `true`). If not, an empty array will be returned from the resolved promise.

##### Staged products
The `ProductProjectionService` returns a representation of the products called [ProductProjection](http://dev.sphere.io/http-api-projects-products.html#product-projection) which corresponds basically to a **catalog** or **staged** representation of a product. When using this service you can specify which projection of the product you would like to have by defining a `staged` parameter (default is `true`).

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
The `ProductProjectionService` supports **searching**, returning a list of results of type [PagedQueryResponse](http://dev.sphere.io/http-api.html#paged-query-response).

A search request can be configured with following query parameters:

- `lang` (ISO language tag)
- `text` (String)
- `filter` ([Filter](http://dev.sphere.io/http-api-projects-products-search.html#search-filters))
- `filter.query` ([Filter](http://dev.sphere.io/http-api-projects-products-search.html#search-filters))
- `filter.facets` ([Filter](http://dev.sphere.io/http-api-projects-products-search.html#search-filters))
- `facet` ([Facet](http://dev.sphere.io/http-api-projects-products-search.html#search-facets))
- `sort` ([Sort](http://dev.sphere.io/http-api.html#sorting))
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
- `perPage(n)` defines the number of results to return from a query (default is `100`). If set to `0` all results are returned (_more [info](CONNECT#paged-requests)_). **If < 0 it throws an error**
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

#### Suggest request
The `ProductProjectionService` supports also a **suggest** endpoint, used for implementing an auto-completion functionality, returning a list of results of type [SuggestionResult](http://dev.sphere.io/http-api-projects-products-search.html#suggest-representations-result).


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
.catch (error) ->
  # either the request failed or was rejected (the response returned an error)
```

> You can use also `create` instead of `save` (it's an alias)

##### Import orders
The `OrderService` exposes a specific function to [import orders](http://dev.sphere.io/http-api-projects-orders-import.html).
Use it as you would use the `save` function, just internally the correct API endpoint is set.

```coffeescript
client.orders.import(order)
```

##### Ensure channels
The `ChannelService` provides a convenience method to retrieve a channel with given key/role. The method ensures, that the requested channel can be returned in case it's not existing or doesn't have the requried role yet.

```coffeescript
# makes sure a channel with key 'OrderFileExport' and role 'OrderExport' exists
client.channels.ensure('OrderFileExport', 'OrderExport')
.then (result) ->
  # pretty print channel instance
  console.log _u.prettify(result.body)
.catch (error) ->
  # either the request failed or was rejected (the response returned an error)
```

#### Update resource
Updates are just a POST request to the endpoint specified by an `ID`, provided with a body payload of [Update Actions](http://dev.sphere.io/http-api.html#partial-updates).

> The `update` method requires that the given resource `ID` is set. If no `ID` is provided it will throw an Error.

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

client.products.byId('123-abc').update(product)
.then (result) ->
  # a JSON object containing either a result or a SPHERE.IO HTTP error
.catch (error) ->
  # either the request failed or was rejected (the response returned an error)
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
.catch (error) ->
  # either the request failed or was rejected (the response returned an error)
```

#### Types of responses
When a [`Bluebird` promise](https://github.com/petkaantonov/bluebird) is resolved or rejected a JSON object is always returned and it contains a `statusCode` plus the response body or error messages

```coffeescript
# promise resolved
{
  statusCode: 200 # or other successful status codes
  body: { ... } # the body of the response coming from SPHERE.IO
}

# promise rejected
{
  statusCode: 400 # or other error codes
  message: 'Oops, something went wrong' # see http://dev.sphere.io/http-api-errors.html
  ...
}
```

> When a promise is rejected, the response object contains a field `originalRequest`, providing some information about the related request (`endpoint`, `payload`). This is useful to better understand the error in relation with the failed request.

### Error handling
As the HTTP API _gracefully_ [handles errors](CONNECT#error-handling) by providing a JSON body with error codes and messages, the `SphereClient` handles that by providing an intuitive way of dealing with responses.

Since a Promise can be either resolved or rejected, the result is determined by valuating the `statusCode` of the response:
- `resolved` everything with a successful HTTP status code
- `rejected` everything else

#### Error types
All Sphere response _errors_ are then wrapped in a custom `Error` type and returned as a rejected Promise value.
That means you can do type check as well as getting the JSON response body

```coffeescript
{ConcurrentModification} = Errors.SphereHttpError
client.products.byId(productId).update(payload)
.then (result) ->
  # we know the request was successful (e.g.: 2xx) and `result` is a JSON of a resource representation
.catch (e) ->
  # something went wrong, either an unexpected error or a HTTP API error response
  # here we can check the error type to differentiate the error
  if e instanceof ConcurrentModification
    # e.code => 409
    # e.message => 'Different version then expected'
    # e.body => {statusCode: 409, message: ...}
    # e instanceof SphereError => true
  else
    throw e
```

Following error types are exposed:
* `HttpError`
* `SphereError`
* `SphereHttpError`
  * `BadRequest`
  * `NotFound`
  * `ConcurrentModification`
  * `InternalServerError`
  * `ServiceUnavailable`

### Statistics
You can retrieve some statistics (more to come) by passing some options when creating a new `SphereClient` instance.

Current options are available:

- `includeHeaders` will include some HTTP header information in the [response](#types-of-responses), wrapped in a JSON object called `http`

```coffeescript
client = new SphereClient
  config: # credentials
  stats:
    includeHeaders: true
```

```javascript
{
  "http": { // HTTP header information
    "request": {
      "method": "GET",
      "httpVersion": "1.1",
      "uri": {
        "protocol": "https:",
        "slashes": true,
        "auth": null,
        "host": "api.sphere.io",
        "port": 443,
        "hostname": "api.sphere.io",
        "hash": null,
        "search": null,
        "query": null,
        "pathname": "/foo/bar",
        "path": "/foo/bar",
        "href": "https://api.sphere.io/foo/bar",
      },
      "header": "GET /foo/bar HTTP/1.1\r\nUser-Agent: sphere-node-sdk\r\nAuthorization: Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\r\nhost: api.sphere.io\r\naccept: application/json\r\nConnection: keep-alive\r\n\r\n",
      "headers": {
        "User-Agent": "sphere-node-sdk",
        "Authorization": "Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "accept": "application/json"
      }
    },
    "response": {
      "headers": {
        "server": "nginx",
        "date": "Wed, 01 Jan 2014 12:00:00 GMT",
        "content-type": "application/json; charset=utf-8",
        "transfer-encoding": "chunked",
        "connection": "keep-alive",
        "x-served-by": "app2.sphere.prod.commercetools.de",
        "x-served-config": "sphere-projects-ws-1.0",
        "access-control-allow-origin": "*",
        "access-control-allow-headers": "Accept, Authorization, Content-Type, Origin",
        "access-control-allow-methods": "GET, POST, DELETE, OPTIONS"
      }
    }
  }
  "statusCode": 200
  "body": { ... }
}

```
