// TODO: some basic stuff that can be used by any service
export default {

  // should be overriden by each service
  baseEndpoint: '/',

  fetch () {
    const endpoint = this.id ?
      `${this.baseEndpoint}/${this.id}` : this.baseEndpoint
    return this.request(this.options.request.host + endpoint)
  }

}
