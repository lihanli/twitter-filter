dom =
  filteredUsersInput: $('.filtered-users-input')
  filteredUsers: $('.filtered-users')
  hideCompletelyInput: $('.hide-completely-input')
  alertsBox: $('.alerts-box')
  optionsBox: $('.options-box')
  enableInput: $('.enable-input')
  filteredPhrases: $('.filtered-phrases')
  filteredPhrasesInput: $('.filtered-phrases-input')
  hideMentionsInput: $('.hide-mentions-input')

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
      "<a href='http://twitter.com/#{screenNameEscaped}' target='_blank' class='screen-name'>@#{screenNameEscaped}</a>"
    defaultAttr: 'screenName'

  filteredPhrases:
    defaultAttr: 'phrase'
, (opt, dataName) ->
  chrome.storage.sync.get dataName, (res) ->
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
            <li class="filtered-item">
              #{template}
              <span class="close-box">
                <a class="close">&times;</a>
              </span>
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
        item.set(opt.defaultAttr, $inputEl.val())
        return unless item.isValid()
        collection.add(item)
    )()

chrome.storage.sync.get options: {}, (res) ->
  options = new models.Options(res.options)
  checkBoxes =
    hideCompletely: null
    enable: (val) ->
      dom.optionsBox[if val then 'show' else 'hide']()
    hideMentions: null

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
