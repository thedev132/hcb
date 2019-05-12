# restore previous theme setting
$(document).ready ->
  BK.styleDark(true) if localStorage.getItem('dark') is 'true'

$(document).on 'turbolinks:load', ->
  $(document).on 'click', '[data-behavior~=toggle_theme]', ->
    BK.toggleDark()

  hankIndex = 0
  $(document).on 'keydown', (e) ->
    if e.originalEvent.key == 'hank'[hankIndex]
      hankIndex++
      if hankIndex == 4
        $('[name="header-logo"]').hide()
        $('[name="alternative-logo"]').show()
    else
      hankIndex = 0

  $(document).on 'click', '[data-behavior~=flash]', ->
    $(this).fadeOut 'medium'

  currentFilter = ->
    BK.s('filterbar_item', '[aria-selected=true]').data('name')

  findFilterItem = (name) ->
    BK.s 'filterbar_item', "[data-name=#{name}]"

  activateFilterItem = (name) ->
    BK.deselect 'filterbar_item'
    BK.select 'filterbar_item', "[data-name=#{name}]"

  activateFilterItem 'exists' if BK.thereIs 'filterbar'

  # pass in function for each record
  filterRecords = (valid) ->
    records = BK.s('filterbar_row').not('[data-behavior~=filterbar_row_exclude]')
    BK.s('filterbar_row_exclude').hide()
    records.hide()
    BK.s('filterbar_blankslate').hide()
    acc = 0
    records.each ->
      if valid(this)
        $(this).show(
          "slow", ->
            $(this).css("display", "table-row")
        )
        acc++
    if acc is 0
      BK.s('filterbar_blankslate').fadeIn 'fast'
  
  if BK.thereIs 'filterbar_blankslate'
    BK.s('filterbar_blankslate').hide()

  # patch for keyboard accessibility: simulate click on enter key
  $(document).on 'keyup', '[data-behavior~=filterbar_item]', (e) ->
    $(e.target).click() if e.keyCode is 13

  $(document).on 'click', '[data-behavior~=filterbar_item]', ->
    name = $(this).data('name') or 'exists'
    activateFilterItem name
    filterRecords (record) ->
      data = $(record).data('filter')
      data[name] # returns true/false from currentFilter record in data-filter

  $(document).on 'input', '[data-behavior~=filterbar_search]', ->
    activateFilterItem('exists') if currentFilter() isnt 'exists'
    value = $(this).val().toLowerCase()
    filterRecords (record) ->
      $(record).text().toLowerCase().indexOf(value) > -1
      $(record).attr 'aria-expanded', 'false'
  
  $(document).on 'click', '[data-behavior~=row_expand_trigger]', ->
    button = $(this)
    id = button.data 'id'
    targets = BK.s('expandable_row').filter("[data-id=#{id}]")
    expanded = button.data 'expanded'
    if expanded
      targets.removeClass('is-expanded')
      button.text 'Expand'
      button.data 'expanded', false
    else
      targets.addClass('is-expanded')
      button.text 'Retract'
      button.data 'expanded', true

  $(document).on 'submit', '[data-behavior~=login]', ->
    val = $('input[name=email]').val()
    localStorage.setItem 'login_email', val

  if BK.thereIs 'login'
    if email = localStorage.getItem 'login_email'
      BK.s('login').find('input[type=email]').val email
  
  $(document).on 'change', '[name="invoice[sponsor]"]', (e) ->
    sponsor = $(e.target).children('option:selected').data 'json'
    sponsor ||= {}

    if sponsor.id
      $('[data-behavior~=sponsor_update_warning]').slideDown 'fast'
    else
      $('[data-behavior~=sponsor_update_warning]').slideUp 'fast'

    fields = [
      'name',
      'contact_email',
      'address_line1',
      'address_line2',
      'address_city',
      'address_state',
      'address_postal_code',
      'id'
    ]

    fields.forEach (field) ->
      $("input#invoice_sponsor_attributes_#{field}").val sponsor[field]

  updateAmountPreview = ->
    amount = $('[name="invoice[item_amount]"]').val()
    previousAmount = BK.s('amount-preview').data('amount') || 0
    if amount == previousAmount
      return 
    if amount > 0
      feePercent = BK.s('amount-preview').data 'fee'
      lFeePercent = Math.round(feePercent * 100)
      lAmount = BK.money amount * 100
      feeAmount = BK.money feePercent * amount * 100
      revenue = BK.money (1 - feePercent) * amount * 100
      BK.s('amount-preview').text "#{lAmount} - #{feeAmount} (#{lFeePercent}% Bank fee) = #{revenue}"
      BK.s('amount-preview').show()
      BK.s('amount-preview').data 'amount', amount
    else
      BK.s('amount-preview').hide()
      BK.s('amount-preview').data 'amount', 0

  $(document).on 'keyup', '[name="invoice[item_amount]"]', ->
    updateAmountPreview()
  $(document).on 'change', '[name="invoice[item_amount]"]', ->
    updateAmountPreview()

  $(document).on 'keydown', '[data-behavior~=autosize]', ->
    t = this
    setTimeout (->
      $(t).attr { rows: Math.floor(t.scrollHeight / 28) }
      $(t).css { height: 'auto' }
    ), 0
