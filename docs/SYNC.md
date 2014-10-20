SPHERE SYNC
---

```coffeescript
{ProductSync} = require 'sphere-node-sdk' # utilities for Products Sync actions
{OrderSync} = require 'sphere-node-sdk' # utilities for Orders Sync actions
{InventorySync} = require 'sphere-node-sdk' # utilities for Inventories Sync actions
```

## Table of Contents
* [Documentation](#documentation)
  * [Methods](#methods)
    * [config](#config)
    * [buildActions](#buildactions)
    * [filterActions](#filteractions)
    * [shouldUpdate](#shouldupdate)
    * [getUpdateId](#getupdateid)
    * [getUpdateActions](#getupdateactions)
    * [getUpdatePayload](#getupdatepayload)
* [Update actions groups](#update-actions-groups)
  * [ProductSync](#productsync)
  * [OrderSync](#ordersync)
  * [InventorySync](#inventorysync)

## Documentation
The module exposes many _resource-specific_ `Sync` objects and it provides an API to compare 2 resources and build update actions out of it. Available resources are:

- *products* - `ProductSync`
- *orders* - `OrderSync`
- *inventory* - `InventorySync`

> All `Sync` objects share the same implementation, only the _mapping_ of the *actions update* is resource-specific. **I will assume from now on (for the sake of simplicity) that the `Sync` is either an instance of one of the resources listed above.**


### Methods

Following methods are accessible from the object.

#### `config`
Pass a list of [actions groups](#update-actions-groups) in order to restrict the actions that will be built

```coffeescript
options = [
  {type: 'base', group: 'black'}
  {type: 'prices', group: 'white'}
  {type: 'variants', group: 'black'}
]
# => this will exclude 'base' and 'variants' mapping of actions and include the rest (white group is actually implicit if not given)

sync.config(options).buildActions ...
```

> An empty list means all actions are built

#### `buildActions`
There is basically one main method `buildActions` which expects **2 valid JSON objects**, here is the signature:

```coffeescript
buildActions = (new_obj, old_obj) ->
  # ...
  this
```
The method returns a reference to the current object `Sync`, so that you can chain it with other methods.

#### `filterActions`
You can pass a custom function to filter built actions and internally update the actions payload.
> This function should be called after the actions are built

```coffeescript
# example
sync = new Sync {...}
sync.buildActions(new_obj, old_obj).filterActions (a) -> a.action is 'changeName'
# => actions payload will now contain only 'changeName' action
```
The method returns a reference to the current object `Sync`, so that you can chain it with other methods.

### `shouldUpdate`
Returns `true` or `false` whether there is something to update or not.

### `getUpdateId`
Returns the `id` of the resource to be updated, taken from *old_obj*.

### `getUpdateActions`
Returns the generated `actions` list that needs to be updated.

### `getUpdatePayload`
Returns the generated JSON payload for the update.

```coffeescript
# example
{SphereClient, Sync} = require 'sphere-node-sdk'
client = new SphereClient {...}
sync = new Sync
syncedActions = sync.buildActions(new_obj, old_obj)
if syncedActions.shouldUpdate()
  client.products.byId(syncedActions.getUpdatedId()).update(syncedActions.getUpdatePayload())
else
  # do nothing
```

## Update actions groups
Based on the instantiated resource sync (product, order, ...) there are groups of actions used for updates defined below.

> Groups gives you the ability to configure the sync to include / exclude them when the actions are [built](#buildactions). This concept can be expressed in terms of _blacklisting_ and _whitelisting_


### ProductSync

- `base` (name, slug, description)
- `references` (taxCategory, categories)
- `prices`
- `attributes`
- `images`
- `variants`
- `metaAttributes`

### OrderSync

- `status` (orderState, paymentState, shipmentState)
- `returnInfo` (returnInfo, shipmentState / paymentState of ReturnInfo)
- `deliveries` (delivery, parcel)

### InventorySync

- `quantity`
- `expectedDelivery`
