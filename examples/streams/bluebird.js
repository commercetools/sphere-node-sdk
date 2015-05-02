import Promise from 'bluebird'
import streamRequest from './lib/stream-request'
import streamResponse from './lib/stream-response'

streamRequest(Promise)
streamResponse(Promise, 'bluebird')
