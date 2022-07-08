// (msw) This should be loaded syncronously (don't defer or async) before the page
// loads in. It prevents users in dark mode from getting flashed by a bright
// light when the page loads in.

;(function () {
  if (
    document.querySelector('html').getAttribute('data-ignore-theme') != null
  ) {
    // Ignore the user's theme preference
    return
  }

  const darkModeConfig = localStorage.getItem('dark')
  let darkMode = darkModeConfig == 'true'

  if (darkModeConfig === null) {
    // Bank has not stored a dark mode preference. Fallback to the browser's
    // `prefers-color-scheme` preference.
    if (
      window.matchMedia &&
      window.matchMedia('(prefers-color-scheme: dark)').matches
    ) {
      // According to the browser, the user prefers dark mode
      darkMode = true
    }

    // Asyncrhonously store the dark mode preference
    ;(async () => {
      localStorage.setItem('dark', darkMode)
    })()
  }

  if (darkMode) {
    document.querySelector('html').setAttribute('data-dark', darkMode)
  }
})()
