root = exports ? window

root.util =
  getFromLocalStorage: (key) ->
    value = localStorage[key]
    return JSON.parse(value) if value
    null

  putInLocalStorage: (key, value) ->
    localStorage[key] = JSON.stringify(value)

  defaultResponse: (sendResponse) ->
    sendResponse(OK: true)

  isBlank: (str) ->
    !str || /^\s*$/.test(str)

  convertToBackboneArr: (Model, arr) ->
    _.map arr, (item) ->
      new Model(item)

  saveToBg: (key, model) ->
    req = {}
    req[key] = model.toJSON()
    chrome.storage.sync.set(req)

  highlight: ($el) ->
    $el.effect('highlight', { color: '#A9F5BC' }, 500)

  uncapitalize: (str) ->
    str.charAt(0).toLowerCase() + str.slice(1)

  capitalize: (str) ->
    str.charAt(0).toUpperCase() + str.slice(1)

  inputHandler: ($el, cb) ->
    $el.keypress (e) ->
      if e.keyCode == 13
        cb.call(@)
        $el.val('')
