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
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 20000
    }
  })

  const endpoint = 'http://jsonplaceholder.typicode.com/posts'

  // TODO: use API endpoint
  httpFetch.get(endpoint)
    .then(res => {
      console.log('Streaming response (pipe)...')
      const ws = fs.createWriteStream(
        path.join(__dirname, '../output', `${filePrefix}-pipe.json`))
      res.body.pipe(ws)
    })

  httpFetch.get(endpoint)
    .then(res => {
      console.log('Streaming response (chunks)...')
      const chunks = []
      res.body.on('data', chunk => {
        chunks.push(chunk)
      })
      res.body.on('end', () => {
        fs.writeFileSync(
          path.join(__dirname, '../output', `${filePrefix}-chunk.json`),
          Buffer.concat(chunks).toString())
      })
    })

}
