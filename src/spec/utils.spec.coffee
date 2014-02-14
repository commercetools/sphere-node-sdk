Utils = require '../lib/utils'

describe 'Utils', ->

  it 'should build query string with all params', ->
    query = Utils.buildQueryString
      where: ['masterData(current(name(en%3D%22Foo%22)))', 'id%3D%22123-abc-456-def-789-ghi%22']
      whereOperator: 'or'
      page: 2
      perPage: 5

    expect(query).toBe 'where=masterData(current(name(en%3D%22Foo%22)))%20or%20id%3D%22123-abc-456-def-789-ghi%22&limit=5&offset=5'

  it 'should build query string without params', ->
    query = Utils.buildQueryString()
    expect(query).toBe 'limit=100'

  it 'should build query string without (zero) offset', ->
    query = Utils.buildQueryString page: -10
    expect(query).toBe 'limit=100'

  it 'should build query string with (positive) offset', ->
    query = Utils.buildQueryString page: 10, perPage: 20
    expect(query).toBe 'limit=20&offset=180'

  it 'should build query string with no limit (all results)', ->
    query = Utils.buildQueryString perPage: 0
    expect(query).toBe 'limit=0'

  it 'should build query string with (default) limit', ->
    query = Utils.buildQueryString perPage: -10
    expect(query).toBe 'limit=100'
