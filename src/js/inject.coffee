if location.host == 'twitter.com'
  rclass = /[\n\t]/g
  filteredUsers = null
  options = null

  class Tweet
    constructor: ($el) ->
      @screenName = $el.data('screen-name')

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

    $els.find('.tweet').each ->
      $this = $(@)
      tweet = new Tweet($this)

      # remove previous changes
      $this.show()
      $this.find('.content').show()
      $this.find('.tf-el').remove()

      $this.find('.account-group').after("""
        <a class="toggle-hide tf-el">
          Hide
        </a>
      """)

      if filteredUsers.findWhere(screenName: tweet.screenName.toLowerCase())
        toHide.push
          el: $this
          tweet: tweet

    _.each toHide, (hideObj) ->
      {el} = hideObj

      if options.get('hideCompletely')
        el.hide()
      else
        el = el.find('.content')

        replacement = $("""
          <div class="hidden-message tf-el">
            #{_.escape(hideObj.tweet.screenName)}'s tweet has been filtered. <a>Show?</a>
          </div>
        """)

        replacement.find('a').click ->
          el.show()
          replacement.remove()

        el.hide().after(replacement)

  (->
    filteredUsersDeferred = $.Deferred()
    optionsDeferred = $.Deferred()

    chrome.extension.sendMessage filteredUsers: null, (res) ->
      filteredUsers = models.generateTwitterUsers
        users: res.filteredUsers
      filteredUsersDeferred.resolve()

    chrome.extension.sendMessage options: null, (res) ->
      options = new models.Options(res.options)
      optionsDeferred.resolve()

    $.when(filteredUsersDeferred, optionsDeferred).then ->
      filterCurrentPage()
  )()

  (->
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

    addObserver()

    oldLocation = location.href
    setInterval ->
      unless location.href == oldLocation
        oldLocation = location.href
        filterCurrentPage()
        addObserver()
    , 500
  )()
