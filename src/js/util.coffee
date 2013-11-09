util =
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

root = exports ? window
root.util = util
