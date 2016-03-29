# coding: utf-8

# Qualities specific to absolute magnitudes (mixin).
#
# Absolute magnitude may not be negative  – physical amounts cannot have
# negative number of unit objects. (<em>Difference</em> between magnitudes
# (relative magnitude) can be positive as well as negative.
#
# While ordinary #+ and #- methods of absolute magnitudes return relative
# magnitudes, absolute magnitudes have additional methods #add and #subtract,
# that return absolute magnitudes (it is the responsibility of the caller to
# avoid negative results). Furthermore, absolute magnitudes have one more
# special method #take, which perfoms #subtract whilst protecting against
# subtraction of more than, there is to take.
# 
module SY::AbsoluteMagnitude
  # Absolute magnitude constructor takes :quantity (alias :of) named argument,
  # and :amount named argument, where amount must be nonnegative.
  # 
  def initialize( of: nil, amount: nil )
    fail ArgumentError, "Quantity (:of) argument missing!" if of.nil?
    @quantity = of
    @amount = case amount
              when Numeric then amount
              when nil then 1
              else
                begin
                  amount.( @quantity ).amount
                rescue NameError, NoMethodError; amount end
              end
    fail SY::MagnitudeError, "Attempt to construct an unsigned magnitude " +
      "(SY::AbsoluteMagnitude) with a negative amount." if @amount < 0
  end

  # For absolute magnitudes, #+ method always returns a result framed in
  # corresponding relative quantity.
  # 
  def + m2
    return magnitude amount + m2.amount if m2.quantity == quantity.relative
    return quantity.relative.magnitude( amount + m2.amount ) if
      quantity == m2.quantity
    return self if m2.equal? SY::ZERO
    fail SY::QuantityError, "Unable to perform #{quantity} + #{m2.quantity}!"
  end

  # Addition of absolute magnitudes that returns a result framed as
  # absolute quantity.
  # 
  def add m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    return self if m2.equal? SY::ZERO
    fail SY::QuantityError, "Unable to perform #add with #{m2.quantity}!"
  end

  # For absolute magnitudes, #- method always returns a result framed in
  # corresponding relative quantity.
  # 
  def - m2
    return magnitude amount - m2.amount if m2.quantity == quantity.relative
    return quantity.relative.magnitude( amount - m2.amount ) if
      quantity == m2.quantity
    return self if m2.equal? SY::ZERO
    fail SY::QuantityError, "Unable to perform #{quantity} - #{m2.quantity}!"
  end

  # Subtraction of absolute magnitudes that returns a result framed as
  # absolute quantity. (With caller being responsible for the result being
  # nonnegative.)
  # 
  def subtract m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    return self if m2.equal? SY::ZERO
    fail SY::QuantityError, "Unable to perform #add with #{m2.quantity}!"
  end

  # "Subtraction" of absolute magnitudes, that never takes more thant the
  # amount from which subtraction is being performed. But for this reason,
  # unlike regular #subtract, it is not known in advance what amount will
  # be subtracted. Returns an array of two values: first one is the amount
  # actually subtracted (which may differ from the amount asked for), and
  # the second is the actual result of the subtraction (amount left). The
  # latter will be zero if attempt is made to subtract greater amount from
  # a smaller one.
  # 
  def take other
    actually_taken = [ self, other ].min
    return [ actually_taken, other.subtract( take ) ]
  end

  private

  # String describing this class.
  # 
  def çς; "Magnitude" end
end # class SY::AbsoluteMagnitude
