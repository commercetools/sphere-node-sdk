<div style="background-color: yellow; color: black; padding: 10px; text-align: center; font-weight: bold;">
  <h2>🚨 Non-maintainable 🚨</h2>
  <p>Starting January 1, 2025, we will no longer provide maintenance or updates for the CLI ImpEx tools. After this date, this tool will no longer receive bug fixes, security patches, or new features.</p>
</div>


<img src="https://impex.europe-west1.gcp.commercetools.com/static/images/ct-logo.svg" alt="commercetools logo" width="200">

# Node.js SDK

[![NPM](https://nodei.co/npm/sphere-node-sdk.png?downloads=true)](https://www.npmjs.org/package/sphere-node-sdk)

[![NPM version](https://img.shields.io/npm/v/sphere-node-sdk.svg?style=flat)](https://www.npmjs.com/package/sphere-node-sdk) [![Build Status](https://img.shields.io/travis/sphereio/sphere-node-sdk/master.svg?style=flat)](https://travis-ci.org/sphereio/sphere-node-sdk) [![Coverage Status](https://img.shields.io/coveralls/sphereio/sphere-node-sdk/master.svg?style=flat)](https://coveralls.io/r/sphereio/sphere-node-sdk?branch=master) [![Dependency Status](https://img.shields.io/david/sphereio/sphere-node-sdk.svg?style=flat)](https://david-dm.org/sphereio/sphere-node-sdk)

[commercetools](https://commercetools.com/) is a cloud-based commerce platform.

Officially supported Node.js SDK library for working with the commercetools<span>&trade;</span> platform HTTP API, with OAuth2 support.

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
