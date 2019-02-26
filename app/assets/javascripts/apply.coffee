$(document).on 'turbolinks:load', ->
  if BK.thereIs 'application_form'
    # Method for adding a hide/show for parent info
    parentToggle = (index) ->
      birthdate = new Date($('#application_team_members_' + index + '_birthdate').val())
      minorThreshold = new Date().setFullYear(new Date().getFullYear() - 18)
      isMinor = birthdate > minorThreshold
      parentInfo = $('[data-index="' + index + '"]>.parent-info')
      parentInfo.toggle(isMinor)
      parentInfo.find(':input').prop('required', isMinor)
      parentInfo.find(':input').prop('disabled', !isMinor)

    # Handle change of birthday selector
    $(document).on 'change', '[data-behavior~=birthdate]', (e) ->
      index = $(e.target).parent().parent().attr('data-index')
      parentToggle(index)

    # Remove team-member on application form
    $(document).on 'click', '[data-behavior~=remove_member]', (e) ->
      $(e.target).parent().slideUp('fast')
      setTimeout (-> $(e.target).parent().remove()), 1000

    # Add team-member on application form
    $(document).on 'click', '[data-behavior~=add_member]', ->
      newDiv = $('.member-attributes:last').clone()
      newID = Number(newDiv.data('index')) + 1
      newDiv.attr('data-index', newID)
      newDiv.fadeIn 'fast'

      incrementAttr = (div, attr) ->
        oldValue = $(div).attr(attr)
        newValue = oldValue.replace(/\d+/, newID)
        $(div).attr(attr, newValue)

      $.each newDiv.find('.field>*'), ->
        if this.tagName == 'INPUT' || this.tagName == 'SELECT'
          incrementAttr(this, 'name')
          incrementAttr(this, 'id')
          $(this).val('')
          $(this).prop('required', true)
        if this.tagName == 'LABEL'
          incrementAttr(this, 'for')
      $('.members-list').append(newDiv)
      parentToggle(newID)
