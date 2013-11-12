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
    chrome.extension.sendMessage(req)
