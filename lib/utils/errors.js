class SphereError extends Error {
  constructor (message, body = {}) {
    super(message)

    this.message = message
    this.name = 'SphereError'
    this.body = body
    if (body.statusCode) {
      this.statusCode = body.statusCode
      // For backwards compatibility
      this.code = this.statusCode
    }

    Error.captureStackTrace(this, SphereError)
  }
}

export { SphereError }
