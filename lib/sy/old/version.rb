module SY
  VERSION = "2.2.0"
  DEBUG = true # debug mode switch
  # For debugging reasons, there are lines like
  # puts "local variable x is #{x}" if SY::DEBUG
  # scattered over SY source. This constant turns
  # them on or off. This "feature" will be removed
  # once SY is more stable.
end
