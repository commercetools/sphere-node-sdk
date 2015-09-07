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

    it('should throw if config is missing', () => {
      expect(() => createService())
      .toThrow(/Cannot create a service without a `config`/)
    })

    it('should throw if config parameters are missing', () => {
      expect(() => createService({ type: 'foo' }))
      .toThrow(/Object `config` is missing required parameters/)

      expect(() => createService({ type: 'foo', endpoint: '/foo' }))
      .toThrow(/Object `config` is missing required parameters/)

      expect(() => createService({
        type: 'foo', endpoint: '/foo', options: {} }))
      .toThrow(/Object `config` is missing required parameters/)
    })
  })
})
