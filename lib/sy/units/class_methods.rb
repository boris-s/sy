#encoding: utf-8

# Class methods for classes that include SY::Units mixin.
# 
module SY::Units::ClassMethods
  # If collision warnings are enabled, this method searches for all
  # possible collisions in the classes that include SY::Units mixin
  # for a single given unit supplied as an argument. 
  # 
  def warn_about_method_collisions( of: unit )
    name, abbrev = unit.name, unit.abbreviation
    return nil
    fail NotImplementedError
    # FIXME: Not implemented!
  end
end # module SY::Units
