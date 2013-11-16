dom =
  filteredUserInput: $('.filtered-user-input')
  filteredUsers: $('.filtered-users')
  hideCompletelyInput: $('.hide-completely-input')
  alertsBox: $('.alerts-box')
  optionsBox: $('.options-box')
  enableInput: $('.enable-input')
  filteredText: $('.filtered-text')
  filteredTextInput: $('.filtered-text-input')

showSettingsSaved = ->
  alertEl = $("""
    <div class="alert alert-success">
      <span class="glyphicon glyphicon-ok"></span> Settings have been saved, reload page to see changes.
    </div>
  """)
  dom.alertsBox.html(alertEl)
  util.highlight(alertEl)

  alertEl.delay(5000).fadeOut('slow')

chrome.extension.sendMessage filteredPhrases: null, (res) ->
  filteredPhrases = models.generateCollection
    collectionName: 'FilteredPhrases'
    data: res.filteredPhrases
    anyChangeCb: showSettingsSaved
    events:
      add: (filteredPhrase) ->
        el = $("""
          <li>
            #{_.escape(filteredPhrase.get('phrase'))}
            <a class="close">&times;</a>
          </li>
        """).data('model', filteredPhrase)

        dom.filteredText.append(el)

      remove: (__, ___, opt) ->
        $(dom.filteredText.find('li')[opt.index]).remove()

  dom.filteredText.on 'click', '.close', ->
    el = $(@).parents('li')
    filteredPhrases.remove(el.data('model'))

  util.inputHandler dom.filteredTextInput, ->
    filteredPhrase = new models.FilteredPhrase(phrase: dom.filteredTextInput.val())
    return unless filteredPhrase.isValid()
    filteredPhrases.add(filteredPhrase)

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

      remove: (__, ___, opt) ->
        $(dom.filteredUsers.find('li')[opt.index]).remove()

  dom.filteredUsers.on 'click', '.close', ->
    el = $(@).parents('li')
    filteredUsers.remove(el.data('model'))

  util.inputHandler dom.filteredUserInput, ->
    filteredUser = new models.FilteredUser(screenName: dom.filteredUserInput.val())
    return unless filteredUser.isValid()
    filteredUsers.add(filteredUser)

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
