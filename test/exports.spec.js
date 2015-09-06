import expect from 'expect'
import SphereClient from '../lib'

const { errors, http } = SphereClient

describe('Public exports', () => {

  it('should export SphereClient', () => {
    expect(SphereClient).toBeA('function')
    expect(SphereClient.name).toEqual('SphereClient')
  })

  it('should export static properties', () => {
    expect(errors).toExist()

    expect(http).toBeA('function')
    expect(http.name).toEqual('http')
  })
})
