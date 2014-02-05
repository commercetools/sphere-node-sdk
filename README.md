![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# NODE.JS Client

[![Build Status](https://secure.travis-ci.org/sphereio/sphere-node-client.png?branch=master)](http://travis-ci.org/sphereio/sphere-node-client) [![NPM version](https://badge.fury.io/js/sphere-node-client.png)](http://badge.fury.io/js/sphere-node-client) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-node-client/badge.png?branch=master)](https://coveralls.io/r/sphereio/sphere-node-client?branch=master) [![Dependency Status](https://david-dm.org/sphereio/sphere-node-client.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-node-client) [![devDependency Status](https://david-dm.org/sphereio/sphere-node-client/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-node-client#info=devDependencies)

[SPHERE.IO](http://sphere.io/) is the first **Platform-as-a-Service** solution for eCommerce.

This module is a standalone Node.js client for accessing the Sphere HTTP APIs.

## Getting Started
Install the module with `npm install sphere-node-client`

```javascript
var SphereClient = require('sphere-node-client');
```

## Documentation
To start using the Sphere client you need to create an instance of the `SphereClient` by passing the credentials (and other options) in order to connect with the HTTP APIs. Project credentials can be found in the SPHERE.IO [Merchant Center](https://admin.sphere.io/) under `Developers > API clients` section.

> For a list of options to pass to the client, see [`sphere-node-connect`](https://github.com/emmenko/sphere-node-connect#documentation).

```javascript
var sphere_client = new SphereClient({
  config: {
    client_id: "CLIENT_ID_HERE",
    client_secret: "CLIENT_SECRET_HERE",
    project_key: "PROJECT_KEY_HERE"
  }
})
```

### Services
The `SphereClient` provides a set of Services to connect with the related API endpoints. Currently following services are supported:

- `carts`
- `categories`
- `channels`
- `comments`
- `customObjects`
- `customers`
- `customerGroups`
- `inventories`
- `orders`
- `products`
- `productProjections`
- `productTypes`
- `reviews`
- `shippingMethods`
- `taxCategories`

### Types of requests
Requests to the HTTP API are obviously asynchronous and they all return a [`Q` promise](https://github.com/kriskowal/q).

```javascript
var sphere_client = new SphereClient({...})

sphere_client.products.fetch()
.then(function(result){
  // a JSON object containing either a result or a SPHERE.IO HTTP error
})
.fail(function(error){
  // either the request failed or was rejected (the response returned an error)
})
```

Current methods using promises are:

- `fetch` HTTP `GET` request
- `save` HTTP `POST` request _(Not implemented yet)_


#### Query request
All resource endpoints support queries, returning a list of results of type [PagedQueryResponse](http://commercetools.de/dev/http-api.html#paged-query-response).

> Fetching and endpoint without specifying and `ID` returns a `PagedQueryResponse`

A query request can be configured with following query parameters:

- `where` ([Predicate](http://commercetools.de/dev/http-api.html#predicates))
- `sort` ([Sort](http://commercetools.de/dev/http-api.html#sorting))
- `limit` (Number)
- `offset` (Number)

The `SphereClient` helps you build those requests with following methods:

- `where(predicate)` defines a URI encoded predicate from the given string (can be set multiple times)
- `whereOperator(operator)` defines the logical operator to combine multiple where parameters
- `sort` _TBD_
- `page(n)` defines the page number to be requested from the complete query result (default is `1`)
- `perPage(n)` defines the number of results to return from a query (default is `100`). If set to `0` all results are returned

> All these methods are chainable

```javascript
// example

var sphere_client = new SphereClient({...})
sphere_client.products
  .where('name(en="Foo")')
  .where('id="1234567890"')
  .whereOperator('or')
  .page(3)
  .perPage(25)
  .fetch()

// HTTP request
// /{project_key}/products?where=name(en%3D%22Foo%22)%20or%20id%3D%221234567890%22&limit=25&offset=50
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
