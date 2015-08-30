import expect from 'expect'
import buildQueryString from '../../lib/utils/build-query-string'

describe('Utils', () => {

  describe('::buildQueryString', () => {

    it('should throw if no argument is passed', () => {
      expect(() => buildQueryString())
        .toThrow(/Missing options object to build query string/)
    })

    it('should build fully encoded query string', () => {
      const params = {
        expand: [
          encodeURIComponent('productType'),
          encodeURIComponent('categories[*]')
        ],
        operator: 'or',
        page: 3,
        perPage: 10,
        sort: [
          encodeURIComponent('name.en desc'),
          encodeURIComponent('createdAt asc')
        ],
        where: [
          encodeURIComponent('name(en = "Foo")'),
          encodeURIComponent('name(en = "Bar") and masterVariant(sku = "123")')
        ]
      }
      const expectedQueryString =
        `where=${encodeURIComponent('name(en = "Foo") or ' +
          'name(en = "Bar") and masterVariant(sku = "123")')}&` +
        `limit=10&offset=20&` +
        `sort=${encodeURIComponent('name.en desc')}&` +
        `sort=${encodeURIComponent('createdAt asc')}&` +
        `expand=productType&` +
        `expand=${encodeURIComponent('categories[*]')}`

      expect(buildQueryString(params)).toEqual(expectedQueryString)
    })
  })
})
