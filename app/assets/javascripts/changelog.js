$('[data-behavior~="clear_changelog"]').click(e => {
  e.preventDefault();
  document.getElementById(`HW_badge_cont`).click();
  document.getElementById(`HW_badge_cont`).click();
  window.location.href = 'https://changelog.hcb.hackclub.com/';
})