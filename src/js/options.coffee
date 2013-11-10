dom =
  filteredUserInput: $('.filtered-user-input')
  filteredUsers: $('.filtered-users')

filteredUsers = null

chrome.extension.sendMessage filteredUsers: null, (res) ->
  filteredUsers = util.generateTwitterUsers
    users: res.filteredUsers
    events:
      add: (twitterUser) ->
        el = $("""
          <li>
            <span class="screen-name">@#{_.escape(twitterUser.get('screenName'))}</span>
            <a class="close">&times;</a>
          </li>
        """).data('model', twitterUser)

        dom.filteredUsers.append(el)

      remove: (twitterUser, __, opt) ->
        $(dom.filteredUsers.find('li')[opt.index]).remove()

dom.filteredUsers.on 'click', '.close', ->
  el = $(@).parents('li')
  filteredUsers.remove(el.data('model'))

dom.filteredUserInput.keypress (e) ->
  if e.keyCode == 13
    twitterUser = new models.TwitterUser(screenName: dom.filteredUserInput.val())

    return unless twitterUser.isValid()

    filteredUsers.add(twitterUser)
    dom.filteredUserInput.val('')
