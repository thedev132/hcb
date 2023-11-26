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
  rules: {
    'react/forbid-dom-props': ['error', { forbid: ['id'] }]
  },
  globals: {
    require: 'readonly',
    PublicKeyCredential: 'readonly',
    process: 'readonly',
    AIRBRAKE_PROJECT_ID: 'readonly',
    AIRBRAKE_API_KEY: 'readonly'
  },
  settings: {
    react: {
      version: 'detect'
    }
  }
}
