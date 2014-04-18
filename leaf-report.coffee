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
  created: ->
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

    refresh()

# listen for leaf-report update signal, rerun refresh