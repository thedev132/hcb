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
    fontFamily: {
      sans: [
        'system-ui',
        '-apple-system',
        'BlinkMacSystemFont',
        '"Segoe UI"',
        'Roboto',
        '"Fira Sans"',
        'Oxygen',
        'Ubuntu',
        '"Helvetica Neue"',
        'sans-serif',
      ],
      brand: [
        'ui-rounded',
        'system-ui',
        '-apple-system',
        'BlinkMacSystemFont',
        '"Segoe UI"',
        'Roboto',
        '"Fira Sans"',
        'Oxygen',
        'Ubuntu',
        '"Helvetica Neue"',
        'sans-serif',
      ],
      mono: [
        '"SFMono-Regular"',
        '"Roboto Mono"',
        'Menlo',
        'Consolas',
        'monospace',
      ],
      check: [
        '"Space Mono"',
        '"SFMono-Regular"',
        '"Roboto Mono"',
        'Menlo',
        'Consolas',
        'monospace',
      ],
    },
  },
  darkMode: ['selector', '[data-dark="true"]'],
}
