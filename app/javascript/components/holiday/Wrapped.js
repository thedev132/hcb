import React from 'react'
import HCBWrapped from '@hackclub/hcb-wrapped'
import PropTypes from 'prop-types'

export default function Wrapped({ data }) {
  return <HCBWrapped data={data} />
}

Wrapped.propTypes = {
  data: PropTypes.object.isRequired,
}
