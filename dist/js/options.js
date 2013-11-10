// Generated by CoffeeScript 1.6.3
(function() {
  var dom, filteredUsers;

  dom = {
    filteredUserInput: $('.filtered-user-input'),
    filteredUsers: $('.filtered-users')
  };

  filteredUsers = null;

  chrome.extension.sendMessage({
    filteredUsers: null
  }, function(res) {
    return filteredUsers = util.generateTwitterUsers({
      users: res.filteredUsers,
      events: {
        add: function(twitterUser, collection) {
          var el;
          el = $("<li>\n  @" + (_.escape(twitterUser.get('screenName'))) + "\n  <a class=\"close\">&times;</a>\n</li>").data('model', twitterUser);
          return dom.filteredUsers.append(el);
        },
        remove: function(twitterUser, __, opt) {
          return $(dom.filteredUsers.find('li')[opt.index]).remove();
        }
      }
    });
  });

  dom.filteredUsers.on('click', '.close', function() {
    var el;
    el = $(this).parents('li');
    return filteredUsers.remove(el.data('model'));
  });

  dom.filteredUserInput.keypress(function(e) {
    var twitterUser;
    if (e.keyCode === 13) {
      twitterUser = new models.TwitterUser({
        screenName: dom.filteredUserInput.val()
      });
      if (!twitterUser.isValid()) {
        return;
      }
      filteredUsers.add(twitterUser);
      return dom.filteredUserInput.val('');
    }
  });

}).call(this);
