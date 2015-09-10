import test from 'tape'
import SphereClient from '../lib'

const { errors, http } = SphereClient

test('Public exports', t => {

  t.test('should export SphereClient', t => {
    t.equal(typeof SphereClient, 'function')
    t.equal(SphereClient.name, 'SphereClient')
    t.end()
  })

  t.test('should export static properties', t => {
    t.ok(errors)
    t.equal(typeof http, 'function')
    t.equal(http.name, 'http')
    t.end()
  })
})
