module.exports = {
  env: {
    browser: true,
    es2021: true
  },
  ignorePatterns: ['.eslintrc.js', 'webpack.config.js'],
  extends: ['eslint:recommended', 'plugin:react/recommended'],
  overrides: [],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  plugins: ['react'],
  rules: {},
  globals: {
    require: 'readonly',
    PublicKeyCredential: 'readonly'
  },
  settings: {
    react: {
      version: 'detect'
    }
  }
}
