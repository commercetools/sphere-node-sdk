import * as constants from '../../../utils/constants'

function absoluteUrl (options, endpoint) {
  const { auth, request } = options

  if (auth.credentials.projectKey)
    endpoint = '/' + auth.credentials.projectKey + endpoint

  if (request.urlPrefix) {
    const prefix = request.urlPrefix.charAt(0) === '/' ?
      request.urlPrefix : `/${request.urlPrefix}`
    endpoint = prefix + endpoint
  }

  return `${request.protocol}://${request.host}${endpoint}`
}

// TODO: some basic stuff that can be used by any service
export function fetch () {
  const endpoint = this.params.id ?
    `${this.baseEndpoint}/${this.params.id}` : this.baseEndpoint
  const url = absoluteUrl(this.options, endpoint)

  return this.queue.addTask({ method: constants.get, url })
}
