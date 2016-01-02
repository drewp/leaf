humanizeSec = (sec) ->
  if sec
    moment.duration(sec, "seconds").humanize()
  else
    sec

meterToMile = (value) ->
  Math.round value * 0.000621371


Polymer
  is: "leaf-report"
  properties:
    latestRead: {notify: true}
    fullL2Format: {computed: _fullL2Format(latestRead)}
    fullFormat: {computed: _fullFormat(latestRead)}
    cruiseAcOffMiles: {computed: _cruiseAcOffMiles(latestRead)}
    cruiseAcOnMiles: {computed: _cruiseAcOnMiles(latestRead)}
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
  _fullFormat: (latestRead) ->
    humanizeSec(latestRead.time_required_to_full_sec)
  _fullL2Format: (latestRead) ->
    humanizeSec(latestRead.time_required_to_full_L2_sec)
  _cruiseAcOffMiles: (latestRead) ->
    meterToMile(latestRead.cruising_range_ac_off)
  _cruiseAcOnMiles: (latestRead) ->
    meterToMile(latestRead.cruising_range_ac_on)