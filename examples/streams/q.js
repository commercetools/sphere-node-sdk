import Q from 'q'
import streamRequest from './lib/stream-request'
import streamResponse from './lib/stream-response'

streamRequest(Q.Promise)
streamResponse(Q.Promise, 'q')
