# can't cache dom elements because they become invalid when user changes pages
RCLASS = /[\n\t]/g
CONVERSATION_CHILDREN = ['.missing-tweets-bar', '.conversation-header']
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
    lowercaseText = @text.toLowerCase()
    allFilteredPhrases = filteredPhrases.map (filteredPhrase) ->
      filteredPhrase.get('phrase')

    if options.get('hideMentions')
      filteredUsers.each (filteredUser) ->
        allFilteredPhrases.push("@#{filteredUser.get('screenName')}")

    @hidden = (->
      return true if filteredUsers.findByScreenName(@screenName)

      for phrase in allFilteredPhrases
        return true unless lowercaseText.indexOf(phrase) == -1

      false
    ).apply(@, arguments)

  @getCachedTweet: ($el) ->
    $el.data('tf-tweet')

hasClass = (el, selector) ->
  className = " " + selector + " "
  return true  if (" " + el.className + " ").replace(RCLASS, " ").indexOf(className) > -1
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
    # disable the entire conversation module
    module = $el.parents('ol.conversation-module')
    return if module.length == 0
    module.removeClass('conversation-module')

    _.each CONVERSATION_CHILDREN, (klass) ->
      module.find(klass).hide()

  # remove previous changes
  _.each CONVERSATION_CHILDREN, (klass) ->
    $els.find(klass).show()
  $els.parents('ol[data-ancestors]').addClass('conversation-module')

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

    $this.find('.stream-item-header .time').after("""
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

chrome.storage.sync.get options: {}, (res) ->
  options = new models.Options(res.options)

  if options.get('enable')
    pageWatcher()

    chrome.storage.sync.get ['filteredUsers', 'filteredPhrases'], (res) ->
      filteredUsers = models.generateCollection
        collectionName: 'FilteredUsers'
        data: res.filteredUsers
        anyChangeCb: ->
          filterCurrentPage()

      filteredPhrases = models.generateCollection
        collectionName: 'FilteredPhrases'
        data: res.filteredPhrases

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

  observerCallback = (mutations) ->
    for mutation in mutations
      {addedNodes} = mutation
      firstAdded = addedNodes[0]

      if addedNodes.length > 0
        if hasClass(firstAdded, 'stream-item') ||
           hasClass(firstAdded, 'conversation-tweet-item') ||
           (firstAdded.tagName == 'LI' && firstAdded.children.length > 0 && hasClass(firstAdded.children[0], 'tweet'))
          filterTweets(addedNodes)
  observerCallback = _.throttle(observerCallback, 100)

  addObserver = ->
    observer.disconnect() if observer
    observer = new MutationObserver(observerCallback)
    observer.observe document.getElementsByClassName('stream-items')[0],
      childList: true
      subtree: true

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
