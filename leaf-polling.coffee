Polymer
  is: "leaf-polling"
  properties:
    events: {notify: true, type: Array}
    next_sample: {notify: true, type: Number, observer: 'now_milliChanged'}
    recent: {notify: true, type: Array, observer: 'recentChanged'}
    events: {notify: true, type: Array}
    now_milli: {notify: true, type: Number, observer: 'now_milliChanged'}
    data_time: {notify: true}
    data_time_from_now: {computed: '_data_time_from_now(data_time)'}
  ready: () ->
    @events = []
    
  now_milliChanged: () ->
    nextMilli = +new Date(@next_sample)
    nextMin = (nextMilli - @now_milli) / 1000 / 60
    @nextMin = Math.round(nextMin * 10) / 10
    @recentChanged()
    
  recentChanged: () ->
    return if not @recent?
    xForTime = d3.scale.linear().domain([
      @now_milli - .25 * 86400 * 1000,
      @now_milli + 30 * 60 * 1000]).range([0, @$.timeline.clientWidth])

    @events = []
    # this is missing the unsuccessful ones, which the server should provide
    @recent.forEach (row) =>
      t = new Date(row[0])
      label = "ok" # row[1]
      hhmm = t.toTimeString().replace(/(\d+:\d+):.*/, "$1")
      x = xForTime(+t)
      if x > 0
        @push 'events',
          style: "left: " + x + "px"
          label: hhmm + "\n" + label
    # also get the expected next times from the server and draw those

    @push 'events',
      style: "left: " + xForTime(parseFloat(@now_milli)) + "px; border-left-style: dashed; border-color: red"
      label: "now"

  _data_time_from_now: (data_time) ->
    moment(data_time)?.fromNow()