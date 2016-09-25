import test from 'tape'
import initStore from 'utils/init-store'

const fakeMiddleware = () => next => action => next(action)

test('Utils::init-store', (t) => {
  t.test('should create a redux store', (t) => {
    const store = initStore({
      projectKey: 'test',
      oauth: {
        token: 'foo',
        expiresIn: 100,
      },
      middlewares: [fakeMiddleware],
    })

    t.deepEqual(Object.keys(store),
      [
        'dispatch',
        'subscribe',
        'getState',
        'replaceReducer',
      ],
      'initialize redux store'
    )

    t.deepEqual(store.getState(),
      {
        request: {
          projectKey: 'test',
          token: 'foo',
          expiresIn: 100,
        },
        service: {},
      },
    )

    t.end()
  })

  t.test('should throw if no middleware is defined', (t) => {
    t.throws(
      () => {
        initStore()
      },
      /No middlewares found/,
      'throw if no middleware is found'
    )
    t.end()
  })
})
