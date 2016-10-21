import test from 'tape'
import SphereClient, {
  createSyncCategories,
  createSyncCustomers,
  createSyncInventories,
  createSyncOrders,
  createSyncProducts,
} from '../src'
import pkg from '../package.json'

const { errors, features, http, version } = SphereClient

test('Public exports', (t) => {
  t.test('should export SphereClient', (t) => {
    t.equal(typeof SphereClient, 'function')
    t.equal(SphereClient.name, 'SphereClient')
    t.end()
  })

  t.test('should export static properties', (t) => {
    t.ok(errors)
    t.equal(typeof http, 'function')
    t.equal(http.name, 'http')
    t.equal(Object.keys(features).length, 10)
    t.equal(version, pkg.version)
    t.end()
  })

  t.test('should export sync utils', (t) => {
    t.equal(typeof createSyncCategories, 'function')
    t.equal(typeof createSyncCustomers, 'function')
    t.equal(typeof createSyncInventories, 'function')
    t.equal(typeof createSyncOrders, 'function')
    t.equal(typeof createSyncProducts, 'function')
    t.end()
  })
})
