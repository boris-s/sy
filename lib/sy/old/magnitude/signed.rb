# encoding: utf-8

class SY::Magnitude
  # Qualities specific to relative magnitudes (mixin).
  # 
  module Signed
    # Addition. Returns absolute quantity if operand is absolute, otherwise
    # behaves generically.
    # 
    def + m2
      return quantity.absolute.magnitude( amount + m2.amount ) if
        quantity.absolute == m2.quantity
      super
    end

    private

    # Generic descriptive string for the class.
    # 
    def çς
      "Magnitude±"
    end
  end # module Signed
end # class SY::Magnitude
