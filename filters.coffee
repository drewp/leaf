PolymerExpressions::json = JSON.stringify
PolymerExpressions::meterToMile = (value) ->
  Math.round value * 0.000621371

PolymerExpressions::fromNow = (date) ->
  moment(date)?.fromNow()

PolymerExpressions::humanizeSec = (sec) ->
  if sec
    moment.duration(sec, "seconds").humanize()
  else
    sec
