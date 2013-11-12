class Settings
  constructor: (@_sendResponse) ->

_.each {
  filteredUsers: []
  options: {}
}, (defaultValue, key) ->
  Settings.prototype[key] = (newData) ->
    if newData?
      util.putInLocalStorage(key, newData)
      return util.defaultResponse(@_sendResponse)

    (->
      res = {}
      res[key] = util.getFromLocalStorage(key) || defaultValue
      @_sendResponse(res)
    ).apply(this, arguments)

chrome.extension.onMessage.addListener (req, __, sendResponse) ->
  settings = new Settings(sendResponse)

  for k,v of req
    settings[k] v

chrome.browserAction.onClicked.addListener (tab) ->
  optionsUrl = chrome.extension.getURL("dist/options/index.html")
  chrome.tabs.query {}, (extensionTabs) ->
    found = false
    i = 0

    while i < extensionTabs.length
      if optionsUrl is extensionTabs[i].url
        found = true
        chrome.tabs.update extensionTabs[i].id,
          selected: true

      i++
    chrome.tabs.create url: optionsUrl unless found
