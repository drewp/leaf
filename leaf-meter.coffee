Polymer "leaf-meter", {
  ready: () ->
    @cap = parseInt(@attributes.battery_capacity.value)
    @remain = parseInt(@attributes.battery_remaining_amount.value)
    console.log("attr", @battery_capacity)
    console.log("a2", @attributes.battery_capacity.value)
  observe: {
    battery_capacity: 'refresh',
  },
  refresh: () ->
    @steps = [@cap .. 1]
    if @attributes.plugin_state.value == 'NOT_CONNECTED'
      @desc = "not connected"
    else
      if @attributes.battery_charging_status.value == 'NOT_CHARGING'
        @desc = "plugged but not charging"
      else
        @desc = "charging at "
        if @attributes.time_required_to_full_L2_sec
          @desc += "L2"
        else if @attributes.time_required_to_full
          @desc += "slow plug"
        else
          @desc += "(unknown mode)"
    @estimate = "Est " + @attributes.cruising_range_ac_off.value + " mi"
}

