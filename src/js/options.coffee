dom =
  filteredUsersInput: $('.filtered-users-input')
  filteredUsers: $('.filtered-users')
  hideCompletelyInput: $('.hide-completely-input')
  alertsBox: $('.alerts-box')
  optionsBox: $('.options-box')
  enableInput: $('.enable-input')
  filteredPhrases: $('.filtered-phrases')
  filteredPhrasesInput: $('.filtered-phrases-input')

showSettingsSaved = ->
  alertEl = $("""
    <div class="alert alert-success">
      <span class="glyphicon glyphicon-ok"></span> Settings have been saved, reload page to see changes.
    </div>
  """)
  dom.alertsBox.html(alertEl)
  util.highlight(alertEl)

  alertEl.delay(5000).fadeOut('slow')

_.each
  filteredUsers:
    template: (screenNameEscaped) ->
      "<span class='screen-name'>@#{screenNameEscaped}</span>"
    defaultAttr: 'screenName'
    sanitizeFn: models.FilteredUser.sanitizeScreenName

  filteredPhrases:
    defaultAttr: 'phrase'
    sanitizeFn: $.trim
, (opt, dataName) ->
  req = {}
  req[dataName] = null
  chrome.extension.sendMessage req, (res) ->
    $collectionEl = dom[dataName]
    dataNameCapitalized = util.capitalize(dataName)

    collection = models.generateCollection
      collectionName: dataNameCapitalized
      data: res[dataName]
      anyChangeCb: showSettingsSaved
      events:
        add: (item) ->
          attrEscaped = _.escape(item.get(opt.defaultAttr))
          template = if opt.template then opt.template(attrEscaped) else attrEscaped
          el = $("""
            <li>
              #{template}
              <a class="close">&times;</a>
            </li>
          """).data('model', item)

          $collectionEl.append(el)

        remove: (__, ___, opt) ->
          $($collectionEl.find('li')[opt.index]).remove()

    $collectionEl.on 'click', '.close', ->
      el = $(@).parents('li')
      collection.remove(el.data('model'))

    (->
      $inputEl = dom["#{dataName}Input"]

      util.inputHandler $inputEl, ->
        item = models.generateModelWithSanitizer
          Model: models[dataNameCapitalized].prototype.model
          attr: opt.defaultAttr
          sanitizeFn: opt.sanitizeFn
        item.set(opt.defaultAttr, $inputEl.val())
        return unless item.isValid()
        collection.add(item)
    )()

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
