import test from 'tape'
import { spy } from 'sinon'
import { diff } from '../../../src/sync/utils/diffpatcher'
import createBuildArrayActions, {
  ADD_ACTIONS,
  REMOVE_ACTIONS,
  CHANGE_ACTIONS,
} from '../../../src/sync/utils/create-build-array-actions'

const testObjKey = 'someNestedObjects'
const getTestObj = (list) => ({ [testObjKey]: list || [] })

test('Sync::utils::createBuildArrayActions', (t) => {
  t.test('returns function', (t) => {
    t.equal(
      typeof createBuildArrayActions('test', {}),
      'function',
      'should return function'
    )
    t.end()
  })

  t.test('correctly detects add actions', (t) => {
    const before = getTestObj()
    const now = getTestObj([ { name: 'a new object' } ])
    const addActionSpy = spy()

    const handler = createBuildArrayActions(testObjKey, {
      [ADD_ACTIONS]: addActionSpy,
    })

    handler(diff(before, now), before, now)

    const calledWithCorrectArguments = addActionSpy
      .calledWithExactly({ name: 'a new object' })

    t.true(
      calledWithCorrectArguments,
      'add action handler called with correct arguments'
    )
    t.end()
  })

  t.test('correctly detects change actions', (t) => {
    const before = getTestObj([ { name: 'a new object' } ])
    const now = getTestObj([ { name: 'a changed object' } ])
    const changeActionSpy = spy()

    const handler = createBuildArrayActions(testObjKey, {
      [CHANGE_ACTIONS]: changeActionSpy,
    })

    handler(diff(before, now), before, now)

    const calledWithCorrectArguments = changeActionSpy.calledWithExactly(
      { name: 'a new object' },
      { name: 'a changed object' }
    )

    t.true(
      calledWithCorrectArguments,
      'change action handler called with correct arguments'
    )
    t.end()
  })

  t.test('correctly detects remove actions', (t) => {
    const before = getTestObj([ { name: 'an object' } ])
    const now = getTestObj()
    const removeActionSpy = spy()

    const handler = createBuildArrayActions(testObjKey, {
      [REMOVE_ACTIONS]: removeActionSpy,
    })

    handler(diff(before, now), before, now)

    const calledWithCorrectArguments = removeActionSpy
      .calledWithExactly({ name: 'an object' })

    t.true(
      calledWithCorrectArguments,
      'remove action handler called with correct arguments'
    )
    t.end()
  })
})
