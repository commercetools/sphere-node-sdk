export default function processResponse (response) {
  if (response.ok)
    return response.json().then(body => ({
      statusCode: response.status,
      headers: parseHeaders(response.headers),
      body,
    }))

  return response.text().then(rawBody => {
    let jsonResponse
    try {
      jsonResponse = JSON.parse(rawBody)
    } catch (error) { /* noop */ }

    const error = new Error(jsonResponse ? jsonResponse.message : rawBody)
    error.statusCode = response.status
    error.headers = parseHeaders(response.headers)
    error.body = jsonResponse || rawBody
    throw error
  })
}


function parseHeaders (headers) {
  if (headers.raw)
    // node-fetch
    return headers.raw()

  // Tmp fix for Firefox until it supports iterables
  if (!headers.forEach) return {}

  // whatwg-fetch
  const map = {}
  headers.forEach((value, name) => {
    map[name] = value
  })
  return map
}
