MIGRATION from 0.8 to 1.0
---

> The repo has been renamed from `sphere-node-client` to `sphere-node-sdk` since it has become more of a toolkit

## Summary of breaking changes
- renaming to `sphere-node-sdk`
- aggregation of `sphere-node-sdk`, `sphere-node-connect`, `sphere-node-sync`
- no more `bunyan` logger dependent, the application is free to choose
- use of `DEBUG` ENV variable for easier debugging
- switch from `Q` to `Bluebird` promises
- little changes of `sync` API

## Backwards incompatible changes
Here a short migration guide regarding backwards incompatible changes

### Available modules
Some applications have been using `sphere-node-sdk` in combination with `sphere-node-sync`, having some inconsistencies regarding dependency version of the former one.
To make it simpler now the two modules are independent from each other and the recommended usage for both is:
- `sync` should be used just to build update actions given two objects
- `client` should be used to talk to the API, using i.e. the actions generated from the `sync` to update a resource


```coffeescript
{SphereClient, ProductSync} = require 'sphere-node-sdk'
client = new SphereClient {...}
sync = new ProductSync # or one of the other *Sync objects

synced = sync.buildActions(new_prod, old_prod)
if synced.shouldUpdate()
  client.products().byId(synced.getUpdateId()).update(synced.getUpdatePayload())
  .then (result) -> expect(result.statusCode).toBe 200
  .fail (e) -> logger.error e
else
  # do nothing
```

In addition, the `sphere-node-connect` (the low-level API for talking to the SPHERE.IO HTTP API) is also included in the kit and not as a separate repository anymore.

### Logging / debugging
Logger has now been completely dropped, giving the application the liberty of using whatever type of logging.

So when you create a new instance of `SphereClient` or `ProductSync`, etc. you don't need to pass any logger configuration.

The module APIs will provide results or errors either via callbacks or promises (or by throwing an `Error`).

> For handling errors with promises please refer to [Bluebird documentation](https://github.com/petkaantonov/bluebird#error-handling)

If you are developing and need to do some debugging you can simply provide a `DEBUG` ENV variable to get output in the console. See [DEBUGGING](DEBUGGING.md).

```bash
$ DEBUG=* node lib/run
```

### Bluebird promises
The `Q` promises have been dropped in favor of the more [performance](https://github.com/petkaantonov/bluebird/blob/master/benchmark/stats/latest.md) library `Bluebird`.

The Promise APIs is basically the same as for `Q`, just some methods are different like:
- `fail` -> `catch`
- `allSettled` -> `settle`

> The library offers way more utility functions though, so make sure to check the [API documentation](https://github.com/petkaantonov/bluebird/blob/master/API.md) for building applications in a more functional way.

### Sync APIs
Being now a pure utils library, the `Sync API` has been adjusted like following.
Deprecated methods:
- `get`
- `update`

New methods:
- `shouldUpdate`
- `getUpdateId`
- `getUpdateActions`
- `getUpdatePayload`
