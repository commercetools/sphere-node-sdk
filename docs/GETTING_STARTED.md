# Getting started
Install the module with `npm install sphere-node-sdk`

The module exposes some objects but the most important one is [`SphereClient`](/sphere-node-sdk/classes/SphereClient.html).

```coffeescript
{SphereClient} = require 'sphere-node-sdk'

client = new SphereClient {} # configuration
```

The `SphereClient` communicates asynchronously with the SPHERE.IO API via HTTPS and takes care about authentication.
The client itself doesn't allow to make any request, instead you need to instantiate a specific `service` based on the related API resource you want to access.

```coffeescript
# examples
productService = client.products()
cartService = client.carts()
```

Each `service` provides multiple methods to build request. CRUD methods return then a [Promises](/sphere-node-sdk/classes/Promise.html) object that you can use for better async / functional programming.
