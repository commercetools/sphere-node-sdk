import test from 'tape'
import * as diffpatcher from '../../lib/sync/utils/diffpatcher'

test('Utils::diffpatcher', t => {
  t.test('::diff', t => {
    t.test('should diff a single object', t => {
      const original = { name: 'old' }
      const update = { name: 'new' }
      const diff = diffpatcher.diff(original, update)
      t.deepEqual(diff, { name: ['old', 'new'] })
      t.end()
    })

    t.test('should diff a list of scalar values', t => {
      const original = ['old', 'list']
      const update = ['new', 'list']
      const diff = diffpatcher.diff(original, update)
      // expect first value of the list to be modified
      const delta = diff[0]
      t.deepEqual(delta, ['new'])
      t.end()
    })

    t.test('should provide correct index on the array', t => {
      const original = [
        { name: 'old' },
        { name: 'list' },
      ]
      const update = [
        null,
        { name: 'list' },
      ]

      const diff = diffpatcher.diff(original, update)
      // expect first value of the list to be modified
      const delta = diff[0]
      t.deepEqual(delta, [ null ])
      t.end()
    })
    t.end()
  })

  t.test('::objectHash', t => {
    t.test(
      'should provide index value if obj is not defined or null in a list',
      t => {
        const objectHash = diffpatcher.objectHash
        const randomValues = [
          { name: 'random1' },
          null,
          '',
          0,
          [],
        ]

        const objectHashIndexValues = randomValues
          .map((r, i) => objectHash(r, i))

        t.deepEqual(objectHashIndexValues, [
          'random1',
          '$$index:1',
          '$$index:2',
          '$$index:3',
          '$$index:4',
        ], 'expect index value OR hash of the object in the list')
        t.end()
      })
    t.end()
  })

  t.test('::getDeltaValue', t => {
    t.test('should be equivalent to the updated value with objects', t => {
      const original = { obj: { name: 'original' } }
      const updated = { obj: { name: 'updated' } }
      const diff = diffpatcher.diff(original, updated)
      const delta = diffpatcher.getDeltaValue(diff.obj.name, original)
      t.deepEqual(delta, updated.obj.name,
        'expect delta to be equivalent to the updated value')
      t.end()
    })

    t.test(
      'should be equivalent to the updated value with list of scalar values',
      t => {
        const original = ['old', 'value']
        const updated = ['new', 'value']
        const diff = diffpatcher.diff(original, updated)
        const delta = diffpatcher.getDeltaValue(diff[0], original)
        t.deepEqual(delta, 'new')
        t.end()
      })
    t.end()
  })
})
