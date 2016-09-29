import test from 'tape'
import SphereClient, {
  // Sync
  createSyncCategories,
  createSyncCustomers,
  createSyncInventories,
  createSyncProducts,
  // Middlewares
  createAuthMiddleware,
  createHttpMiddleware,
  createQueueMiddleware,
  createLoggerMiddleware,
  createErrorMiddleware,
} from '../src'
import pkg from '../package.json'

const { errors, constants, version } = SphereClient

test('Public exports', (t) => {
  t.test('should export SphereClient', (t) => {
    t.equal(typeof SphereClient, 'function')
    t.equal(SphereClient.name, 'SphereClient')
    t.end()
  })

  t.test('should export static properties', (t) => {
    t.ok(errors)
    t.equal(typeof constants, 'object')
    t.equal(version, pkg.version)
    t.end()
  })

  t.test('should export sync utils', (t) => {
    t.equal(typeof createSyncCategories, 'function')
    t.equal(typeof createSyncCustomers, 'function')
    t.equal(typeof createSyncInventories, 'function')
    t.equal(typeof createSyncProducts, 'function')
    t.end()
  })

  t.test('should export middlewares utils', (t) => {
    t.equal(typeof createAuthMiddleware, 'function')
    t.equal(typeof createHttpMiddleware, 'function')
    t.equal(typeof createQueueMiddleware, 'function')
    t.equal(typeof createLoggerMiddleware, 'function')
    t.equal(typeof createErrorMiddleware, 'function')
    t.end()
  })
})
