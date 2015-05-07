import chai, { expect } from 'chai'
import sinon from 'sinon'
import sinonChai from 'sinon-chai'
import { productProjectionsFn } from '../../../lib/client/services'

chai.use(sinonChai)

describe('ProductProjections', () => {

  let mockDeps

  beforeEach(() => {
    mockDeps = {
      queue: {
        addTask: sinon.stub()
      },
      options: {
        auth: {
          credentials: {
            projectKey: 'foo'
          }
        },
        request: {
          host: 'api.sphere.io',
          protocol: 'https'
        }
      }
    }
  })

  it('should initialize service', () => {
    const service = productProjectionsFn(mockDeps)
    expect(service.baseEndpoint).to.equal('/product-projections')
    expect(service.byId).to.be.a('function')
    expect(service.where).to.be.a('function')
    expect(service.fetch).to.be.a('function')
  })

  it('should build default fetch url', () => {
    const service = productProjectionsFn(mockDeps)

    service.fetch()
    expect(mockDeps.queue.addTask).to.have.been.calledWith({
      'method': 'GET',
      'url': 'https://api.sphere.io/foo/product-projections'
    })
  })

  it('should build custom fetch url', () => {
    mockDeps.options.request.urlPrefix = '/public'
    const service = productProjectionsFn(mockDeps)

    service.byId('123').fetch()
    expect(mockDeps.queue.addTask).to.have.been.calledWith({
      'method': 'GET',
      'url': 'https://api.sphere.io/public/foo/product-projections/123'
    })
  })
})
