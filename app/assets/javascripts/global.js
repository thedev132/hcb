// BK is our global namespace for utilities
const BK = {
  blocked: false
}
// BK.s('some_behavior') is a shortcut for selecting elements by data-behavior
BK.s = (selector, filter = '') =>
  $(`[data-behavior~=${selector}]`).filter(
    filter.length > 0 ? filter : () => true
  )
BK.thereIsNot = (selector, filter) => BK.s(selector, filter).is(':empty')
BK.thereIs = (selector, filter) => !BK.thereIsNot(selector, filter)

BK.deselect = (selector, filter = '[aria-selected=true]') =>
  BK.s(selector, filter).attr('aria-selected', false)
BK.select = (selector, filter) =>
  BK.s(selector, filter).attr('aria-selected', true)

// document.getElementsByTagName('html')[0].getAttribute('data-dark') === 'true'
BK.isDark = () => {
  try {
    return localStorage.getItem('dark') === 'true'
  } catch(e) {
    return false
  }
}
BK.styleDark = theme => {
  document.getElementsByTagName('html')[0].setAttribute('data-dark', theme)
  document.querySelector('meta[name=theme-color]').setAttribute('content', theme ? '#17171d' : '#f9fafc')
  BK.s('toggle_theme').find('svg').toggle()
}
BK.toggleDark = () => {
  theme = !BK.isDark()
  window.dispatchEvent(new CustomEvent('theme-toggle', { detail: theme }))
  return BK.setDark(theme)
}
BK.setDark = dark => {
  theme = !!dark

  // animate background color
  // not in base CSS because otherwise theme restore has background animation on load
  $('body').css({
    transition: 'background-color 0.125s ease-in-out, color 0.0625s ease-in-out'
  })
  BK.styleDark(theme)
  localStorage.setItem('dark', theme)
  return theme
}

// Listen for Browser dark mode preference changes (`prefers-color-scheme`)
if (window.matchMedia) {
  window
    .matchMedia('(prefers-color-scheme: dark)')
    .addEventListener('change', e => {
      // This will only be called on changes (not during initial page load)
      const prefersDarkMode = e.matches
      BK.setDark(prefersDarkMode)
    })
}

// Attempt to load Fullstory
$(document).ready(() => {
  setTimeout(() => {
    if (typeof FS === 'undefined') {
      BK.blocked = true
    } else {
      fetch('https://rs.fullstory.com/rec/page', { method: 'POST' })
        .then(res => {
          if (!res.ok) {
            BK.blocked = true
          }
        })
        .catch(() => {
          BK.blocked = true
        })
    }
  }, 3000)
})

// https://css-tricks.com/snippets/jquery/get-query-params-object/
BK.getQueryParams = () => {
  const result = {}
  const kvPairs = window.location.search.substr(1).split('&')
  for (let i = 0; i < kvPairs.length; i++) {
    const [k, v] = kvPairs[i].split('=')
    if (k) {
      result[k] = decodeURIComponent(v)
    }
  }
  return result
}

BK.money = amount => {
  if (typeof amount !== 'number') return '–'
  const localAmount = Math.abs(Math.round(amount) / 100).toLocaleString()
  const sign = Math.sign(amount) === -1 ? '-' : ''
  return `${sign}$${localAmount}`
}
