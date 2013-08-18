# encoding: utf-8

# Setting +AUTOINCLUDE+ constant to _false_ at the beginning of the +sy+ loading
# process prevents automatic inclusion of +SY::ExpressibleInUnits+ in +Numeric+.
# 
module SY
  AUTOINCLUDE = false
end

require_relative '../sy'
