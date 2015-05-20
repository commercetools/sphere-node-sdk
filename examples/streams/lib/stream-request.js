import fs from 'fs'
import path from 'path'
import { http as httpFn } from '../../../lib'

/*
  Example of request with readable stream as body
 */

export default function streamRequest (promiseLibrary) {

  const http = httpFn({
    Promise: promiseLibrary,
    request: {
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 20000
    }
  })

  const endpoint = 'http://jsonplaceholder.typicode.com/posts'
  const body = fs.createReadStream(path.join(
    __dirname, '../data/post.json'), { encoding: 'utf-8' })

  // TODO: use API endpoint
  console.log('Streaming request body...')
  http(endpoint, { body, method: 'POST' })
    .then(res => res.json())
    .then(res => {
      console.log('Successfully posted body: ', res)
    })

}
