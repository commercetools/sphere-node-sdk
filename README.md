![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# Node.js SDK

[![NPM](https://nodei.co/npm/sphere-node-sdk.png?downloads=true)](https://www.npmjs.org/package/sphere-node-sdk)

[![NPM version](https://img.shields.io/npm/v/sphere-node-sdk.svg?style=flat)](https://www.npmjs.com/package/sphere-node-sdk) [![Build Status](https://img.shields.io/travis/sphereio/sphere-node-sdk/master.svg?style=flat)](https://travis-ci.org/sphereio/sphere-node-sdk) [![Coverage Status](https://img.shields.io/coveralls/sphereio/sphere-node-sdk/master.svg?style=flat)](https://coveralls.io/r/sphereio/sphere-node-sdk?branch=master) [![Dependency Status](https://img.shields.io/david/sphereio/sphere-node-sdk.svg?style=flat)](https://david-dm.org/sphereio/sphere-node-sdk)

[commercetools](https://commercetools.com/) is a cloud-based commerce platform.

Officially supported Node.js SDK library for working with the commercetools<span>&trade;</span> platform HTTP API, with OAuth2 support.

> We are working on a [`v2.0`](https://github.com/sphereio/sphere-node-sdk/tree/rewrite-2.0) version, [more info](docs/MIGRATION-2.0.md) coming soon.

## Getting Started
Install the module with `npm install sphere-node-sdk`

## Documentation
Check out the [JSDoc](http://sphereio.github.io/sphere-node-sdk/).

The module exposes some libraries which can be either used alone or together

- `SphereClient` - a high-level (promise-based) client to connect to the SPHERE.IO HTTP APIs
- `Rest` - a low-level (callback-based) client to connect to the SPHERE.IO HTTP APIs
- `*Sync` - a collection of utils to build update actions


## License
Licensed under the [MIT license](LICENSE-MIT).
