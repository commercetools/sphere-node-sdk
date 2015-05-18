import { expect } from 'chai'
import * as sdk from '../lib'

describe('Public exports', () => {

  it('should export SphereClient', () => {
    expect(sdk.SphereClient).to.be.a('function')
    expect(sdk.SphereClient.name).to.equal('SphereClient')
  })

  it('should export http client', () => {
    expect(sdk.http).to.be.a('function')
    expect(sdk.http.name).to.equal('http')
  })
})
