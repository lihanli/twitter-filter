if location.host == 'twitter.com'
  rclass = /[\n\t]/g
  observer = null
  blocked = ['_hermit_thrush_', 'leh0n']

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

      unless _.indexOf(blocked, $this.data('screen-name').toLowerCase()) == -1
        toHide.push($this)

    _.each toHide, (el) ->
      replacement = $("""
        <div>
          This tweet has been filtered. <a>Show?</a>
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
    , 1000
  )()

  # history.onpushstate = ->
  #   console.log 'state changed'

  # ((history) ->
  #   pushState = history.pushState
  #   history.pushState = (state) ->
  #     history.onpushstate state: state  if typeof history.onpushstate is "function"

  #     # ... whatever else you want to do
  #     # maybe call onhashchange e.handler
  #     pushState.apply history, arguments
  # ) window.history