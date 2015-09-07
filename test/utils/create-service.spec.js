import expect from 'expect'
import createService from '../../lib/utils/create-service'

const fakeService = {
  type: 'test',
  endpoint: '/test',
  options: {
    hasRead: true,
    hasCreate: true,
    hasUpdate: true,
    hasDelete: true,
    hasQuery: true,
    hasQueryOne: true,
    hasQueryExpand: true,
    hasSearch: true,
    hasProjection: true,
    hasQueryString: true
  }
}

describe('Utils', () => {

  describe('::createService', () => {

    it('should create a fully service', () => {
      const service = createService(fakeService)({})

      expect(service.withCredentials).toExist()
      expect(service.withHeader).toExist()
      expect(service.where).toExist()
      expect(service.whereOperator).toExist()
      expect(service.sort).toExist()
      expect(service.page).toExist()
      expect(service.perPage).toExist()
      expect(service.byId).toExist()
      expect(service.expand).toExist()
      expect(service.text).toExist()
      expect(service.facet).toExist()
      expect(service.filter).toExist()
      expect(service.filterByQuery).toExist()
      expect(service.filterByFacets).toExist()
      expect(service.staged).toExist()
      expect(service.byQueryString).toExist()
      expect(service.fetch).toExist()
      expect(service.create).toExist()
      expect(service.update).toExist()
      expect(service.delete).toExist()
    })

  })
})
