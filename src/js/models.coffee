window.models =
  TwitterUser: Backbone.Model.extend
    initialize: ->
      @.set
        screenName: models.TwitterUser.sanitizeScreenName(@.get('screenName'))

    validate: ->
      msg = models.validations.presence.call(@, 'screenName')
      return msg if msg

  TwitterUsers: Backbone.Collection.extend
    model: @TwitterUser

    add: ->
      return false if models.checkDuplicates.call(@, 'twitterUser')

      Backbone.Collection.prototype.add.apply(this, arguments)

    findByScreenName: (screenName) ->
      @.findWhere({ screenName: models.TwitterUser.sanitizeScreenName(screenName) })

  FilteredPhrase: Backbone.Model.extend
    initialize: ->
      @.set(phrase: $.trim(@.get('phrase')))

    validate: ->
      msg = models.validations.presence.call(@, 'phrase')
      return msg if msg

  FilteredPhrases: Backbone.Collection.extend
    model: @FilteredPhrase

    add: (filteredPhrase) ->
      return false if models.checkDuplicates('phrase')

      Backbone.Collection.prototype.add.apply(this, arguments)

  Options: Backbone.Model.extend
    defaults:
      hideCompletely: false
      enable: true

  checkDuplicates: (attr) ->
    self = @

    self.any (model) ->
      model.get(attr) == self.get(attr)

  validations:
    presence: (attr) ->
      return "#{attr} can't be blank" if util.isBlank(@.get(attr))
      false

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