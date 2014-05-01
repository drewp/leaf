Polymer "leaf-meter", {
  observe: {
    battery_capacity: 'refresh',
    battery_remaining_amount: 'refresh'
  },
  refresh: () ->
    @cap = parseInt(@battery_capacity)
    @remain = parseInt(@battery_remaining_amount)
    @steps = [@cap .. 1]
    if @plugin_state == 'NOT_CONNECTED'
      @desc = "not connected"
    else
      if @battery_charging_status == 'NOT_CHARGING'
        @desc = "plugged but not charging"
      else
        @desc = "charging at "
        if @time_required_to_full_L2_sec
          @desc += "L2"
        else if @time_required_to_full_sec
          @desc += "slow plug"
        else
          @desc += "(unknown mode)"
    @estimate = "Est " + Math.round(@cruising_range_ac_off / 1609.34) + " mi"
}
