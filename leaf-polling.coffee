Polymer "leaf-polling", {
  ready: () ->
    self = this
    @events = []

  next_sampleChanged: () ->
    @now_milliChanged()
    
  now_milliChanged: () ->
    nextMilli = +new Date(@next_sample)
    nextMin = (nextMilli - parseFloat(@now_milli)) / 1000 / 60
    @nextMin = Math.round(nextMin * 10) / 10
    @recentChanged()
    
  recentChanged: () ->
    return if not @recent?
    t1 = parseFloat(@now_milli) - .5 * 86400 * 1000
    t2 = parseFloat(@now_milli) + 30 * 60 * 1000
    width = 600
    # change to a d3 scale!
    xForTime = (t) ->
      frac = (t - t1) / (t2 - t1)
      width * frac

    @events = []
    # this is not really sample attempts; it's only the successful ones
    @recent.forEach (row) =>
      t = new Date(row[0])
      label = "ok" # row[1]
      hhmm = t.toTimeString().replace(/(\d+:\d+):.*/, "$1")
      x = xForTime(+t)
      if x > 0
        @events.push
          style: "left: " + x + "px"
          label: hhmm + "\n" + label

    @events.push
      style: "left: " + xForTime(parseFloat(@now_milli)) + "px; border-color: red"
      label: "now"

}
