function absoluteUrl (options, endpoint) {
  if (options.urlPrefix)
    endpoint = options.urlPrefix + endpoint
  return `${options.protocol}://${options.host}${endpoint}`
}

// TODO: some basic stuff that can be used by any service
export function fetch () {
  const endpoint = this.params.id ?
    `${this.baseEndpoint}/${this.params.id}` : this.baseEndpoint
  const url = absoluteUrl(this.options.request, endpoint)

  // return this.queue.addTask(() => {
  //   return new Promise((resolve, reject) => {
  //     this.http.get(url)
  //       .then(res => resolve(res))
  //       .catch(e => reject(e))
  //   })
  // })
  return this.http.get(url)
}
