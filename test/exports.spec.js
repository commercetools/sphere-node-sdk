import expect from 'expect'
import * as sdk from '../lib'

describe('Public exports', () => {

  it('should export SphereClient', () => {
    expect(sdk.SphereClient).toBeA('function')
    expect(sdk.SphereClient.name).toEqual('SphereClient')
  })

  it('should export http client', () => {
    expect(sdk.http).toBeA('function')
    expect(sdk.http.name).toEqual('http')
  })
})
