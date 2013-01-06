#encoding: utf-8

# This class represents a signed magnitude (can be negative).
# 
module SY::MagnitudeDifference
  class << self
    # Constructor of relative magnitudes.
    # 
    def of qnt, args={}
      return qnt.relative_quantity.new_magnitude ꜧ[:amount]
    end
  end

  include SY::Magnitude
  include SY::RelativeMagnitudeMixin
end
