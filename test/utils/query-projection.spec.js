import expect from 'expect'
import * as queryProjection from '../../lib/utils/query-projection'

describe('Utils', () => {

  describe('::queryProjection', () => {

    let service

    beforeEach(() => {
      service = Object.assign({ params: {} }, queryProjection)
    })

    it('should set the staged param', () => {
      service.staged()
      expect(service.params.staged).toBe(true)

      service.staged(false)
      expect(service.params.staged).toBe(false)

      service.staged(true)
      expect(service.params.staged).toBe(true)
    })

  })
})
