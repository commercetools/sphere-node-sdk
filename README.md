![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# Node.js SDK

[![NPM](https://nodei.co/npm/sphere-node-sdk.png?downloads=true)](https://www.npmjs.org/package/sphere-node-sdk)

[![Build Status](https://secure.travis-ci.org/sphereio/sphere-node-sdk.png?branch=master)](http://travis-ci.org/sphereio/sphere-node-sdk) [![NPM version](https://badge.fury.io/js/sphere-node-sdk.png)](http://badge.fury.io/js/sphere-node-sdk) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-node-sdk/badge.png?branch=master)](https://coveralls.io/r/sphereio/sphere-node-sdk?branch=master) [![Dependency Status](https://david-dm.org/sphereio/sphere-node-sdk.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-node-sdk) [![devDependency Status](https://david-dm.org/sphereio/sphere-node-sdk/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/sphere-node-sdk#info=devDependencies)

[SPHERE.IO](http://sphere.io/) is the first **Platform-as-a-Service** solution for eCommerce.

Officially supported Node.js SDK library for working with the SPHERE.IO HTTP API, with OAuth2 support.


## Getting Started
Install the module with `npm install sphere-node-sdk`

## Documentation
> This documentation is for node-sdk 1.x and not valid for previous version - [0.8.x docs here](https://github.com/sphereio/sphere-node-sdk/blob/v0.8.1/README.md#table-of-contents).

> For migrating, check the [migration guide](docs/MIGRATION-1.0.md) to 1.x

The module exposes some libraries which can be either used alone or together

* [CLIENT](docs/CLIENT.md) - a high-level (promise-based) client to connect to the SPHERE.IO HTTP APIs
* [CONNECT](docs/CONNECT.md) - a low-level (callback-based) client to connect to the SPHERE.IO HTTP APIs
* [SYNC](docs/SYNC.md) - a collection of utils to build update actions

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
