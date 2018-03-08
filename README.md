# ⛔ [Deprecated]

This repo has been deprecated and the code migrated to this [repo](https://github.com/commercetools/nodejs).

For migration, please follow this [guide](https://commercetools.github.io/nodejs/sdk/upgrading-from-sphere-node-sdk.html).

![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# Node.js SDK

[![NPM](https://nodei.co/npm/sphere-node-sdk.png?downloads=true)](https://www.npmjs.org/package/sphere-node-sdk)

[![NPM version](https://img.shields.io/npm/v/sphere-node-sdk.svg?style=flat)](https://www.npmjs.com/package/sphere-node-sdk) [![Build Status](https://img.shields.io/travis/sphereio/sphere-node-sdk/rewrite-2.0.svg?style=flat)](https://travis-ci.org/sphereio/sphere-node-sdk) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-node-sdk/badge.svg?branch=rewrite-2.0&service=github)](https://coveralls.io/github/sphereio/sphere-node-sdk?branch=rewrite-2.0) [![npm](https://img.shields.io/npm/l/express.svg)](https://raw.githubusercontent.com/sphereio/sphere-node-sdk/master/LICENSE-MIT)

> This is the new development branch for the `2.0` version.

See roadmap https://github.com/sphereio/sphere-node-sdk/issues/63

# Documentation

### Installation

To install the latest `alpha` version:

```
npm install --save sphere-node-sdk@">2.0.0-alpha"
```

This assumes you are using [npm](https://www.npmjs.com/) as your package manager.
If you don't, you can [access these files on npmcdn](https://npmcdn.com/sphere-node-sdk/), download them, or point your package manager to them.

Usually this library is consumed as a collection of [CommonJS](http://webpack.github.io/docs/commonjs.html) modules. These modules are what you get when you import `sphere-node-sdk` in a [Webpack](http://webpack.github.io), [Browserify](http://browserify.org/), or a Node environment.

If you don't use a module bundler, it's also fine. The `sphere-node-sdk` npm package includes precompiled production and development [UMD](https://github.com/umdjs/umd) builds in the [`dist` folder](https://npmcdn.com/sphere-node-sdk/dist/). They can be used directly without a bundler and are thus compatible with many popular JavaScript module loaders and environments. For example, you can drop a UMD build as a [`<script>` tag](https://npmcdn.com/sphere-node-sdk/dist/sphere-node-sdk.js) on the page. The UMD builds make SphereClient available as a `window.SphereClient` global variable.


## License

Licensed under the [MIT license](LICENSE-MIT).
