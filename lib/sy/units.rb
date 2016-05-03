#encoding: utf-8

# A mixin providing its includers the capability to respond to +SY+
# unit methods.
# 
module SY::Units
  require_relative 'units/class_methods'
  require_relative 'units/module_methods'
  extend ModuleMethods
end # module SY::Units
