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
    now = parseFloat(@now_milli)
    xForTime = d3.scale.linear().domain([
      now - .25 * 86400 * 1000,
      now + 30 * 60 * 1000]).range([0, this.$.timeline.clientWidth])

    @events = []
    # this is missing the unsuccessful ones, which the server should provide
    @recent.forEach (row) =>
      t = new Date(row[0])
      label = "ok" # row[1]
      hhmm = t.toTimeString().replace(/(\d+:\d+):.*/, "$1")
      x = xForTime(+t)
      if x > 0
        @events.push
          style: "left: " + x + "px"
          label: hhmm + "\n" + label

    # also get the expected next times from the server and draw those

    @events.push
      style: "left: " + xForTime(parseFloat(@now_milli)) + "px; border-left-style: dashed; border-color: red"
      label: "now"

}
