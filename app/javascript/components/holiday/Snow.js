import React from 'react'
import Snowfall from 'react-snowfall'

import createPersistedState from 'use-persisted-state'
const useSnow = createPersistedState('shallItSnow')

export default function Snow() {
  const [snow] = useSnow(true)

  return <>{snow ? <Snowfall /> : null}</>
}
