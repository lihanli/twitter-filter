// Generated by CoffeeScript 1.6.3
(function() {
  var Tweet, filterCurrentPage, filterTweets, filteredUsers, hasClass, options, pageWatcher, rclass, setupPage;

  if (location.host === 'twitter.com') {
    rclass = /[\n\t]/g;
    filteredUsers = null;
    options = null;
    Tweet = (function() {
      function Tweet($el) {
        this.screenName = $el.data('screen-name');
      }

      Tweet.prototype.data = function() {
        return _.pick(this, 'screenName');
      };

      Tweet.getCachedTweet = function($el) {
        return $el.data('tf-tweet');
      };

      return Tweet;

    })();
    hasClass = function(el, selector) {
      var className;
      className = " " + selector + " ";
      if ((" " + el.className + " ").replace(rclass, " ").indexOf(className) > -1) {
        return true;
      }
      return false;
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
        return $el.parents('ol.conversation-module').removeClass('conversation-module');
      };
      if (hideCompletely) {
        _.each(['.missing-tweets-bar', '.conversation-header'], function(klass) {
          return $els.find(klass).each(function() {
            var $this;
            $this = $(this);
            $this.show();
            if (filteredUsers.findByScreenName($this.find('a').attr('href').split('/')[1])) {
              $this.hide();
              return removeConversationModule($this);
            }
          });
        });
      }
      $els.find('.tweet').each(function() {
        var $this, tweet;
        $this = $(this);
        tweet = new Tweet($this);
        $this.data('tf-tweet', tweet);
        $this.show();
        $this.find('.content').show();
        $this.find('.tf-el').remove();
        if (filteredUsers.findByScreenName(tweet.screenName)) {
          tweet.hidden = true;
          toHide.push({
            $el: $this
          });
        }
        return $this.find('.account-group').after("<a class=\"toggle-hide tf-el\">\n  " + (tweet.hidden ? 'Unhide' : 'Hide') + "\n</a>");
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
    chrome.extension.sendMessage({
      options: null
    }, function(res) {
      options = new models.Options(res.options);
      if (options.get('enable')) {
        pageWatcher();
        return chrome.extension.sendMessage({
          filteredUsers: null
        }, function(res) {
          filteredUsers = models.generateCollection({
            collectionName: 'FilteredUsers',
            data: res.filteredUsers,
            anyChangeCb: function() {
              return filterCurrentPage();
            }
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
      var addClickHandlers, addObserver, observer;
      observer = null;
      addObserver = function() {
        if (observer) {
          observer.disconnect();
        }
        observer = new MutationObserver(function(mutations) {
          return mutations.forEach(function(mutation) {
            var addedNodes;
            addedNodes = mutation.addedNodes;
            if (addedNodes.length > 0 && hasClass(addedNodes[0], 'stream-item')) {
              return filterTweets(addedNodes);
            }
          });
        });
        return observer.observe(document.querySelector('.stream-items'), {
          childList: true
        });
      };
      addClickHandlers = function() {
        return $('.stream-container').on('click', '.tweet .toggle-hide', function() {
          var tweet;
          tweet = Tweet.getCachedTweet($(this).parents('.tweet'));
          if (tweet.hidden) {
            return filteredUsers.remove(filteredUsers.findByScreenName(tweet.screenName));
          } else {
            if (confirm("Hide all of " + tweet.screenName + "'s tweets? This won't unfollow or block him/her.")) {
              return filteredUsers.add(new models.FilteredUser(tweet.data()));
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
  }

}).call(this);
