/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
  ],
  blocklist: ['container'],
  corePlugins: {
    preflight: false,
  },
  theme: {
    colors: {},
  },
  darkMode: ['selector', '[data-dark="true"]'],
}
