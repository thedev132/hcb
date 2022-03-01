import axios from 'axios'

const HttpClient = axios.create()

HttpClient.interceptors.request.use(
  request => {
    const csrfTokenSelector = document.querySelector('[name=csrf-token]')
    // injects CSRF token
    if (csrfTokenSelector && csrfTokenSelector.content) {
      request.headers['X-CSRF-TOKEN'] = csrfTokenSelector.content
    }
    return request
  },
  error => error
  // error => Promise.reject(error)
)

export default HttpClient
