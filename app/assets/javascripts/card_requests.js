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
})
