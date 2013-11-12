window.models =
  TwitterUser: Backbone.Model.extend
    initialize: ->
      @.set
        screenName: models.TwitterUser.sanitizeScreenName(@.get('screenName'))

    validate: ->
      return "screenName can't be blank" if util.isBlank(@.get('screenName'))

  TwitterUsers: Backbone.Collection.extend
    model: @TwitterUser

    add: (twitterUser) ->
      return false if this.any (_twitterUser) ->
        _twitterUser.get('screenName') == twitterUser.get('screenName')

      Backbone.Collection.prototype.add.apply(this, arguments)

    findByScreenName: (screenName) ->
      @.findWhere({ screenName: models.TwitterUser.sanitizeScreenName(screenName) })

  Options: Backbone.Model.extend
    defaults:
      hideCompletely: false
      enable: true

  generateTwitterUsers: (opt = {}) ->
    opt.events = {} unless opt.events?

    twitterUsers = new @TwitterUsers()

    for evt, cb of opt.events
      twitterUsers.on(evt, cb)

    twitterUsers.add(util.convertToBackboneArr(@TwitterUser, opt.users))

    twitterUsers.on 'change reset add remove', (__, collection) ->
      util.saveToBg('filteredUsers', collection)
      opt.anyChangeCb() if opt.anyChangeCb

    twitterUsers

models.TwitterUser.sanitizeScreenName = (screenName) ->
  $.trim(screenName).replace(/\W/g, '').toLowerCase()