// import pkg from '../../package.json'
// FIXME: make sure webpack has correct loader
const pkg = {
  name: 'sphere-node-sdk',
  version: '2.0.0'
}

export const authorization = 'Authorization'
export const contentType = 'Content-Type'
export const contentLength = 'Content-Length'
export const userAgent = 'User-Agent'

export const formMediaType = 'application/x-www-form-urlencoded'
export const jsonMediaType = 'application/json'

export const defaultUserAgent = `${pkg.name}-${pkg.version}`
