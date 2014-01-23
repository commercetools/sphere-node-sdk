/* ===========================================================
# sphere-node-sdk - v0.0.1
# ==============================================================
# Copyright (c) 2014 Nicola Molinari
# Licensed MIT.
*/
var ProductService, Rest, SphereClient;

Rest = require('sphere-node-connect').Rest;

ProductService = require('./services/products');

/**
 * Defines a SphereClient.
 * @class SphereClient
*/


SphereClient = (function() {
  function SphereClient(config) {
    this._rest = new Rest(config);
    this.products = new ProductService(this._rest);
  }

  return SphereClient;

})();

/**
 * The {@link SphereClient} client.
*/


module.exports = SphereClient;
