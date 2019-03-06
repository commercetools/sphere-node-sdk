_ = require 'underscore'
{CategorySync} = require '../../lib/main'

describe 'CategorySync', ->

  beforeEach ->
    @sync = new CategorySync

  afterEach ->
    @sync = null

  describe ':: buildActions', ->

    it 'should create no update actions', ->
      category =
        id: 'c123'

      update = @sync.buildActions(category, category).getUpdatePayload()
      expect(update).toBeUndefined()
      updateId = @sync.buildActions(category, category).getUpdateId()
      expect(updateId).toBe 'c123'

    it 'should create different kind of update actions', ->
      category =
        id: 'c123'
        externalId: 'ext123'
        key: 'key123'

      newCategory =
        id: 'c123'
        externalId: 'ext234'
        key: 'key234'
        name:
          en: 'my Category'
        slug:
          de: 'my-cat'
        description:
          fr: 'bla'
        orderHint: '0.9'
        parent:
          id: 'root'
          typeId: 'category'

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()
      expect(_.size update.actions).toBe 7
      expect(update.actions[0].action).toBe 'changeName'
      expect(update.actions[0].name).toEqual { en : 'my Category' }
      expect(update.actions[1].action).toBe 'changeSlug'
      expect(update.actions[1].slug).toEqual { de : 'my-cat' }
      expect(update.actions[2].action).toBe 'setDescription'
      expect(update.actions[2].description).toEqual { fr: 'bla' }
      expect(update.actions[3].action).toBe 'changeParent'
      expect(update.actions[3].parent).toEqual { id: 'root', typeId: 'category' }
      expect(update.actions[4].action).toBe 'changeOrderHint'
      expect(update.actions[4].orderHint).toBe '0.9'
      expect(update.actions[5].action).toBe 'setExternalId'
      expect(update.actions[5].externalId).toBe 'ext234'
      expect(update.actions[6].action).toBe 'setKey'
      expect(update.actions[6].key).toBe 'key234'

    it 'should create only externalId update actions', ->
      category =
        id: 'c123'
        externalId: 'ext123'

      newCategory =
        id: 'c123'
        externalId: 'ext234'

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()
      expect(_.size update.actions).toBe 1
      expect(update.actions[0].action).toBe 'setExternalId'
      expect(update.actions[0].externalId).toBe 'ext234'

    it 'should not create an update action for categories without orderHint', ->
      category =
        id: 'c123'
        orderHint: '0.1'

      newCategory =
        id: 'c123'

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeUndefined()

    it 'should not create an update action for categories without slug', ->
      category =
        id: 'c123'
        slug:
          en: 'slug'

      newCategory =
        id: 'c123'

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeUndefined()

    it 'should add custom fields object using setCustomType update action', ->
      category =
        id: 'c123'
        key: 'key123'
        # no custom property

      newCategory =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            customFieldName: 'value'

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()

      expect(_.size update.actions).toBe 1
      expect(update.actions[0]).toEqual
        action: 'setCustomType'
        type:
          typeId: 'type'
          id: 'customTypeId'
        fields:
          customFieldName: 'value'

    it 'should change whole custom object when new customType is provided', ->
      category =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            customFieldName: 'value'

      newCategory =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeIdChanged'
          fields:
            differentCustomKey: 'value2'

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()

      expect(_.size update.actions).toBe 1
      expect(update.actions[0]).toEqual
        action: 'setCustomType'
        type:
          typeId: 'type'
          id: 'customTypeIdChanged'
        fields:
          differentCustomKey: 'value2'

    it 'should remove custom fields using setCustomType update action', ->
      category =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            customFieldName: 'value'

      newCategory =
        id: 'c123'
        key: 'key123'
        # removed custom fields

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()

      expect(_.size update.actions).toBe 1
      expect(update.actions[0]).toEqual
        action: 'setCustomType'
        # will remove custom fields

    it 'should add a new custom field using setCustomField update action', ->
      category =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            persistedField: 123

      newCategory =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            persistedField: 123
            newField: 'newValue'


      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()

      expect(_.size update.actions).toBe 1
      expect(update.actions[0]).toEqual
        action: 'setCustomField'
        name: 'newField'
        value: 'newValue'

    it 'should change custom field using setCustomField update action', ->
      category =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            customFieldName: 'value'

      newCategory =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            customFieldName: 'changedValue'

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()

      expect(_.size update.actions).toBe 1
      expect(update.actions[0]).toEqual
        action: 'setCustomField'
        name: 'customFieldName'
        value: 'changedValue'

    it 'should remove custom field using setCustomField update action', ->
      category =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            persistedField: 123
            customFieldName: 'value'

      newCategory =
        id: 'c123'
        key: 'key123'
        custom:
          type:
            typeId: 'type'
            id: 'customTypeId'
          fields:
            persistedField: 123

      update = @sync.buildActions(newCategory, category).getUpdatePayload()
      expect(update).toBeDefined()

      expect(_.size update.actions).toBe 1
      expect(update.actions[0]).toEqual
        action: 'setCustomField'
        name: 'customFieldName'
        # will remove