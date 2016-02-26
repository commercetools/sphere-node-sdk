import test from 'tape'
import buildQueryString from '../../lib/utils/build-query-string'

test('Utils::buildQueryString', t => {

  t.test('should throw if no argument is passed', t => {
    t.throws(() => buildQueryString(),
      /Missing options object to build query string/)
    t.end()
  })

  t.test('should build fully encoded query string', t => {
    const params = {
      expand: [
        encodeURIComponent('productType'),
        encodeURIComponent('categories[*]')
      ],
      staged: false,
      pagination: {
        page: 3,
        perPage: 10,
        sort: [
          encodeURIComponent('name.en desc'),
          encodeURIComponent('createdAt asc')
        ]
      },
      query: {
        operator: 'or',
        where: [
          encodeURIComponent('name(en = "Foo")'),
          encodeURIComponent('name(en = "Bar") and categories(id = "123")')
        ]
      },
      search: {
        facet: [
          encodeURIComponent('variants.attributes.foo:"bar")'),
          encodeURIComponent('variants.sku:"foo123"')
        ],
        filter: [
          encodeURIComponent('variants.attributes.color.key:"red")'),
          encodeURIComponent('categories.id:"123"')
        ],
        filterByQuery: [
          encodeURIComponent('variants.attributes.color.key:"red")'),
          encodeURIComponent('categories.id:"123"')
        ],
        filterByFacets: [
          encodeURIComponent('variants.attributes.color.key:"red")'),
          encodeURIComponent('categories.id:"123"')
        ],
        text: { lang: 'en', value: 'Foo' }
      }
    }
    /*eslint-disable max-len*/
    const expectedQueryString =
      'staged=false&' +
      'expand=productType&' +
      `expand=${encodeURIComponent('categories[*]')}&` +
      `where=${encodeURIComponent('name(en = "Foo") or name(en = "Bar") and categories(id = "123")')}&` +
      'limit=10&offset=20&' +
      `sort=${encodeURIComponent('name.en desc')}&` +
      `sort=${encodeURIComponent('createdAt asc')}&` +
      `text.en=${encodeURIComponent('Foo')}&` +
      `facet=${encodeURIComponent('variants.attributes.foo:"bar")')}&` +
      `facet=${encodeURIComponent('variants.sku:"foo123"')}&` +
      `filter=${encodeURIComponent('variants.attributes.color.key:"red")')}&` +
      `filter=${encodeURIComponent('categories.id:"123"')}&` +
      `filter.query=${encodeURIComponent('variants.attributes.color.key:"red")')}&` +
      `filter.query=${encodeURIComponent('categories.id:"123"')}&` +
      `filter.facets=${encodeURIComponent('variants.attributes.color.key:"red")')}&` +
      `filter.facets=${encodeURIComponent('categories.id:"123"')}`
    /*eslint-enable max-len*/

    t.deepEqual(buildQueryString(params), expectedQueryString)
    t.end()
  })
})
