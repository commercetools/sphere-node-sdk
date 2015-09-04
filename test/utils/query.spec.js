import expect from 'expect'
import * as query from '../../lib/utils/query'
import { getDefaultQueryParams } from '../../lib/utils/default-params'

describe('Utils', () => {

  describe('::query', () => {

    let service

    beforeEach(() => {
      service = Object.assign({ params: getDefaultQueryParams() }, query)
    })

    it('should set the where param', () => {
      service.where('name(en = "Foo Bar")')
      expect(service.params.query.where).toEqual([
        encodeURIComponent('name(en = "Foo Bar")')
      ])
    })

    it('should throw if predicate is missing', () => {
      expect(() => service.where()).toThrow(/Parameter `predicate` is missing/)
    })

    it('should set the whereOperator param', () => {
      service.whereOperator('or')
      expect(service.params.query.operator).toBe('or')

      service.whereOperator('and')
      expect(service.params.query.operator).toBe('and')
    })

    it('should throw if whereOperator is missing', () => {
      expect(() => service.whereOperator())
      .toThrow(/Parameter `operator` is missing/)
    })

    it('should throw if whereOperator is wrong', () => {
      expect(() => service.whereOperator('foo'))
      .toThrow(/Parameter `operator` is wrong, either `and` or `or`/)
    })

    it('should set the expand param', () => {
      service.expand('productType')
      expect(service.params.query.expand).toEqual([
        encodeURIComponent('productType')
      ])
    })

    it('should throw if expansionPath is missing', () => {
      expect(() => service.expand())
      .toThrow(/Parameter `expansionPath` is missing/)
    })

  })
})
