_ = require 'underscore'
_.mixin require 'underscore-mixins'
CategoryUtils = require '../../../lib/sync/utils/category'

describe 'CategoryUtils', ->
  beforeEach ->
    @utils = new CategoryUtils()

  afterEach ->
    @utils = null

  describe 'actionsMap', ->
    it 'should create no actions for the same category', ->
      category =
        id: 'same'
        name:
          de: 'bla'
          en: 'foo'

      delta = @utils.diff category, category
      update = @utils.actionsMap delta, category

      expect(update).toEqual []


    it 'should create action to change name', ->
      category =
        id: '123'
        name:
          de: 'bla'
          en: 'foo'

      otherCategory = _.deepClone category
      otherCategory.name.en = 'bar'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'changeName', name: { de: 'bla', en: 'bar' } }
      ]

    it 'should create action to change description', ->
      category =
        id: '123'
        name:
          en: 'foo'
        description:
          en: 'foo bar'

      otherCategory = _.deepClone category
      otherCategory.description.en = "some\nmulti line\n text"
      otherCategory.description.de = 'eine andere Sprache'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'setDescription', description: { de: 'eine andere Sprache', en: "some\nmulti line\n text" } }
      ]

    it 'should create action to delete description', ->
      category =
        id: '123'
        description:
          en: 'foo bar'

      otherCategory = _.deepClone category
      delete otherCategory.description

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'setDescription' }
      ]

    it 'should create action to change slug', ->
      category =
        id: '123'
        name:
          en: 'foo'
        slug:
          en: 'foo-bar'

      otherCategory = _.deepClone category
      delete otherCategory.slug.en
      otherCategory.slug.de = 'nice-url'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'changeSlug', slug: { de: 'nice-url' } }
      ]

    it 'should create action to change parent', ->
      category =
        id: '123'
        parent:
          typeId: 'category'
          id: 'p1'

      otherCategory = _.deepClone category
      otherCategory.parent.id = 'p2'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'changeParent', parent: { typeId: 'category', id: 'p2' } }
      ]

    it 'should create action to change order hint', ->
      category =
        id: '123'
        orderHint: '0.9'

      otherCategory = _.deepClone category
      otherCategory.orderHint = '0.1'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'changeOrderHint', orderHint: '0.1' }
      ]

    it 'should create action to set external id', ->
      category =
        id: '123'

      otherCategory = _.deepClone category
      otherCategory.externalId = 'ext-123'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'setExternalId', externalId: 'ext-123' }
      ]

    it 'should create action to change external id', ->
      category =
        id: '123'
        externalId: 'something'

      otherCategory = _.deepClone category
      otherCategory.externalId = 'ext-123'

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'setExternalId', externalId: 'ext-123' }
      ]

    it 'should create action to delete external id', ->
      category =
        id: '123'
        externalId: 'external-123'

      otherCategory = _.deepClone category
      delete otherCategory.externalId

      delta = @utils.diff category, otherCategory
      update = @utils.actionsMap delta, otherCategory
      expect(update).toEqual [
        { action: 'setExternalId' }
      ]