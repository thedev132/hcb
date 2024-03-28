/** @type {import('tailwindcss').Config} */
module.exports = {
  // DO NOT UNCOMMENT YET— this will cause Tailwind to override some classes we already have
  //
  // content: [
  //   './app/views/**/*.html.erb',
  //   './app/helpers/**/*.rb',
  //   './app/assets/stylesheets/**/*.css',
  //   './app/javascript/**/*.js'
  // ],
  safelist: [
    'relative',
    'absolute',
    'fixed',
    'top-0',
    'right-0',
    'bottom-0',
    'left-0',
    'rounded-full',
    'rounded-b',
    'rounded-t',
    'flex',
    'inline-flex',
    'flex-wrap',
    'flex-none',
    'flex-row',
    'flex-col',
    'align-top',
    'align-middle',
    'align-bottom',
    'mx-auto',
    'ml-auto',
    'mr-auto',
    'font-mono',
  ],
  corePlugins: {
    preflight: false,
  },
  theme: {
    colors: {},
  },
  darkMode: ['selector', '[data-dark="true"]'],
}
