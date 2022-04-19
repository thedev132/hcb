/**
 * Creates and submits a hidden form with the given parameters as inputs.
 *
 * @param {string} url
 * @param {Object} params
 */
export default function submitForm(url, params) {
  const form = document.createElement('form')
  form.action = url
  form.method = 'POST'
  form.style.display = 'none'

  const csrfParam = document
    .querySelector('meta[name="csrf-param"]')
    .getAttribute('content')
  const csrfToken = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')

  params[csrfParam] = csrfToken

  for (const key in params) {
    const value = params[key]

    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = key
    input.value = value

    form.appendChild(input)
  }

  document.body.appendChild(form)

  form.submit()
}
