window.models =
  FilteredUser: Backbone.Model.extend
    validate: ->
      models.validations.presence.call(@, 'screenName')

  FilteredUsers: Backbone.Collection.extend
    add: (filteredUser) ->
      return false if models.checkDuplicates.call(@, filteredUser, 'screenName')

      Backbone.Collection.prototype.add.apply(@, arguments)

    findByScreenName: (screenName) ->
      @.findWhere({ screenName: models.FilteredUser.sanitizeScreenName(screenName) })

  FilteredPhrase: Backbone.Model.extend
    validate: ->
      models.validations.presence.call(@, 'phrase')

  FilteredPhrases: Backbone.Collection.extend
    add: (filteredPhrase) ->
      return false if models.checkDuplicates.call(@, filteredPhrase, 'phrase')

      Backbone.Collection.prototype.add.apply(this, arguments)

  Options: Backbone.Model.extend
    defaults:
      hideCompletely: false
      enable: true
      hideMentions: false

  checkDuplicates: (model, attr) ->
    @any (_model) ->
      _model.get(attr) == model.get(attr)

  validations:
    presence: (attr) ->
      return "#{attr} can't be blank" if util.isBlank(@.get(attr))
      false

  generateModelWithSanitizer: (opt = {}) ->
    # TODO get list of sanitizers using _.keys and regex
    model = new opt.Model()
    sanitizeFn = opt.sanitizeFn || opt.Model["sanitize#{util.capitalize(opt.attr)}"]

    model.on "change:#{opt.attr}", (__, val, changeOpt) ->
      return if changeOpt.noSanitize
      model.set(opt.attr, sanitizeFn(val), noSanitize: true)

    model

  generateCollection: (opt = {}) ->
    opt.events = {} unless opt.events?

    Collection = models[opt.collectionName]
    collection = new Collection()

    for evt, cb of opt.events
      collection.on(evt, cb)

    collection.add(util.convertToBackboneArr(Collection.prototype.model, opt.data || []))

    collection.on 'change reset add remove', ->
      util.saveToBg(util.uncapitalize(opt.collectionName), collection)
      opt.anyChangeCb() if opt.anyChangeCb

    collection

models.FilteredUser.sanitizeScreenName = (screenName) ->
  $.trim(screenName).replace(/\W/g, '').toLowerCase()
models.FilteredPhrase.sanitizePhrase = (phrase) ->
  $.trim(phrase).toLowerCase()

models.FilteredUsers.prototype.model = models.FilteredUser
models.FilteredPhrases.prototype.model = models.FilteredPhrase
