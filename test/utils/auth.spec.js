import * as auth from '../../lib/utils/auth'

describe('Utils', () => {

  describe('::authToken', () => {

    it('should build request to get auth token', () => {
      const authRequest = auth.buildRequest({
        projectKey: 'foo',
        clientId: '123',
        clientSecret: 'secret'
      })
      const expectedEndpoint = 'https://123:secret@auth.sphere.io/oauth/token'
      const expectedBody = 'grant_type=client_credentials' +
        '&scope=manage_project:foo'

      expect(authRequest.endpoint).toEqual(expectedEndpoint)
      expect(authRequest.body).toEqual(expectedBody)
    })

  })
})
