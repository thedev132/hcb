$(document).on 'turbolinks:load', ->
  $(document).on 'click', '[data-behavior~=flash]', ->
    $(this).fadeOut 'medium'

  currentFilter = ->
    BK.s('transactions_filter_item', '[aria-selected=true]').data('name')

  findFilterItem = (name) ->
    BK.s 'transactions_filter_item', "[data-name=#{name}]"

  activateFilterItem = (name) ->
    BK.deselect 'transactions_filter_item'
    BK.select 'transactions_filter_item', "[data-name=#{name}]"

  activateFilterItem 'exists' if BK.thereIs 'transactions_filter'

  # pass in function for each record
  filterRecords = (valid) ->
    records = BK.s('transactions_item').hide()
    records.each ->
      $(this).show() if valid(this)
  
  # patch for keyboard accessibility: simulate click on enter key
  $(document).on 'keyup', '[data-behavior~=transactions_filter_item]', (e) ->
    $(e.target).click() if e.keyCode is 13

  $(document).on 'click', '[data-behavior~=transactions_filter_item]', ->
    name = $(this).data('name') or 'exists'
    activateFilterItem name
    filterRecords (record) ->
      data = $(record).data('filter')
      data[name] # returns true/false from currentFilter record in data-filter

  $(document).on 'input', '[data-behavior~=transactions_search]', ->
    activateFilterItem('exists') if currentFilter() isnt 'exists'
    value = $(this).val().toLowerCase()
    filterRecords (record) ->
      $(record).text().toLowerCase().indexOf(value) > -1
