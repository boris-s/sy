#encoding: utf-8

# Qualities specific to absolute magnitudes.
# 
module SY::AbsoluteMagnitude
  # Absolute magnitude constructor takes :quantity (alias :of) named argument,
  # and :amount named argument, where amount must be nonnegative.
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
                  args[:amount].in_standard_unit
                end
              end
    raise SY::NegativeAmountError,
          "Unsigned magnitudes canot have negative amount!" if @amount < 0
  end

  # For absolute magnitudes, #+ method always returns a result framed in
  # corresponding relative quantity.
  # 
  def + other
    return quantity.new_magnitude( amount + other.amount ) if
      other.quantity == relative_quantity
    return relative_quantity.new_magnitude( amount + other.amount ) if
      quantity == other.quantity
    raise( SY::IncompatibleQuantityError,
           "Unable to perform #{quantity} + #{other.quantity}!" )
  end

  # Addition of absolute magnitudes that returns a result framed as
  # absolute quantity.
  # 
  def add other
    return quantity.new_magnitude( amount + other.amount ) if
      quantity == other.quantity
    raise( SY::IncompatibleQuantityError,
           "Unable to perform #add with #{other.quantity}!" )
  end

  # For absolute magnitudes, #- method always returns a result framed in
  # corresponding relative quantity.
  # 
  def - other
    return quantity.new_magnitude( amount - other.amount ) if
      other.quantity == relative_quantity
    return relative_quantity.new_magnitude( amount - other.amount ) if
      quantity == other.quantity
    raise( SY::IncompatibleQuantityError,
           "Unable to perform #{quantity} + #{other.quantity}!" )
  end

  # Subtraction of absolute magnitudes that returns a result framed as
  # absolute quantity. (With caller being responsible for the result being
  # nonnegative.)
  # 
  def subtract other
    return quantity.new_magnitude( amount + other.amount ) if
      quantity == other.quantity
    raise( SY::IncompatibleQuantityError,
           "Unable to perform #add with #{other.quantity}!" )
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
  def çς
    "Magnitude"
  end
end # class SY::Magnitude
