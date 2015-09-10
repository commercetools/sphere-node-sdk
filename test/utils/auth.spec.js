import test from 'tape'
import * as auth from '../../lib/utils/auth'

test('Utils::authToken', t => {

  t.test('should build request to get auth token', t => {
    const authRequest = auth.buildRequest({
      projectKey: 'foo',
      clientId: '123',
      clientSecret: 'secret'
    })
    const expectedEndpoint = 'https://123:secret@auth.sphere.io/oauth/token'
    const expectedBody = 'grant_type=client_credentials' +
      '&scope=manage_project:foo'

    t.equal(authRequest.endpoint, expectedEndpoint)
    t.equal(authRequest.body, expectedBody)
    t.end()
  })
})
