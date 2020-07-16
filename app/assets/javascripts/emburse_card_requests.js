// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('turbolinks:load', function() {
  $('#lcr_blank').hide()

  function toggleLcrs() {
    var count = 0

    $('[id=lcr_row]')
      .toArray()
      .forEach(row => {
        var attr = $(row).attr('under-review')
        if (attr !== '') {
          $(row).toggle()
        } else {
          count++
        }
      })

    if (count == 0) {
      $('#lcr_blank').toggle()
      $('#lcr_table').toggle()
    }
  }

  $('#show_lcrs').click(e => {
    toggleLcrs()
    let currentText = $('#show_lcrs').text()

    if (currentText == 'Show all') {
      $('#show_lcrs').text('Show pending')
    } else {
      $('#show_lcrs').text('Show all')
    }
  })

  toggleLcrs()

  const shipping_address_inputs = document.querySelector('.shipping_address_inputs')
  const virtual_card_inputs = document.querySelector('.virtual_card_inputs')
  $(virtual_card_inputs).hide()
  if (shipping_address_inputs) {
    const is_virtual_checkbox = document.querySelector('#emburse_card_request_is_virtual')
    is_virtual_checkbox.addEventListener('change', evt => {
      if (evt.target.checked) {
        $(shipping_address_inputs).hide()
        $(virtual_card_inputs).show()
      } else {
        $(shipping_address_inputs).show()
        $(virtual_card_inputs).hide()
      }
    })
  }
})
