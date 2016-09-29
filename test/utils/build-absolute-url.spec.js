import test from 'tape'
import buildAbsoluteUrl from 'utils/build-absolute-url'

test('Utils::buildAbsoluteUrl', (t) => {
  t.comment('should build full URL')
  t.equal(
    buildAbsoluteUrl({
      endpoint: '/products',
      host: 'api.sphere.io',
      projectKey: 'test',
      protocol: 'https',
    }),
    'https://api.sphere.io/test/products'
  )

  t.comment('should build full URL (no projectKey)')
  t.equal(
    buildAbsoluteUrl({
      endpoint: '/products',
      host: 'api.sphere.io',
      protocol: 'https',
    }),
    'https://api.sphere.io/products'
  )

  t.comment('should build full URL (with prefix)')
  t.equal(
    buildAbsoluteUrl({
      endpoint: '/products',
      host: 'api.sphere.io',
      projectKey: 'test',
      protocol: 'https',
      urlPrefix: '/a-different/path',
    }),
    'https://api.sphere.io/a-different/path/test/products',
  )

  t.equal(
    buildAbsoluteUrl({
      endpoint: '/products',
      host: 'api.sphere.io',
      projectKey: 'test',
      protocol: 'https',
      urlPrefix: 'another/path',
    }),
    'https://api.sphere.io/another/path/test/products',
  )

  t.end()
})
