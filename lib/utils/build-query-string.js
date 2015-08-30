/**
 * Build the query string with the given parameters
 * @param  {Object} queryParams - An object with query parameters
 * @throws If argument is missing.
 * @return {string} The fully encoded query string.
 */
export default function buildQueryString (queryParams) {
  if (!queryParams)
    throw new Error('Missing options object to build query string.')

  const { expand, operator, page, perPage, sort, where } = queryParams

  const whereParams = where.join(encodeURIComponent(` ${operator} `))

  let queryString = []
  if (whereParams)
    queryString.push(`where=${whereParams}`)
  if (perPage)
    queryString.push(`limit=${perPage}`)
  if (page) {
    const limitParam = perPage || 20
    const offsetParam = limitParam * (page - 1)
    queryString.push(`offset=${offsetParam}`)
  }
  if (sort)
    queryString = queryString.concat(sort.map(s => `sort=${s}`))
  if (expand)
    queryString = queryString.concat(expand.map(e => `expand=${e}`))

  return queryString.join('&')
}
