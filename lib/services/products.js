var BaseService, ProductService,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseService = require('./base');

/**
 * Creates a new ProductService.
 * @class ProductService
*/


ProductService = (function(_super) {
  __extends(ProductService, _super);

  /**
   * Initialize the class.
   * @param  {Rest} [@_rest] an instance of the Rest client (sphere-node-connect)
   * @return {ProductService}
  */


  function ProductService(rest) {
    ProductService.__super__.constructor.call(this, rest);
    this._projectEndpoint = '/';
    this;
  }

  return ProductService;

})(BaseService);

/**
 * The {@link ProductService} service.
*/


module.exports = ProductService;
