import test from 'tape'
import * as querySearch from '../../lib/utils/query-search'
import { getDefaultSearchParams } from '../../lib/utils/default-params'

test('Utils::querySearch', t => {
  let service

  function setup () {
    service = Object.assign({ params: getDefaultSearchParams() }, querySearch)
  }

  t.test('should set the text param', t => {
    setup()

    service.text('Foo Bar', 'en')
    t.deepEqual(service.params.search.text, {
      lang: 'en',
      value: encodeURIComponent('Foo Bar'),
    })
    t.end()
  })

  t.test('should throw if text params are missing', t => {
    setup()

    t.throws(() => service.text(),
      /Required arguments for `text` are missing/)
    t.throws(() => service.text('Foo Bar'),
      /Required arguments for `text` are missing/)
    t.end()
  })

  t.test('should set the fuzzy param', t => {
    setup()

    service.fuzzy()
    t.equal(service.params.search.fuzzy, true)
    t.end()
  })

  t.test('should set the facet param', t => {
    setup()

    service.facet('categories.id:"123"')
    t.deepEqual(service.params.search.facet, [
      encodeURIComponent('categories.id:"123"'),
    ])
    t.end()
  })

  t.test('should throw if facet is missing', t => {
    setup()

    t.throws(() => service.facet(),
      /Required argument for `facet` is missing/)
    t.end()
  })

  t.test('should set the filter param', t => {
    setup()

    service.filter('categories.id:"123"')
    t.deepEqual(service.params.search.filter, [
      encodeURIComponent('categories.id:"123"'),
    ])
    t.end()
  })

  t.test('should throw if filter is missing', t => {
    setup()

    t.throws(() => service.filter(),
      /Required argument for `filter` is missing/)
    t.end()
  })

  t.test('should set the filterByQuery param', t => {
    setup()

    service.filterByQuery('categories.id:"123"')
    t.deepEqual(service.params.search.filterByQuery, [
      encodeURIComponent('categories.id:"123"'),
    ])
    t.end()
  })

  t.test('should throw if filterByQuery is missing', t => {
    setup()

    t.throws(() => service.filterByQuery(),
      /Required argument for `filterByQuery` is missing/)
    t.end()
  })

  t.test('should set the filterByFacets param', t => {
    setup()

    service.filterByFacets('categories.id:"123"')
    t.deepEqual(service.params.search.filterByFacets, [
      encodeURIComponent('categories.id:"123"'),
    ])
    t.end()
  })

  t.test('should throw if filterByFacets is missing', t => {
    setup()

    t.throws(() => service.filterByFacets(),
      /Required argument for `filterByFacets` is missing/)
    t.end()
  })
})
