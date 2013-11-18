if location.host == 'twitter.com'
  # can't cache dom elements because they become invalid when user changes pages
  rclass = /[\n\t]/g
  filteredUsers = null
  filteredPhrases = null
  options = null

  class Tweet
    constructor: ($el) ->
      @screenName = $el.data('screen-name')
      @text = $el.find('.tweet-text').text()

    userData: ->
      _.pick(@, 'screenName')

    shouldHide: ->
      @hidden = (->
        return true if filteredUsers.findByScreenName(@screenName)
      ).apply(@, arguments)

    @getCachedTweet: ($el) ->
      $el.data('tf-tweet')

  hasClass = (el, selector) ->
    className = " " + selector + " "
    return true  if (" " + el.className + " ").replace(rclass, " ").indexOf(className) > -1
    false

  filterCurrentPage = ->
    filterTweets(document.querySelectorAll('.stream-items li'))

  filterTweets = (els) ->
    # every time the page changes without a full reload
    # all the elements stay the same but the previously set click handlers and data attributes get wiped out
    $els = $(els)
    toHide = []
    hideCompletely = options.get('hideCompletely')

    removeConversationModule = ($el) ->
      # remove the blue lines
      $el.parents('ol.conversation-module').removeClass('conversation-module')

    if hideCompletely
      # hide the conversation module things for filtered users
      _.each ['.missing-tweets-bar', '.conversation-header'], (klass) ->
        $els.find(klass).each ->
          $this = $(@)
          # remove previous changes
          $this.show()

          if filteredUsers.findByScreenName($this.find('a').attr('href').split('/')[1])
            $this.hide()
            removeConversationModule($this)

    $els.find('.tweet').each ->
      $this = $(@)
      tweet = new Tweet($this)
      $this.data('tf-tweet', tweet)

      # remove previous changes
      $this.show()
      $this.find('.content').show()
      $this.find('.tf-el').remove()

      if tweet.shouldHide()
        toHide.push
          $el: $this

      $this.find('.account-group').after("""
        <a class="toggle-hide tf-el">
          #{if tweet.hidden then 'Unhide' else 'Hide'}
        </a>
      """)

    _.each toHide, (hideObj) ->
      {$el} = hideObj
      tweet = Tweet.getCachedTweet($el)

      if hideCompletely
        $el.hide()
        removeConversationModule($el)
      else
        $el = $el.find('.content')

        replacement = $("""
          <div class="hidden-message tf-el">
            #{_.escape(tweet.screenName)}'s tweet has been filtered. <a>Show?</a>
          </div>
        """)

        replacement.find('a').click ->
          $el.show()
          replacement.remove()

        $el.hide().after(replacement)

  chrome.extension.sendMessage options: null, (res) ->
    options = new models.Options(res.options)

    if options.get('enable')
      pageWatcher()

      filteredUsersDeferred = $.Deferred()
      filteredPhrasesDeferred = $.Deferred()

      chrome.extension.sendMessage filteredUsers: null, (res) ->
        filteredUsers = models.generateCollection
          collectionName: 'FilteredUsers'
          data: res.filteredUsers
          anyChangeCb: ->
            filterCurrentPage()

        filteredUsersDeferred.resolve()

      chrome.extension.sendMessage filteredPhrases: null, (res) ->
        filteredPhrases = models.generateCollection
          collectionName: 'FilteredPhrases'
          data: res.filteredPhrases

        filteredPhrasesDeferred.resolve()

      $.when(filteredUsersDeferred, filteredPhrasesDeferred).then ->
        setupPage()

  pageWatcher = ->
    oldLocation = location.href

    setInterval ->
      newLocation = location.href
      unless newLocation == oldLocation
        oldLocation = newLocation

        setupPage()
    , 500

  setupPage = (->
    observer = null

    addObserver = ->
      observer.disconnect() if observer

      observer = new MutationObserver (mutations) ->
        mutations.forEach (mutation) ->
          {addedNodes} = mutation
          if addedNodes.length > 0 && hasClass(addedNodes[0], 'stream-item')
            filterTweets(addedNodes)

      observer.observe document.querySelector('.stream-items'),
        childList: true

    addClickHandlers = ->
      $('.stream-container').on 'click', '.tweet .toggle-hide', ->
        tweet = Tweet.getCachedTweet($(this).parents('.tweet'))

        if tweet.hidden
          filteredUsers.remove(filteredUsers.findByScreenName(tweet.screenName))
        else
          if confirm("Hide all of #{tweet.screenName}'s tweets? This won't unfollow or block him/her.")
            filteredUser = models.generateModelWithSanitizer
              Model: models.FilteredUser
              attr: 'screenName'
            filteredUser.set(tweet.userData())

            filteredUsers.add(filteredUser)

    ->
      path = location.pathname
      return if path == '/mentions' || path == '/i/connect'

      addObserver()
      addClickHandlers()
      filterCurrentPage()
  )()
