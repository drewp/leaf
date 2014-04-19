Polymer "leaf-polling", {
  ready: () ->
    xForTime = (t) ->
      frac = (t - t1) / (t2 - t1)
      width * frac
    self = this
    t1 = parseFloat(@draw_from)
    t2 = parseFloat(@draw_to)
    width = 600
    self.nextMin = Math.floor((parseFloat(@next_sample) - parseFloat(@now)) / 6) / 10
    self.events = []
    JSON.parse(@recent).forEach (row) ->
      t = row[0]
      label = row[1]
      hhmm = new Date(t * 1000).toTimeString().replace(/(\d+:\d+):.*/, "$1")
      self.events.push
        style: "left: " + xForTime(t) + "px"
        label: hhmm + " " + label

      return

    self.events.push
      style: "left: " + xForTime(parseFloat(@now)) + "px; border-color: red"
      label: "now"

    return
}
