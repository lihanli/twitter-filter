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

chrome.extension.sendMessage filteredUsers: null, (res) ->
  twitterUsers = new TwitterUsers(convertToBackboneArr(TwitterUser, res.filteredUsers))

  twitterUsers.on 'add', (twitterUser, collection) ->
    dom.filteredUsers.append """
      <li>
        @#{_.escape(twitterUser.get('screenName'))}
        <a class="close">&times;</a>
      </li>
    """

dom.filteredUserInput.keypress (e) ->
  if e.keyCode == 13
    screenName = $.trim(dom.filteredUserInput.val()).replace(/\W/g, '')

    return if util.isBlank(screenName)

    twitterUsers.add(new TwitterUser(screenName: screenName))
    dom.filteredUserInput.val('')
