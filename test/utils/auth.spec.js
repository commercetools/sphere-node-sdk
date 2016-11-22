import test from 'tape'
import * as auth from '../../src/utils/auth'

test('Utils::authToken', t => {
  t.test('should build request to get auth token', t => {
    const authRequest = auth.buildRequest({
      credentials: {
        projectKey: 'foo',
        clientId: '123',
        clientSecret: 'secret',
      },
      host: 'auth.sphere.io',
    })
    const expectedEndpoint = 'https://auth.sphere.io/oauth/token'
    const expectedBody = 'grant_type=client_credentials' +
      '&scope=manage_project:foo'
    // truth is curl 'curl ... --basic --user "123:secret" ... --verbose'
    const expectedAuthorizationHeader = 'Basic MTIzOnNlY3JldA=='

    t.equal(authRequest.endpoint, expectedEndpoint)
    t.equal(authRequest.body, expectedBody)
    t.equal(authRequest.authorizationHeader, expectedAuthorizationHeader)
    t.end()
  })
})
