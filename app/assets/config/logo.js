const { createElement: h } = require('react')

const width = 512
const widthIcon = 0.75 * width
const padding = 0.125 * width
const borderRadius = 0.25 * width

module.exports = props =>
  h(
    'div',
    {
      style: {
        boxSizing: 'border-box',
        margin: 0,
        // borderRadius,
        padding,
        width,
        height: width,
        backgroundColor: '#28ce68',
        backgroundImage: 'linear-gradient(96deg, #73eb63, #28ce68)'
      }
    },
    h('img', {
      src: 'https://icon.now.sh/account_balance/ffffff',
      style: { width: widthIcon }
    })
  )
