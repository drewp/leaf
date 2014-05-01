PolymerExpressions::json = JSON.stringify
PolymerExpressions::meterToMile = (value) ->
  Math.round value * 0.000621371

PolymerExpressions::fromNow = (date) ->
  moment(date).fromNow()

PolymerExpressions::humanizeSec = (sec) ->
  if sec
    moment.duration(sec, "seconds").humanize()
  else
    sec

Polymer "leaf-report",
  latestRead: {}
  ready: ->
    console.log("lrc")
    self = this
    refresh = ->
      $.getJSON "/leaf/latest", (d) ->
        self.latestRead = d

        meter = self.$.meter
        for k, v of d
          meter[k] = v

        meter.refresh() # should be an observer
        return

      return

    updateTime = () ->
      self.$.polling.now_milli = +new Date()
    setInterval(updateTime, 30 * 1000)
    setInterval(refresh, 1000 * 60 * 10)
    updateTime()
    refresh()

