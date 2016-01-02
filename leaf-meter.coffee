Polymer
  is: "leaf-meter"
  
  properties:
    battery_capacity: {notify: true, type: Number, observer: 'refresh'}
    battery_remaining_amount: {notify: true, type: Number, observer: 'refresh'}
    battery_charging_status: {notify: true, observer: 'refresh'}
    plugin_state: {notify: true, observer: 'refresh'}
    cruising_range_ac_off: {notify: true, type: Number, observer: 'refresh'}
    time_required_to_full_L2_sec: {notify: true, observer: 'refresh'}
    time_required_to_full_sec: {notify: true, observer: 'refresh'}
    steps: {notify: true, type: Array}

  refresh: () ->
    @cap = parseFloat(@battery_capacity) # why didn't this come as a Number?
    @remain = parseFloat(@battery_remaining_amount)
    @steps = [@cap .. 1]
    if @plugin_state == 'NOT_CONNECTED'
      @desc = "not connected"
      @classes = "not-connected"
    else
      if @battery_charging_status == 'NOT_CHARGING'
        @desc = "plugged but not charging"
        @classes = "plug-no-charge"
      else
        @desc = "charging at "
        if @time_required_to_full_L2_sec
          @desc += "L2"
          @classes = "charging charging-l2"
        else if @time_required_to_full_sec
          @desc += "slow plug"
          @classes = "charging charging-slow"
        else
          @desc += "(unknown mode)"
    @estimate = "Est " + Math.round(parseFloat(@cruising_range_ac_off) / 1609.34) + " mi"
