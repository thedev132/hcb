//= require jquery3
//= require jquery_ujs
//= require activestorage
//= require turbolinks

// BK is our global namespace for utilities
const BK = {
  blocked: false
}

// Disable use without FullStory
$(document).ready(() => {
  // BK.s('some_behavior') is a shortcut for selecting elements by data-behavior
  BK.s = selector => $(`[data-behavior~=${selector}]`)

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
  }, 4000)
  setTimeout(() => {
    if (BK.blocked) {
      const body = document.getElementsByTagName('body')
      body[0].remove()
      alert(
        'Hack Club Bank is still in development. To continue improving the product, it’s crucial for us to debug any issues that arise, but your adblocker is currently blocking our bug reporting + analytics. Please unblock to continue using the app.'
      )
    }
  }, 4500)
})
