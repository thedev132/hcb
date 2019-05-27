$(document).on('turbolinks:load', function() {
  const currentFilter = () =>
    BK.s('filterbar_item', '[aria-selected=true]').data('name')

  const findFilterItem = name => BK.s('filterbar_item', `[data-name=${name}]`)

  const activateFilterItem = function(name) {
    BK.deselect('filterbar_item')
    return BK.select('filterbar_item', `[data-name=${name}]`)
  }

  if (BK.thereIs('filterbar')) {
    activateFilterItem('exists')
  }

  // pass in function for each record
  const filterRecords = function(valid) {
    // get all table rows that aren't excluded
    const records = BK.s('filterbar_row').not(
      '[data-behavior~=filterbar_row_exclude]'
    )
    // hide all the excluded ones
    BK.s('filterbar_row_exclude').hide()
    // hide all current ones so we can show later when they return search positive
    records.hide()
    // don't show a "there are no records here"
    BK.s('filterbar_blankslate').hide()
    // how many records have been found
    let acc = 0
    records.each(function() {
      // if the record fits our search query (see below)
      if (valid(this)) {
        $(this).css('display', 'table-row')
        // return and increment the amount of records found
        return acc++
      }
    })
    // if there are no records found, show the "there are no records"
    if (acc === 0) {
      return BK.s('filterbar_blankslate').fadeIn('fast')
    }
  }

  if (BK.thereIs('filterbar_blankslate')) {
    BK.s('filterbar_blankslate').hide()
  }

  // patch for keyboard accessibility: simulate click on enter key
  $(document).on('keyup', '[data-behavior~=filterbar_item]', function(e) {
    if (e.keyCode === 13) {
      return $(e.target).click()
    }
  })

  // if a filter button is selected
  $(document).on('click', '[data-behavior~=filterbar_item]', function() {
    // the name of the filter is either whatever is in the data, or if it for some reason exists, use the catch-all filter
    const name = $(this).data('name') || 'exists'
    // make the just-clicked button look selected
    activateFilterItem(name)
    // run the filter records function
    return filterRecords(function(record) {
      // get the data from within the filter data attribute
      const data = $(record).data('filter')
      if (name !== 'archived' && data['archived']) {
        return false
      }
      // return whatever the value is from within that json (either true or false)
      return data[name]
    })
  }) // returns true/false from currentFilter record in data-filter

  $(document).on('input', '[data-behavior~=filterbar_search]', function() {
    if (currentFilter() !== 'exists') {
      activateFilterItem('exists')
    }
    const value = $(this)
      .val()
      .toLowerCase()

    return filterRecords(function(record) {
      $(record).attr('aria-expanded', 'false')
      return (
        $(record)
          .text()
          .toLowerCase()
          .indexOf(value) > -1
      )
    })
  })

  // initial filtering out archived invoices
  filterRecords(function(record) {
    const data = $(record).data('filter')
    if (data['archived']) {
      return false
    }

    return true
  })
})
