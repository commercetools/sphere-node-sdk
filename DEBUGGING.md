DEBUGGING
---

The SDK doesn't use any Logger and lets the application decide how to handle it.
On the other hand, it provides some debugging support using the [`debug`](https://github.com/visionmedia/debug) library.

To enable debugging simply set the `DEBUG` environment variable, specifying the accuracy of the debugger by using or not using [wildcards](https://github.com/visionmedia/debug#wildcards).

```bash
DEBUG=*
DEBUG=sphere-connect:rest
DEBUG=sphere-client
DEBUG=spec-sphere-client:*
```