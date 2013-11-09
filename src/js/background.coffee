class Settings
  constructor: (@sendResponse) ->

  getFilteredUsers: ->
    @sendResponse(filteredUsers: util.getFromLocalStorage('filteredUsers'))

  setFilteredUsers: (filteredUsers) ->
    util.putInLocalStorage('filteredUsers', filteredUsers)
    util.defaultResponse(@sendResponse)

chrome.extension.onMessage.addListener (req, __, sendResponse) ->
  settings = new Settings(sendResponse)

  for k,v of req
    settings[k] v
