// Generated by CoffeeScript 1.6.3
(function() {
  chrome.browserAction.onClicked.addListener(function(tab) {
    var optionsUrl;
    optionsUrl = chrome.extension.getURL("dist/options/index.html");
    return chrome.tabs.query({}, function(extensionTabs) {
      var found, i;
      found = false;
      i = 0;
      while (i < extensionTabs.length) {
        if (optionsUrl === extensionTabs[i].url) {
          found = true;
          chrome.tabs.update(extensionTabs[i].id, {
            selected: true
          });
        }
        i++;
      }
      if (!found) {
        return chrome.tabs.create({
          url: optionsUrl
        });
      }
    });
  });

}).call(this);
