TASK QUEUE
---

A `TaskQueue` allows you to queue `Bluebird` promises (or function that return promises) which will be executed in parallel until a max limit, meaning that new tasks will not be triggered until the previous ones are resolved.

```coffeescript
Promise = require 'bluebird'
{TaskQueue} = require 'sphere-node-sdk'

callMe = ->
  new Promise (resolve, reject) ->
    setTimeout ->
      resolve true
    , 5000
task = new TaskQueue maxParallel: 50 # default 20
task.addTask callMe
.then (result) -> # result == true
.catch (error) ->
```

Available methods:
- `setMaxParallel` sets the `maxParallel` parameter (default is `20`). **If < 1 or > 100 it throws an error**
- `addTask` adds a task (promise) to the queue and returns a new promise
