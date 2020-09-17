// restore previous theme setting
$(document).ready(function () {
  if (localStorage.getItem('dark') === 'true') {
    BK.s('toggle_theme').find('svg').toggle()
  }
  if (localStorage.getItem('dark') === 'true') {
    return BK.styleDark(true)
  }
})

$(document).on('turbolinks:load', function () {
  $('[data-behavior~=toggle_theme]').on('click', () => BK.toggleDark())

  if (window.location !== window.parent.location) {
    $('[data-behavior~=hide_iframe]').hide()
  }

  $('[data-behavior~=select_content]').on('click', e => e.target.select())

  $(document).on('click', '[data-behavior~=flash]', function () {
    $(this).fadeOut('medium')
  })

  $(document).on('click', '[data-behavior~=modal_trigger]', function (e) {
    if ($(this).attr('href')) e.preventDefault()
    BK.s('modal', '#' + $(this).data('modal')).modal()
    return this.blur()
  })

  $(document).on('click', '[data-behavior~=row_expand_trigger]', function () {
    const button = $(this)
    const id = button.data('id')
    const targets = BK.s('expandable_row').filter(`[data-id=${id}]`)
    const parent = BK.s('parent_expandable_row').filter(`[data-id=${id}]`)
    const expanded = button.data('expanded')
    if (expanded) {
      targets.removeClass('is-expanded')
      parent.removeClass('is-expanded')
      button.text('Expand')
      return button.data('expanded', false)
    } else {
      targets.addClass('is-expanded')
      parent.addClass('is-expanded')
      button.text('Retract')
      return button.data('expanded', true)
    }
  })

  $(document).on('keyup', 'action', function (e) {
    if (e.keyCode === 13) {
      return $(e.target).click()
    }
  })

  $(document).on('submit', '[data-behavior~=login]', function () {
    const val = $('input[name=email]').val()
    return localStorage.setItem('login_email', val)
  })

  if (BK.thereIs('login')) {
    let email
    const val = $('input[name=email]').val()

    if (val === '' || val === undefined) {
      if ((email = localStorage.getItem('login_email'))) {
        BK.s('login').find('input[type=email]').val(email)
      }
    }
  }

  // login code sanitization
  $("input[name='login_code']").keyup(function () {
    let currentVal = $(this)
      .val()
      .replace(/[^0-9]+/g, '')

    if (currentVal.length > 3) {
      currentVal = currentVal.slice(0, 3) + '-' + currentVal.slice(3)
    }

    if (currentVal.length > 7) {
      currentVal = currentVal.slice(0, -1)
    }

    return $(this).val(currentVal)
  })

  // if you add the money behavior to an input, it'll add commas, only allow two numbers for cents,
  // and only permit numbers to be entered
  $('input[data-behavior~=money]').on('input', function () {
    let value = $(this)
      .val()
      .replace(/,/g, '') // replace all commas with nothing
      .replace(/[^0-9.]+/g, '') // replace anything that isn't a number or a dot with nothing
      .replace(/\B(?=(\d{3})+(?!\d))/g, ',') // put commas into the number (pulled off of stack overflow)

    let removeExtraCents

    if (value.lastIndexOf('.') != -1) {
      let cents = value.substring(value.lastIndexOf('.'), value.length)
      cents = cents
        .replace(/[\.\,]/g, '')
        .substring(0, cents.length > 2 ? 2 : 1)

      removeExtraCents =
        value.substring(0, value.lastIndexOf('.')) + '.' + cents
    } else {
      removeExtraCents = value
    }

    $(this).val(removeExtraCents)
  })

  $('input[data-behavior~=prevent_whitespace]').on({
    keydown: function (e) {
      if (e.which === 32) return false
    },
    change: function () {
      this.value = this.value.replace(/\s/g, '')
    }
  })

  $(document).on('change', '[name="invoice[sponsor]"]', function (e) {
    let sponsor = $(e.target).children('option:selected').data('json')
    if (!sponsor) {
      sponsor = {}
    }

    if (sponsor.id) {
      $('[data-behavior~=sponsor_update_warning]').slideDown('fast')
    } else {
      $('[data-behavior~=sponsor_update_warning]').slideUp('fast')
    }

    const fields = [
      'name',
      'contact_email',
      'address_line1',
      'address_line2',
      'address_city',
      'address_state',
      'address_postal_code',
      'id'
    ]

    return fields.forEach(field =>
      $(`input#invoice_sponsor_attributes_${field}`).val(sponsor[field])
    )
  })

  $(document).on('change', '[name="check[lob_address]"]', function (e) {
    let lob_address = $(e.target).children('option:selected').data('json')
    if (!lob_address) {
      lob_address = {}
    }

    if (lob_address.id) {
      $('[data-behavior~=lob_address_update_warning]').slideDown('fast')
    } else {
      $('[data-behavior~=lob_address_update_warning]').slideUp('fast')
    }

    const fields = [
      'name',
      'address1',
      'address2',
      'city',
      'state',
      'zip',
      'id'
    ]

    return fields.forEach(field =>
      $(`input#check_lob_address_attributes_${field}`)
        .val(lob_address[field])
        .change()
    )
  })

  const updateAmountPreview = function () {
    const amount = $('[name="invoice[item_amount]"]').val().replace(/,/g, '')
    const previousAmount = BK.s('amount-preview').data('amount') || 0
    if (amount === previousAmount) {
      return
    }
    if (amount > 0) {
      const feePercent = BK.s('amount-preview').data('fee')
      const lFeePercent = (feePercent * 100).toFixed(1)
      const lAmount = BK.money(amount * 100)
      const feeAmount = BK.money(feePercent * amount * 100)
      const revenue = BK.money((1 - feePercent) * amount * 100)
      BK.s('amount-preview').text(
        `${lAmount} - ${feeAmount} (${lFeePercent}% Bank fee) = ${revenue}`
      )
      BK.s('amount-preview').show()
      return BK.s('amount-preview').data('amount', amount)
    } else {
      BK.s('amount-preview').hide()
      return BK.s('amount-preview').data('amount', 0)
    }
  }

  $(document).on('keyup', '[name="invoice[item_amount]"]', () =>
    updateAmountPreview()
  )
  $(document).on('change', '[name="invoice[item_amount]"]', () =>
    updateAmountPreview()
  )

  $(document).on('keydown', '[data-behavior~=autosize]', function () {
    const t = this
    return setTimeout(function () {
      $(t).attr({ rows: Math.floor(t.scrollHeight / 28) })
      return $(t).css({ height: 'auto' })
    }, 0)
  })

  // Popover menus
  BK.openMenuSelector = '[data-behavior~=menu_toggle][aria-expanded=true]'
  BK.toggleMenu = function (m) {
    $(m).find('[data-behavior~=menu_content]').slideToggle(100)
    const o = $(m).attr('aria-expanded') === 'true'
    return $(m).attr('aria-expanded', !o)
  }

  $(document).on('click', function (e) {
    const o = $(BK.openMenuSelector)
    const c = $(e.target).closest('[data-behavior~=menu_toggle]')
    if (o.length > 0 || c.length > 0) {
      BK.toggleMenu(o.length > 0 ? o : c)
    }
    e.stopImmediatePropagation()
  })
  $(document).keydown(function (e) {
    // Close popover menus on esc
    if (e.keyCode === 27 && $(BK.openMenuSelector).length > 0) {
      return BK.toggleMenu($(BK.openMenuSelector))
    }
  })

  const tiltElement = $('[data-behavior~=hover_tilt]')
  const enableTilt = () =>
    tiltElement.tilt({
      maxTilt: 15,
      speed: 400,
      perspective: 1500,
      glare: true,
      maxGlare: 0.25,
      scale: 1.0625
    })
  const disableTilt = () => tiltElement.tilt.destroy.call(tiltElement)
  const setTilt = function () {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      return disableTilt()
    } else {
      return enableTilt()
    }
  }
  setTilt()
  return window
    .matchMedia('(prefers-reduced-motion: reduce)')
    .addListener(() => setTilt())
})
