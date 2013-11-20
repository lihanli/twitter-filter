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
