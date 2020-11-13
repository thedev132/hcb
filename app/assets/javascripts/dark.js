// (msw) This should be loaded syncronously (don't defer or async) before the page
// loads in. It prevents users in dark mode from getting flashed by a bright
// light when the page loads in.

(
  function() {
    const darkMode = localStorage.getItem('dark') == 'true'
    if (darkMode) {
      document.querySelector('html').setAttribute('data-dark', darkMode)
    }
  }()
)