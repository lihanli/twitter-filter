dom =
  filteredUserInput: $('.filtered-user-input')
  filteredUsers: $('.filtered-users')

TwitterUser = Backbone.Model.extend
  initialize: ->
    @.set(screenName: @.get('screenName').toLowerCase())

TwitterUsers = Backbone.Collection.extend
  model: TwitterUser
  add: (twitterUser) ->
    return false if this.any (_twitterUser) ->
      _twitterUser.get('screenName') == twitterUser.get('screenName')

    Backbone.Collection.prototype.add.apply(this, arguments)

twitterUsers = null

convertToBackboneArr = (Model, arr) ->
  _.map arr, (item) ->
    new Model(item)

removeByIndex = (collection, idx) ->
  collection.remove(collection.models[idx])

chrome.extension.sendMessage filteredUsers: null, (res) ->
  twitterUsers = new TwitterUsers(convertToBackboneArr(TwitterUser, res.filteredUsers))

  twitterUsers.on 'add', (twitterUser, collection) ->
    el = $("""
      <li>
        @#{_.escape(twitterUser.get('screenName'))}
        <a class="close">&times;</a>
      </li>
    """).data('model', twitterUser)

    dom.filteredUsers.append(el)

  twitterUsers.on 'remove', (twitterUser, __, opt) ->
    $(dom.filteredUsers.find('li')[opt.index]).remove()

dom.filteredUsers.on 'click', '.close', ->
  el = $(@).parents('li')
  twitterUsers.remove(el.data('model'))

dom.filteredUserInput.keypress (e) ->
  if e.keyCode == 13
    screenName = $.trim(dom.filteredUserInput.val()).replace(/\W/g, '')

    return if util.isBlank(screenName)

    twitterUsers.add(new TwitterUser(screenName: screenName))
    dom.filteredUserInput.val('')
