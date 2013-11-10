// Generated by CoffeeScript 1.6.3
(function() {
  var dom, twitterUsers;

  dom = {
    filteredUserInput: $('.filtered-user-input'),
    filteredUsers: $('.filtered-users')
  };

  twitterUsers = null;

  chrome.extension.sendMessage({
    filteredUsers: null
  }, function(res) {
    return twitterUsers = util.generateTwitterUsers({
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
    return twitterUsers.remove(el.data('model'));
  });

  dom.filteredUserInput.keypress(function(e) {
    var screenName;
    if (e.keyCode === 13) {
      screenName = $.trim(dom.filteredUserInput.val()).replace(/\W/g, '');
      if (util.isBlank(screenName)) {
        return;
      }
      twitterUsers.add(new models.TwitterUser({
        screenName: screenName
      }));
      return dom.filteredUserInput.val('');
    }
  });

}).call(this);
