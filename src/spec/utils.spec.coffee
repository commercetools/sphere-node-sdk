_ = require 'underscore'
Utils = require '../lib/utils'
appRoot = require('app-root-path')

describe 'Utils', ->

  describe ':: buildQueryString', ->

    it 'should build query string with all params', ->
      query = Utils.buildQueryString
        where: ['masterData(current(name(en%3D%22Foo%22)))', 'id%3D%22123-abc-456-def-789-ghi%22']
        whereOperator: 'or'
        page: 2
        perPage: 5
        sort: ['foo+asc', 'bar+desc']
        expand: ['foo.bar', 'hello%5B*%5D.world']

      expect(query).toBe 'where=masterData(current(name(en%3D%22Foo%22)))%20or%20id%3D%22123-abc-456-def-789-ghi%22' +
        '&limit=5&offset=5&sort=foo+asc&sort=bar+desc&expand=foo.bar&expand=hello%5B*%5D.world'

    it 'should build query string without params', ->
      query = Utils.buildQueryString()
      expect(query).toBe ''

    it 'should build query string without (zero) offset', ->
      query = Utils.buildQueryString page: 1
      expect(query).toBe ''

    it 'should build query string with (positive) offset', ->
      query = Utils.buildQueryString page: 10, perPage: 20
      expect(query).toBe 'limit=20&offset=180'

    it 'should build query string with no limit (all results)', ->
      query = Utils.buildQueryString perPage: 0
      expect(query).toBe 'limit=0'

    it 'should throw if perPage is < 1', ->
      expect(-> Utils.buildQueryString perPage: -1).toThrow new Error 'PerPage (limit) must be a number >= 0'

    it 'should throw if page is < 1', ->
      expect(-> Utils.buildQueryString page: 0).toThrow new Error 'Page must be a number >= 1'


  describe ':: getTime', ->

    _.each [
      {amount: 30, type: 's', expected_time: 30 * 1000}
      {amount: 30, type: 'm', expected_time: 30 * 1000 * 60}
      {amount: 10, type: 'h', expected_time: 10 * 1000 * 60 * 60}
      {amount: 15, type: 'd', expected_time: 15 * 1000 * 60 * 60 * 24}
      {amount: 12, type: 'w', expected_time: 12 * 1000 * 60 * 60 * 24 * 7}
      {amount: 12, type: 'unknown', expected_time: 0}
    ], (o) ->
      it "should get time in milliseconds for '#{o.type}'", ->
        expect(Utils.getTime(o.amount, o.type)).toBe o.expected_time

  describe ':: getVersion', ->

    it "should return the current version of the sphere node sdk", ->
      pjson = require appRoot + '/package.json'
      expect(Utils.getVersion()).toBe pjson.version
      expect(Utils.getVersion()).toMatch(/^(\d+\.)?(\d+\.)?(\*|\d+)$/)