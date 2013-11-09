if location.host == 'twitter.com'
  rclass = /[\n\t]/g
  observer = null
  blocked = ['_hermit_thrush_', 'leh0n']

  class Tweet
    constructor: ($el) ->
      @screenName = $el.data('screen-name')

  hasClass = (el, selector) ->
    className = " " + selector + " "
    return true  if (" " + el.className + " ").replace(rclass, " ").indexOf(className) > -1
    false

  addObserver = ->
    target = document.querySelector('.stream-items')

    observer.disconnect() if observer

    observer = new MutationObserver (mutations) ->
      mutations.forEach (mutation) ->
        {addedNodes} = mutation
        if addedNodes.length > 0 && hasClass(addedNodes[0], 'stream-item')
          filterTweets(addedNodes)

    observer.observe target,
      childList: true

  addObserver()

  filterTweets = (els) ->
    $els = $(els)
    toHide = []

    $els.find('.tweet').each ->
      $this = $(@)
      tweet = new Tweet($this)

      unless _.indexOf(blocked, tweet.screenName.toLowerCase()) == -1
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


  filterTweets(document.querySelectorAll('.stream-items li'))

  (->
    oldLocation = location.href

    setInterval ->
      unless location.href == oldLocation
        oldLocation = location.href
        addObserver()
    , 500
  )()
