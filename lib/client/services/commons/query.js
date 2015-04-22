// TODO: everything related to build queries
export default Object.freeze({

  byId (id) {
    const copy = Object.assign({}, this)
    copy.id = id
    return Object.freeze(copy)
  },

  where (predicate) {
    const copy = Object.assign({}, this)
    copy.where = predicate
    return Object.freeze(copy)
  }

})
