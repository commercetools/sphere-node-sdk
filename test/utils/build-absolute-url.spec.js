import test from 'tape'
import buildAbsoluteUrl from '../../src/utils/build-absolute-url'

test('Utils::buildAbsoluteUrl', t => {
  t.test('should build full URL', t => {
    const url = buildAbsoluteUrl({
      auth: { credentials: { projectKey: 'test' } },
      request: { protocol: 'https', host: 'api.sphere.io' },
    }, '/products')

    t.equal(url, 'https://api.sphere.io/test/products')
    t.end()
  })

  t.test('should build full URL (no projectKey)', t => {
    const url = buildAbsoluteUrl({
      auth: { credentials: {} },
      request: { protocol: 'https', host: 'api.sphere.io' },
    }, '/products')

    t.equal(url, 'https://api.sphere.io/products')
    t.end()
  })

  t.test('should build full URL (with prefix)', t => {
    const prefix1 = '/a-different/path'
    const url1 = buildAbsoluteUrl({
      auth: { credentials: { projectKey: 'test' } },
      request: { protocol: 'http', host: 'localhost:3000', urlPrefix: prefix1 },
    }, '/products')

    t.equal(url1, 'http://localhost:3000/a-different/path/test/products')

    const prefix2 = 'another/path'
    const url2 = buildAbsoluteUrl({
      auth: { credentials: {} },
      request: { protocol: 'http', host: 'localhost:3000', urlPrefix: prefix2 },
    }, '/products')

    t.equal(url2, 'http://localhost:3000/another/path/products')
    t.end()
  })
})
