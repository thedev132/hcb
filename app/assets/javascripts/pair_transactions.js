// automatically select events on selection of invoices or LCRs

// This script is a pretty hacky tool to reduce a step in bank admin
// dashboard work when pairing common transactions with Invoice Payouts
// or Emburse Transfers. It attempts to parse out the event name from a
// selected option and select the event automatically in the events drop-down
// on behalf of the admin user.
//
// It's not designed to be resilient against future changes, but designed
// to fail gracefully if it fails.
//
// An alternative approach may have been to modify the Rails form itself
// to embed Event IDs within InvoicePayout or EmburseTransfer <select> options,
// but that turned out to be overly complicated in Rails code, so instead I moved
// the mess into this script, where maintainability is less important.

function selectEventWithName(eventName) {
  const eventSelect = document.querySelector('.event-select-target select')
  if (!eventSelect) {
    return
  }

  // NOTE: we should not eagerly pick an event for the admin user
  // if there are duplicate matches.
  const matchedEvents = []
  for (const opt of eventSelect.querySelectorAll('option')) {
    if (opt.textContent.trim() === eventName) {
      matchedEvents.push(opt)
    }
  }

  if (matchedEvents.length === 1) {
    eventSelect.value = matchedEvents[0].value
  }
}

document.addEventListener('DOMContentLoaded', () => {
  // Invoice payouts
  const invoicePayoutSelect = document.querySelector(
    '.invoicepayout-select-target select'
  )
  if (invoicePayoutSelect) {
    invoicePayoutSelect.addEventListener('change', evt => {
      const option = invoicePayoutSelect.querySelector(
        `option[value="${evt.target.value}"]`
      )
      const optionText = option.textContent

      // XXX(@thesephist): this is a bit of a hack, but
      // this is not mission-critical (just admin niceties) and works.
      // parse out event name from select text
      const PARSE_EVENTNAME_RE = /#.*\(.*, (.*), inv #.*/
      const eventName = PARSE_EVENTNAME_RE.exec(optionText)[1]
      selectEventWithName(eventName)
    })
  }

  // LCRs
  const lcrSelect = document.querySelector('.lcr-select-target select')
  if (lcrSelect) {
    lcrSelect.addEventListener('change', evt => {
      const option = lcrSelect.querySelector(
        `option[value="${evt.target.value}"]`
      )
      const optionText = option.textContent

      // XXX(@thesephist): this is a bit of a hack, but
      // this is not mission-critical (just admin niceties) and works.
      // parse out event name from select text
      const PARSE_EVENTNAME_RE = /\d* \(.*, .*, (.*)\)/
      const eventName = PARSE_EVENTNAME_RE.exec(optionText)[1]
      selectEventWithName(eventName)
    })
  }
})
