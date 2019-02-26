$(document).on 'turbolinks:load', ->
  if BK.thereIs 'application_form'
    # Method for adding a hide/show for parent info
    parentToggle = (index) ->
      b0 = $($('[data-index="' + index + '"]>.birthdate-selector').children()[0]).val()
      b1 = $($('[data-index="' + index + '"]>.birthdate-selector').children()[1]).val()
      b2 = $($('[data-index="' + index + '"]>.birthdate-selector').children()[2]).val()
      birthdate = new Date(b0, b1, b2)

      minorThreshold = new Date().setFullYear(new Date().getFullYear() - 18)
      isMinor = birthdate > minorThreshold
      parentInfo = $('[data-index="' + index + '"]>.parent-info')
      parentInfo.toggle(isMinor)
      parentInfo.find(':input').prop('required', isMinor)
      parentInfo.find(':input').prop('disabled', !isMinor)

    # Handle change of birthday selector
    $(document).on 'change', '[data-behavior~=birthdate_selector]', (e) ->
      index = $(e.target).parent().parent().attr('data-index')
      parentToggle(index)

    # Add team-member on application form
    $(document).on 'click', '[data-behavior~=add_member]', ->
      newDiv = $('.member-attributes:last').clone()
      newID = Number(newDiv.data('index')) + 1
      newDiv.attr('data-index', newID)

      incrementAttr = (div, attr) ->
        oldValue = $(div).attr(attr)
        newValue = oldValue.replace(/\d+/, newID)
        $(div).attr(attr, newValue)

      $.each newDiv.children(), ->
        if this.tagName == 'INPUT' || this.tagName == 'SELECT'
          incrementAttr(this, 'name')
          incrementAttr(this, 'id')
          $(this).val('')
        if this.tagName == 'LABEL'
          incrementAttr(this, 'for')
      $('.members-list').append(newDiv)
      parentToggle(newID)
