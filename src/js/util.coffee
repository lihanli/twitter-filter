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

  generateTwitterUsers: (opt = {}) ->
    opt.events = {} unless opt.events?

    twitterUsers = new root.models.TwitterUsers()

    for evt, cb of opt.events
      twitterUsers.on(evt, cb)

    twitterUsers.add(util.convertToBackboneArr(root.models.TwitterUser, opt.users))

    twitterUsers.on 'change reset add remove', (__, collection) ->
      chrome.extension.sendMessage(filteredUsers: collection.toJSON())

    twitterUsers

root.models =
  TwitterUser: Backbone.Model.extend
    initialize: ->
      @.set(screenName: @.get('screenName').toLowerCase())

  TwitterUsers: Backbone.Collection.extend
    model: @TwitterUser

    add: (twitterUser) ->
      return false if this.any (_twitterUser) ->
        _twitterUser.get('screenName') == twitterUser.get('screenName')

      Backbone.Collection.prototype.add.apply(this, arguments)

