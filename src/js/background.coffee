class Settings
  constructor: (@_sendResponse) ->

  filteredUsers: (filteredUsers) ->
    if filteredUsers?
      util.putInLocalStorage('filteredUsers', filteredUsers)
      return util.defaultResponse(@_sendResponse)

    @_sendResponse(filteredUsers: util.getFromLocalStorage('filteredUsers') || [])

chrome.extension.onMessage.addListener (req, __, sendResponse) ->
  settings = new Settings(sendResponse)

  for k,v of req
    settings[k] v
