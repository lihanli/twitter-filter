// Generated by CoffeeScript 1.6.3
(function() {
  var Tweet, filterCurrentPage, filterTweets, filteredUsers, hasClass, options, rclass;

  if (location.host === 'twitter.com') {
    rclass = /[\n\t]/g;
    filteredUsers = null;
    options = null;
    Tweet = (function() {
      function Tweet($el) {
        this.screenName = $el.data('screen-name');
      }

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
      var $els, toHide;
      $els = $(els);
      toHide = [];
      $els.find('.tweet').each(function() {
        var $this, tweet;
        $this = $(this);
        tweet = new Tweet($this);
        $this.show();
        $this.find('.content').show();
        $this.find('.tf-el').remove();
        $this.find('.account-group').after("<a class=\"toggle-hide tf-el\">\n  Hide\n</a>");
        if (filteredUsers.findWhere({
          screenName: tweet.screenName.toLowerCase()
        })) {
          return toHide.push({
            el: $this,
            tweet: tweet
          });
        }
      });
      return _.each(toHide, function(hideObj) {
        var el, replacement;
        el = hideObj.el;
        if (options.get('hideCompletely')) {
          return el.hide();
        } else {
          el = el.find('.content');
          replacement = $("<div class=\"hidden-message tf-el\">\n  " + (_.escape(hideObj.tweet.screenName)) + "'s tweet has been filtered. <a>Show?</a>\n</div>");
          replacement.find('a').click(function() {
            el.show();
            return replacement.remove();
          });
          return el.hide().after(replacement);
        }
      });
    };
    (function() {
      var filteredUsersDeferred, optionsDeferred;
      filteredUsersDeferred = $.Deferred();
      optionsDeferred = $.Deferred();
      chrome.extension.sendMessage({
        filteredUsers: null
      }, function(res) {
        filteredUsers = models.generateTwitterUsers({
          users: res.filteredUsers
        });
        return filteredUsersDeferred.resolve();
      });
      chrome.extension.sendMessage({
        options: null
      }, function(res) {
        options = new models.Options(res.options);
        return optionsDeferred.resolve();
      });
      return $.when(filteredUsersDeferred, optionsDeferred).then(function() {
        return filterCurrentPage();
      });
    })();
    (function() {
      var addObserver, observer, oldLocation;
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
      addObserver();
      oldLocation = location.href;
      return setInterval(function() {
        if (location.href !== oldLocation) {
          oldLocation = location.href;
          filterCurrentPage();
          return addObserver();
        }
      }, 500);
    })();
  }

}).call(this);
