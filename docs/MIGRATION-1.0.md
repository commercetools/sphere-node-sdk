MIGRATION from 0.8 to 1.0
---

- rename to `sphere-node-sdk`
- aggregation of `sphere-node-client`, `sphere-node-connect`, `sphere-node-sync`
- no more `bunyan` logger dependent, the application is free to choose
- use of `DEBUG` ENV variable for easy debugging
- switch from `Q` to `Bluebird` promises
- little changes of `sync` API
