import fs from 'fs'
import path from 'path'
import http from '../../../lib/utils/http'

/*
  Example of streaming response body from a fetch request

    `res.body instanceof stream.Transform`
 */

export default function streamResponse (promiseLibrary, filePrefix) {

  const httpFetch = http({
    Promise: promiseLibrary,
    request: {
      headers: {},
      timeout: 20000
    }
  })

  // TODO: use API endpoint
  httpFetch.get('http://sphere.io')
    .then(res => {
      const ws = fs.createWriteStream(
        path.join(__dirname, '../output', `${filePrefix}-pipe.html`))
      res.body.pipe(ws)
    })

  httpFetch.get('http://sphere.io')
    .then(res => {
      const chunks = []
      res.body.on('data', chunk => {
        chunks.push(chunk)
      })
      res.body.on('end', () => {
        fs.writeFileSync(
          path.join(__dirname, '../output', `${filePrefix}-chunk.html`),
          Buffer.concat(chunks).toString())
      })
    })

}
