Q = require 'q'
ChannelService = require '../../lib/services/channels'

###*
 * Describe service specific implementations
###
describe 'ChannelService', ->

  beforeEach ->
    @channels = new ChannelService

  it 'should fail if key is not defined', ->
    expect(=> @channels.ensure(undefined, 'role'))
      .toThrow new Error 'Key is required.'

  it 'should fail if role is not defined', ->
    expect(=> @channels.ensure('key', undefined))
      .toThrow new Error 'Role is required.'
