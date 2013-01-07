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
  def + other
    return quantity.new_magnitude( amount + other.amount ) if
      quantity == other.quantity
    return absolute_quantity.new_magnitude( amount + other.amount ) if
      other.quantity == absolute_quantity
    raise( SY::IncompatibleQuantityError,
           "Unable to perform #{quantity} + #{other.quantity}!" )
  end

  # Subtraction.
  # 
  def - other
    return quantity.new_magnitude( amount - other.amount ) if
      other.quantity == relative_quantity
    return relative_quantity.new_magnitude( amount - other.amount ) if
      quantity == other.quantity
    raise( SY::IncompatibleQuantityError,
           "Unable to perform #{quantity} + #{other.quantity}!" )
  end

  private

  # String describing this class.
  # 
  def çς
    "±Magnitude"
  end
end # module SY::SignedMagnitudeMixin
