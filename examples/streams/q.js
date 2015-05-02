import Q from 'q'
import streamResponse from './lib/stream-response'

streamResponse(Q.Promise, 'q')
