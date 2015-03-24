![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# Node.js SDK

[![NPM](https://nodei.co/npm/sphere-node-sdk.png?downloads=true)](https://www.npmjs.org/package/sphere-node-sdk)

[![NPM version](https://img.shields.io/npm/v/sphere-node-sdk.svg?style=flat)](https://www.npmjs.com/package/sphere-node-sdk) [![Build Status](https://img.shields.io/travis/sphereio/sphere-node-sdk/master.svg?style=flat)](https://travis-ci.org/sphereio/sphere-node-sdk) [![Coverage Status](https://img.shields.io/coveralls/sphereio/sphere-node-sdk/master.svg?style=flat)](https://coveralls.io/r/sphereio/sphere-node-sdk?branch=master) [![Dependency Status](https://img.shields.io/david/sphereio/sphere-node-sdk.svg?style=flat)](https://david-dm.org/sphereio/sphere-node-sdk)

[SPHERE.IO](http://sphere.io/) is the first **Platform-as-a-Service** solution for eCommerce.

Officially supported Node.js SDK library for working with the SPHERE.IO HTTP API, with OAuth2 support.


## Getting Started
Install the module with `npm install sphere-node-sdk`

## Documentation
> This documentation is for `v1.x` and not valid for previous version - [0.8.x docs here](https://github.com/sphereio/sphere-node-sdk/blob/v0.8.1/README.md#table-of-contents).

> For migrating, check the [migration guide](docs/MIGRATION-1.0.md) to 1.x

The module exposes some libraries which can be either used alone or together

- `SphereClient` - a high-level (promise-based) client to connect to the SPHERE.IO HTTP APIs
- `Rest` - a low-level (callback-based) client to connect to the SPHERE.IO HTTP APIs
- `*Sync` - a collection of utils to build update actions

Check out the [JSDoc](#).


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
