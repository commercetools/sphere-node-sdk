var express = require('express'),
  target = './_docs'
  port = 3000,
  app = express()

app.use(express.static(target)).listen(port)
console.log('Documentation from %s is available at http://localhost:%d', target, port)
