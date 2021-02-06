import React, { useState } from 'react'

const StripeChargeLookup = _props => {
  const [search, setSearch] = useState('')
  const [results, setResults] = useState({})

  const handleChange = async (event) => {
    console.log('change occurred')
    const searchTerm = (event.target.value || '').trim()
    await setSearch(searchTerm)

    if (searchTerm == '') { return }
    console.log(results[searchTerm])
    if (results[searchTerm] || results[searchTerm] == 'loading...') { return }
    console.log('marking as loading')

    const loadingResults = {...results}
    loadingResults[searchTerm] = 'loading...'
    await setResults(loadingResults)

    fetch(`/stripe_charge_lookup?id=${searchTerm}`).then(d => d.json()).then(data => {
      const modifiedResults = {...results}
      modifiedResults[searchTerm] = data
      setResults({...modifiedResults})
    }).catch(err => {
      const errorResults = {...results}
      errorResults[searchTerm] = 'not found!'
      setResults(modifiedResults)
      console.log(err)
    })
  }

  return (
    <>
      <input type="text" onChange={handleChange} value={search} />
      <p>
        {JSON.stringify(results[search])}
      </p>
    </>
  )
}

export default StripeChargeLookup