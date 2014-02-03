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

Current functions using promises are:

- `fetch` HTTP `GET` request
- `save` HTTP `POST` request _(Not implemented yet)_


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
