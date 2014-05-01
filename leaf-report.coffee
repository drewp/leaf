
Polymer "leaf-report",
  latestRead: {}
  ready: ->
    self = this
    refresh = ->
      $.getJSON "/leaf/latest", (d) ->
        self.latestRead = d
      return

    updateTime = () ->
      self.$.polling.now_milli = +new Date()
    setInterval(updateTime, 30 * 1000)
    setInterval(refresh, 1000 * 60 * 10)
    updateTime()
    refresh()

