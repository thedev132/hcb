const phoneInputField = document.querySelector('#phone_raw')
const phoneInput = window.intlTelInput(phoneInputField, {
  initialCountry: 'us',
  utilsScript:
    'https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js'
})

function onSubmit() {
  document.getElementById('phone_number').value = phoneInput.getNumber()
  return true
}
