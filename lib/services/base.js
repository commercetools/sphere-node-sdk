var BaseService, Q;

Q = require('q');

/**
 * Creates a new BaseService, containing base functionalities. It should be extended when defining a Service.
 * @class BaseService
*/


BaseService = (function() {
  /**
   * Initialize the class.
   * @param  {Rest} [@_rest] an instance of the Rest client (sphere-node-connect)
   * @return {BaseService}
  */

  function BaseService(_rest) {
    this._rest = _rest;
    this._projectEndpoint = '/';
    this;
  }

  /**
   * Fetch resource defined by [@_projectEndpoint]
   * @return {Promise} a promise, fulfilled with an Object or rejected with a SphereError
  */


  BaseService.prototype.fetch = function() {
    var deferred;
    deferred = Q.defer();
    this._rest(this._projectEndpoint, function(e, r, b) {
      if (e) {
        return deferred.reject(e);
      } else {
        return deferred.resolve(JSON.parse(b));
      }
    });
    return deferred.promise;
  };

  return BaseService;

})();

/**
 * The {@link BaseService} service.
*/


module.exports = BaseService;
