// TODO: some basic stuff that can be used by any service
export function fetch () {
  const endpoint = this.params.id ?
    `${this.baseEndpoint}/${this.params.id}` : this.baseEndpoint
  return this.request(this.options.request.host + endpoint)
}
