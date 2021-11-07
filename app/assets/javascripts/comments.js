$(document).on('turbo:load', function() {
  if(window.location.hash) {
    $(window.location.hash).addClass('hash-highlight')
  }
})