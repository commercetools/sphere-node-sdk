import test from 'tape'
import credentials from '../../../credentials'
import SphereClient from '../../../src'

let count = 0
function uniqueId (prefix) {
  const id = `${prefix}${Date.now()}_${count}`
  count++
  return id
}

test('Integration - Client', t => {
  let client

  function setup () {
    client = SphereClient.create({
      auth: {
        credentials: {
          projectKey: credentials.project_key,
          clientId: credentials.client_id,
          clientSecret: credentials.client_secret,
        },
      },
      request: {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'sphere-node-sdk',
        },
        maxParallel: 2,
      },
    })
  }

  t.test('::graphql', t => {
    t.test('should query channels', { timeout: 8000 }, t => {
      setup()

      const key1 = uniqueId('channel')
      const key2 = uniqueId('channel')

      Promise.all([
        client.channels.create({ key: key1 }),
        client.channels.create({ key: key2 }),
      ])
      .then(results => {
        const channel1 = results[0]
        const channel2 = results[1]

        return client.graphql.query({
          query: `
            query Sphere {
              channels(where: "key in (\\"${key1}\\", \\"${key2}\\")") {
                total,
                results {
                  ...ChannelKey
                }
              },
              channel1: channel(id: "${channel1.body.id}") {
                ...ChannelKey
              },
              channel2: channel(id: "${channel2.body.id}") {
                ...ChannelKey
              }
            }

            fragment ChannelKey on Channel {
              id, key
            }
          `,
        })
        .then(result => {
          t.equal(result.statusCode, 200)

          const { body } = result
          t.ok(body.data.channels, 'body `data.channels` exist')
          t.equal(body.data.channels.total, 2)
          t.equal(body.data.channels.results.length, 2)
          t.equal(Object.keys(body.data.channel1).length, 2)
          t.equal(body.data.channel1.id, channel1.body.id)
          t.equal(Object.keys(body.data.channel2).length, 2)
          t.equal(body.data.channel2.id, channel2.body.id)
          t.end()
        })
      })
      .catch(t.end)
    })

    t.test('should fail if query is not valid', t => {
      setup()

      client.graphql.query({
        query: `
          query Sphere {
            foo { bar }
          }
        `,
      })
      .then(() => {
        t.end('It should have failed')
      })
      .catch(error => {
        t.equal(error.code, 400)
        t.notOk(error.body.data)
        t.equal(error.body.errors.length, 1)
        t.ok(error.message.includes(
          'Cannot query field \'foo\' on type \'Query\''),
          'should include error message')
        t.end()
      })
    })
  })
})
