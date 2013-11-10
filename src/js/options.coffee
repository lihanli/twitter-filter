dom =
  filteredUserInput: $('.filtered-user-input')
  filteredUsers: $('.filtered-users')

twitterUsers = null

chrome.extension.sendMessage filteredUsers: null, (res) ->
  twitterUsers = util.generateTwitterUsers
    users: res.filteredUsers
    events:
      add: (twitterUser, collection) ->
        el = $("""
          <li>
            @#{_.escape(twitterUser.get('screenName'))}
            <a class="close">&times;</a>
          </li>
        """).data('model', twitterUser)

        dom.filteredUsers.append(el)

      remove: (twitterUser, __, opt) ->
        $(dom.filteredUsers.find('li')[opt.index]).remove()

dom.filteredUsers.on 'click', '.close', ->
  el = $(@).parents('li')
  twitterUsers.remove(el.data('model'))

dom.filteredUserInput.keypress (e) ->
  if e.keyCode == 13
    screenName = $.trim(dom.filteredUserInput.val()).replace(/\W/g, '')

    return if util.isBlank(screenName)

    twitterUsers.add(new models.TwitterUser(screenName: screenName))
    dom.filteredUserInput.val('')
