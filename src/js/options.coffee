dom =
  filteredUserInput: $('.filtered-user-input')
  filteredUsers: $('.filtered-users')
  hideCompletelyInput: $('.hide-completely-input')
  alertsBox: $('.alerts-box')
  optionsBox: $('.options-box')
  enableInput: $('.enable-input')

showSettingsSaved = ->
  alertEl = $("""
    <div class="alert alert-success">
      <span class="glyphicon glyphicon-ok"></span> Settings have been saved, reload page to see changes.
    </div>
  """)
  dom.alertsBox.html(alertEl)
  util.highlight(alertEl)

  alertEl.delay(5000).fadeOut('slow')

chrome.extension.sendMessage filteredUsers: null, (res) ->
  filteredUsers = models.generateCollection
    collectionName: 'FilteredUsers'
    data: res.filteredUsers
    anyChangeCb: showSettingsSaved
    events:
      add: (filteredUser) ->
        el = $("""
          <li>
            <span class="screen-name">@#{_.escape(filteredUser.get('screenName'))}</span>
            <a class="close">&times;</a>
          </li>
        """).data('model', filteredUser)

        dom.filteredUsers.append(el)

      remove: (filteredUser, __, opt) ->
        $(dom.filteredUsers.find('li')[opt.index]).remove()

  dom.filteredUsers.on 'click', '.close', ->
    el = $(@).parents('li')
    filteredUsers.remove(el.data('model'))

  dom.filteredUserInput.keypress (e) ->
    if e.keyCode == 13
      filteredUser = new models.FilteredUser(screenName: dom.filteredUserInput.val())

      return unless filteredUser.isValid()

      filteredUsers.add(filteredUser)
      dom.filteredUserInput.val('')

chrome.extension.sendMessage options: null, (res) ->
  options = new models.Options(res.options)
  checkBoxes =
    hideCompletely: null
    enable: (val) ->
      dom.optionsBox[if val then 'show' else 'hide']()

  _.each checkBoxes, (cb, attr) ->
    $el = dom["#{attr}Input"]

    options.on "renderAll change:#{attr}", ->
      val = @.get(attr)
      $el.prop('checked', val)
      cb(val) if cb

    $el.change ->
      options.set(attr, $el.prop('checked'))

  options.trigger('renderAll')

  options.on 'change', ->
    util.saveToBg('options', options)
    showSettingsSaved()

$('[data-toggle="tooltip"]').tooltip()
