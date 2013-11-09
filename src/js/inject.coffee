if location.host == 'twitter.com'
  rclass = /[\n\t]/g
  filteredUsers = []

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
    $els = $(els)
    toHide = []

    $els.find('.tweet').each ->
      $this = $(@)
      tweet = new Tweet($this)

      if _.findWhere(filteredUsers, screenName: tweet.screenName.toLowerCase())
        toHide.push
          el: $this.find('.content')
          tweet: tweet

    _.each toHide, (hideObj) ->
      {el} = hideObj

      replacement = $("""
        <div class="hidden-message">
          #{_.escape(hideObj.tweet.screenName)}'s tweet has been filtered. <a>Show?</a>
        </div>
      """)

      replacement.find('a').click ->
        el.show()
        replacement.remove()

      el.hide().after(replacement)

  chrome.extension.sendMessage filteredUsers: null, (res) ->
    {filteredUsers} = res
    filterCurrentPage()

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
