import test from 'tape'
import { spy, stub } from 'sinon'
import createHttpVerbs from 'utils/create-http-verbs'
import initStore from 'utils/init-store'
import SphereClient from 'index.js'

const {
  HTTP_FETCH,
  HTTP_CREATE,
  HTTP_UPDATE,
  HTTP_DELETE,
  SERVICE_INIT,
  SERVICE_PARAMS_RESET,
  TASK,
} = SphereClient.constants

const fakeHttpMiddleware = () => next => (action) => {
  if (action.type === TASK)
    return action.meta.promise.resolve()
  return next(action)
}

function getTestContext (type = 'test-service') {
  const store = initStore({
    projectKey: 'test',
    middlewares: [fakeHttpMiddleware],
  })

  store.dispatch({
    type: SERVICE_INIT,
    payload: `/${type}`,
    meta: { service: type },
  })

  return {
    type,
    store,
  }
}

function assertParamsResetAction (t, context) {
  t.equal(context.store.dispatch.callCount, 2,
    'dispatch state reset and task')
  t.deepEqual(context.store.dispatch.args[0][0],
    {
      type: SERVICE_PARAMS_RESET,
      meta: { service: context.type },
    },
    'dispatch params reset action'
  )
}

function assertTaskAction (t, context, expectedSource) {
  const taskDispatch = context.store.dispatch.args[1][0]
  t.equal(taskDispatch.type, TASK, 'task dispatch has type')
  t.equal(taskDispatch.meta.source, expectedSource,
    'task dispatch has source')
  t.equal(taskDispatch.meta.service, context.type,
    'task dispatch has service type')
  t.equal(taskDispatch.meta.serviceState.endpoint, `/${context.type}`,
    'task dispatch has endpoint in state')
  t.equal(typeof taskDispatch.meta.promise.resolve, 'function',
    'task dispatch has promise resolve function')
  t.equal(typeof taskDispatch.meta.promise.reject, 'function',
    'task dispatch has promise reject function')

  return taskDispatch
}

test.only('Utils::createHttpVerbs', (t) => {
  t.test('should return correct methods', (t) => {
    const verbs = createHttpVerbs()

    t.equal(typeof verbs.fetch, 'function', 'has fetch')
    t.equal(typeof verbs.create, 'function', 'has create')
    t.equal(typeof verbs.update, 'function', 'has update')
    t.equal(typeof verbs.delete, 'function', 'has delete')

    t.end()
  })

  t.test('::fetch', (t) => {
    t.test('should dispatch task', (t) => {
      const context = getTestContext()
      const verbs = createHttpVerbs()
      Object.assign(verbs, context)

      spy(context.store, 'dispatch')

      verbs.fetch()
      .then(() => {
        assertParamsResetAction(t, context)

        const taskDispatch = assertTaskAction(t, context, HTTP_FETCH)
        t.false(taskDispatch.payload, 'task dispatch does not have payload')

        t.end()
      })
      .catch(t.end)
    })
  })

  t.test('::create', (t) => {
    t.test('should throw if body is missing', (t) => {
      const verbs = createHttpVerbs()

      t.throws(
        () => {
          verbs.create()
        },
        /Body payload is required for creating a resource/,
        'throw that body is missing'
      )
      t.end()
    })

    t.test('should dispatch task', (t) => {
      const context = getTestContext()
      const verbs = createHttpVerbs()
      Object.assign(verbs, context)

      spy(context.store, 'dispatch')

      verbs.create({ foo: 'bar' })
      .then(() => {
        assertParamsResetAction(t, context)

        const taskDispatch = assertTaskAction(t, context, HTTP_CREATE)
        t.deepEqual(taskDispatch.payload, { foo: 'bar' },
          'task dispatch has a payload')

        t.end()
      })
      .catch(t.end)
    })
  })

  t.test('::update', (t) => {
    t.test('should throw if body is missing', (t) => {
      const verbs = createHttpVerbs()

      t.throws(
        () => {
          verbs.update()
        },
        /Body payload is required for updating a resource/,
        'throw that body is missing'
      )
      t.end()
    })

    t.test('should throw if id is missing', (t) => {
      const context = getTestContext()
      const verbs = createHttpVerbs()
      Object.assign(verbs, context)

      t.throws(
        () => {
          verbs.update({ foo: 'bar' })
        },
        // eslint-disable-next-line max-len
        /Missing required `id` param for updating a resource\. You can set it by chaining/,
        'throw that id is missing'
      )
      t.end()
    })

    t.test('should dispatch task', (t) => {
      const context = getTestContext()
      const verbs = createHttpVerbs()
      Object.assign(verbs, context)

      spy(context.store, 'dispatch')
      stub(context.store, 'getState', () => ({
        service: {
          [context.type]: {
            id: '123',
            endpoint: `/${context.type}`,
          },
        },
      }))

      verbs.update({ foo: 'bar' })
      .then(() => {
        assertParamsResetAction(t, context)

        const taskDispatch = assertTaskAction(t, context, HTTP_UPDATE)
        t.deepEqual(taskDispatch.payload, { foo: 'bar' },
          'task dispatch has a payload')

        t.end()
      })
      .catch(t.end)
    })
  })

  t.test('::delete', (t) => {
    t.test('should throw if version is missing', (t) => {
      const verbs = createHttpVerbs()

      t.throws(
        () => {
          verbs.delete()
        },
        /Version number is required for deleting a resource/,
        'throw that version is missing'
      )
      t.end()
    })

    t.test('should throw if id is missing', (t) => {
      const context = getTestContext()
      const verbs = createHttpVerbs()
      Object.assign(verbs, context)

      t.throws(
        () => {
          verbs.delete(1)
        },
        // eslint-disable-next-line max-len
        /Missing required `id` param for deleting a resource\. You can set it by chaining/,
        'throw that id is missing'
      )
      t.end()
    })

    t.test('should dispatch task', (t) => {
      const context = getTestContext()
      const verbs = createHttpVerbs()
      Object.assign(verbs, context)

      spy(context.store, 'dispatch')
      stub(context.store, 'getState', () => ({
        service: {
          [context.type]: {
            id: '123',
            endpoint: `/${context.type}`,
          },
        },
      }))

      verbs.delete(1)
      .then(() => {
        assertParamsResetAction(t, context)

        const taskDispatch = assertTaskAction(t, context, HTTP_DELETE)
        t.deepEqual(taskDispatch.payload, 1,
          'task dispatch has a payload')

        t.end()
      })
      .catch(t.end)
    })
  })
})
