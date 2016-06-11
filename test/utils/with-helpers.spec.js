import test from 'tape'
import * as withHelpers from '../../lib/utils/with-helpers'

test('Utils::withHelpers', t => {
  let service

  function setup () {
    service = Object.assign({
      options: {
        auth: { credentials: {} },
        request: { headers: { 'Content-Type': 'application/json' } },
      },
    }, withHelpers)
  }

  t.test('should set the given header', t => {
    setup()

    service.withHeader('Authorization', 'supersecret')
    t.deepEqual(service.options.request.headers, {
      Authorization: 'supersecret',
      'Content-Type': 'application/json',
    })
    t.end()
  })

  t.test('should throw if key or value are missing', t => {
    setup()

    t.throws(() => service.withHeader(),
      /Missing required header arguments/)

    t.throws(() => service.withHeader('foo'),
      /Missing required header arguments/)
    t.end()
  })

  t.test('should set the new credentials header', t => {
    setup()

    service.withCredentials({ projectKey: 'foo' })
    t.deepEqual(service.options.auth.credentials, {
      projectKey: 'foo',
    })
    t.end()
  })

  t.test('should throw if credentials is missing', t => {
    setup()

    t.throws(() => service.withCredentials(),
      /Credentials object is missing/)
    t.end()
  })
})
