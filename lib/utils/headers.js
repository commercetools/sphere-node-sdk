import pkg from '../../package.json'

export const authorization = 'Authorization'
export const contentType = 'Content-Type'
export const contentLength = 'Content-Length'
export const userAgent = 'User-Agent'

export const formMediaType = 'application/x-www-form-urlencoded'
export const jsonMediaType = 'application/json'

export const defaultUserAgent = `${pkg.name}-${pkg.version}`
