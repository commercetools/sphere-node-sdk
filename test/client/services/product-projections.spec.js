import expect from 'expect'
import { SphereClient } from '../../../lib'

describe('SphereClient', () => {

  let client

  beforeEach(() => {
    client = new SphereClient({})
  })

  describe('::product-projections', () => {

    it('should have read-only verbs', () => {
      expect(client.productProjections.fetch).toExist()
      expect(client.productProjections.create).toNotExist()
      expect(client.productProjections.update).toNotExist()
      expect(client.productProjections.delete).toNotExist()
    })
  })
})
