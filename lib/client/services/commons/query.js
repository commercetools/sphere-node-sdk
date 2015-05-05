// TODO: everything related to build queries

export function byId (id) {
  this.params.id = id
  return this
}

export function where (predicate) {
  this.params.where = predicate
  return this
}
