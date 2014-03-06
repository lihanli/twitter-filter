// Generated by CoffeeScript 1.6.3
(function() {
  var CONVERSATION_CHILDREN, Tweet, filterCurrentPage, filterTweets, filteredPhrases, filteredUsers, hasClass, options, pageWatcher, setupPage;

  CONVERSATION_CHILDREN = ['.missing-tweets-bar', '.conversation-header'];

  filteredUsers = null;

  filteredPhrases = null;

  options = null;

  Tweet = (function() {
    function Tweet($el) {
      this.screenName = $el.data('screen-name');
      this.text = $el.find('.tweet-text').text();
    }

    Tweet.prototype.userData = function() {
      return _.pick(this, 'screenName');
    };

    Tweet.prototype.shouldHide = function() {
      var allFilteredPhrases, lowercaseText;
      lowercaseText = this.text.toLowerCase();
      allFilteredPhrases = filteredPhrases.map(function(filteredPhrase) {
        return filteredPhrase.get('phrase');
      });
      if (options.get('hideMentions')) {
        filteredUsers.each(function(filteredUser) {
          return allFilteredPhrases.push("@" + (filteredUser.get('screenName')));
        });
      }
      return this.hidden = (function() {
        var phrase, _i, _len;
        if (filteredUsers.findByScreenName(this.screenName)) {
          return true;
        }
        for (_i = 0, _len = allFilteredPhrases.length; _i < _len; _i++) {
          phrase = allFilteredPhrases[_i];
          if (lowercaseText.indexOf(phrase) !== -1) {
            return true;
          }
        }
        return false;
      }).apply(this, arguments);
    };

    Tweet.getCachedTweet = function($el) {
      return $el.data('tf-tweet');
    };

    return Tweet;

  })();

  hasClass = function(el, selector) {
    return el.classList.contains(selector);
  };

  filterCurrentPage = function() {
    return filterTweets(document.querySelectorAll('.stream-items li'));
  };

  filterTweets = function(els) {
    var $els, hideCompletely, removeConversationModule, toHide;
    $els = $(els);
    toHide = [];
    hideCompletely = options.get('hideCompletely');
    removeConversationModule = function($el) {
      var module;
      module = $el.parents('ol.conversation-module');
      if (module.length === 0) {
        return;
      }
      module.removeClass('conversation-module');
      return _.each(CONVERSATION_CHILDREN, function(klass) {
        return module.find(klass).hide();
      });
    };
    _.each(CONVERSATION_CHILDREN, function(klass) {
      return $els.find(klass).show();
    });
    $els.parents('ol[data-ancestors]').addClass('conversation-module');
    $els.find('.tweet').each(function() {
      var $this, tweet;
      $this = $(this);
      tweet = new Tweet($this);
      $this.data('tf-tweet', tweet);
      $this.show();
      $this.find('.content').show();
      $this.find('.tf-el').remove();
      if (tweet.shouldHide()) {
        toHide.push({
          $el: $this
        });
      }
      return $this.find('.stream-item-header .time').after("<a class=\"toggle-hide tf-el\">\n  " + (tweet.hidden ? 'Unhide' : 'Hide') + "\n</a>");
    });
    return _.each(toHide, function(hideObj) {
      var $el, replacement, tweet;
      $el = hideObj.$el;
      tweet = Tweet.getCachedTweet($el);
      if (hideCompletely) {
        $el.hide();
        return removeConversationModule($el);
      } else {
        $el = $el.find('.content');
        replacement = $("<div class=\"hidden-message tf-el\">\n  " + (_.escape(tweet.screenName)) + "'s tweet has been filtered. <a>Show?</a>\n</div>");
        replacement.find('a').click(function() {
          $el.show();
          return replacement.remove();
        });
        return $el.hide().after(replacement);
      }
    });
  };

  chrome.storage.sync.get({
    options: {}
  }, function(res) {
    options = new models.Options(res.options);
    if (options.get('enable')) {
      pageWatcher();
      return chrome.storage.sync.get(['filteredUsers', 'filteredPhrases'], function(res) {
        filteredUsers = models.generateCollection({
          collectionName: 'FilteredUsers',
          data: res.filteredUsers,
          anyChangeCb: function() {
            return filterCurrentPage();
          }
        });
        filteredPhrases = models.generateCollection({
          collectionName: 'FilteredPhrases',
          data: res.filteredPhrases
        });
        return setupPage();
      });
    }
  });

  pageWatcher = function() {
    var oldLocation;
    oldLocation = location.href;
    return setInterval(function() {
      var newLocation;
      newLocation = location.href;
      if (newLocation !== oldLocation) {
        oldLocation = newLocation;
        return setupPage();
      }
    }, 500);
  };

  setupPage = (function() {
    var addClickHandlers, addObserver, observer, observerCallback;
    observer = null;
    observerCallback = function(mutations) {
      var addedNodes, firstAdded, mutation, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = mutations.length; _i < _len; _i++) {
        mutation = mutations[_i];
        addedNodes = mutation.addedNodes;
        firstAdded = addedNodes[0];
        if (addedNodes.length > 0) {
          if (hasClass(firstAdded, 'stream-item') || hasClass(firstAdded, 'conversation-tweet-item') || (firstAdded.tagName === 'LI' && firstAdded.children.length > 0 && hasClass(firstAdded.children[0], 'tweet'))) {
            _results.push(filterTweets(addedNodes));
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    observerCallback = _.throttle(observerCallback, 100);
    addObserver = function() {
      if (observer) {
        observer.disconnect();
      }
      observer = new MutationObserver(observerCallback);
      return observer.observe(document.getElementsByClassName('stream-items')[0], {
        childList: true,
        subtree: true
      });
    };
    addClickHandlers = function() {
      return $('.stream-container').on('click', '.tweet .toggle-hide', function() {
        var filteredUser, tweet;
        tweet = Tweet.getCachedTweet($(this).parents('.tweet'));
        if (tweet.hidden) {
          return filteredUsers.remove(filteredUsers.findByScreenName(tweet.screenName));
        } else {
          if (confirm("Hide all of " + tweet.screenName + "'s tweets? This won't unfollow or block him/her.")) {
            filteredUser = models.generateModelWithSanitizer({
              Model: models.FilteredUser,
              attr: 'screenName'
            });
            filteredUser.set(tweet.userData());
            return filteredUsers.add(filteredUser);
          }
        }
      });
    };
    return function() {
      var path;
      path = location.pathname;
      if (path === '/mentions' || path === '/i/connect') {
        return;
      }
      addObserver();
      addClickHandlers();
      return filterCurrentPage();
    };
  })();

}).call(this);
