# encoding: utf-8

class SY::Magnitude
  # Qualities specific to absolute magnitudes (mixin).
  # 
  # Absolute magnitudes represent physical amounts that cannot be negative.
  # (There cannot be temperature of -1.K or an object of weight -1.kg.)
  # 
  # Binary operator methods #+ and #- used absolute magnitudes return signed
  # magnitudes, while absolute magnitude has additional methods #add and
  # #subtract, that return absolute magnitudes (or fail should the result be
  # negative). There is also method #take, which perfoms #subtract whilst
  # guarding against subtraction of more than there is to subtract.
  # 
  module Absolute
    # For absolute magnitudes, the amount must be nonnegative.
    # 
    def initialize( *args )
      super
      fail SY::MagnitudeError, "Attempt to construct an unsigned magnitude " +
        "(SY::AbsoluteMagnitude) with a negative amount." if amount < 0
    end

    # For two absolute magnitudes, binary + returns a signed magnitude. For one
    # absolute and one relative magnitude, absolute magnitude is returned.
    # 
    def + m2
      return magnitude amount + m2.amount if m2.quantity == quantity.relative
      return quantity.relative.magnitude( amount + m2.amount ) if
        quantity == m2.quantity
      return self if m2.equal? SY::ZERO
      apply_through_coerce :+, m2
    end

    # Addition that returns an absolute magnitude.
    # 
    def add m2
      ( self + m2 ).absolute
    end

    # For absolute magnitudes, binary - returns a signed magnitude. For one
    # absolute and one relative magnitude, absolute magnitude is returned,
    # raising error should the result be negative.
    # 
    def - m2
      return magnitude amount - m2.amount if m2.quantity == quantity.relative
      return quantity.relative.magnitude( amount - m2.amount ) if
        quantity == m2.quantity
      return self if m2.equal? SY::ZERO
      apply_through_coerce :-, m2
    end

    # Subtraction that returns an absolute magnitude, raising error should the
    # result be negative.
    # 
    def subtract m2
      ( self - m2 ).absolute
    end

    # Subtraction guarded against subtraction of an amount greater than the
    # receiver magnitude has. Unlike #subtract, #take returns a pair of two
    # values: The amount actually subtracted, and the actual result of the
    # subtraction (amount remaining after subtraction). 
    # 
    def take m2
      m2 = m2.absolute
      actually_taken = [ self, m2 ].min
      return actually_taken, self.subtract( m2 )
    end

    private

    # Generic descriptive string for the class.
    # 
    def çς
      "Magnitude"
    end
  end # module Absolute
end # class SY::Magnitude
