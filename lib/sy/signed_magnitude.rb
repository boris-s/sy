#encoding: utf-8

# Qualities specific to relative magnitudes.
# 
module SY::SignedMagnitude
  # Relative magnitude constructor takes :quantity (alias :of) named argument,
  # and :amount named argument, where :amount is allowed to be negative.
  # 
  def initialize args={}
    @quantity = args[:quantity] || args[:of]
    @amount = begin
                BigDecimal( args[:amount] )
              rescue ArgumentError
                BigDecimal( args[:amount], SY::NUMERIC_FILTER )
              rescue TypeError => err
                if args[:amount].nil? then
                  BigDecimal( "1", SY::NUMERIC_FILTER )
                else
                  raise err # tough luck
                end
              end
  end

  # Addition.
  # 
  def + m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    return quantity.absolute.magnitude( amount + m2.amount ) if
      m2.quantity == quantity.absolute
    raise SY::QuantityError, "Unable to perform #{quantity} + #{m2.quantity}!"
  end

  # Subtraction.
  # 
  def - m2
    return magnitude( amount - m2.amount ) if m2.quantity == quantity.relative
    return quantity.relative.magnitude( amount - m2.amount ) if
      quantity == m2.quantity
    raise SY::QuantityError, "Unable to perform #{quantity} + #{m2.quantity}!"
  end

  private

  # String describing this class.
  # 
  def çς
    "±Magnitude"
  end
end # module SY::SignedMagnitudeMixin
