#encoding: utf-8

# Qualities specific to absolute magnitudes.
# 
module SY::AbsoluteMagnitude
  # Absolute magnitude constructor takes :quantity (alias :of) named argument,
  # and :amount named argument, where amount must be nonnegative.
  # 
  def initialize args={}
    @quantity = args[:quantity] || args[:of]
    amnt = args[:amount]
    @amount = case amnt
              when Numeric then amnt
              when nil then 1
              else
                begin
                  amnt.amount
                rescue NameError, NoMethodError
                  amnt
                end
              end
    raise SY::MagnitudeError,
          "Unsigned magnitudes canot have negative amount!" if @amount < 0
  end

  # For absolute magnitudes, #+ method always returns a result framed in
  # corresponding relative quantity.
  # 
  def + m2
    return magnitude amount + m2.amount if m2.quantity == quantity.relative
    return quantity.relative.magnitude( amount + m2.amount ) if
      quantity == m2.quantity
    m1, m2 = m2.coerce( self )
    return m1 + m2
    raise SY::QuantityError, "Unable to perform #{quantity} + #{m2.quantity}!"
  end

  # Addition of absolute magnitudes that returns a result framed as
  # absolute quantity.
  # 
  def add m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    m1, m2 = m2.coerce( self )
    return m1.add m2
    raise SY::QuantityError, "Unable to perform #add with #{m2.quantity}!"
  end

  # For absolute magnitudes, #- method always returns a result framed in
  # corresponding relative quantity.
  # 
  def - m2
    return magnitude amount - m2.amount if m2.quantity == quantity.relative
    return quantity.relative.magnitude( amount - m2.amount ) if
      quantity == m2.quantity
    m1, m2 = m2.coerce( self )
    return m1 - m2
    raise( SY::QuantityError, "Unable to perform #{quantity} - #{m2.quantity}!" )
  end

  # Subtraction of absolute magnitudes that returns a result framed as
  # absolute quantity. (With caller being responsible for the result being
  # nonnegative.)
  # 
  def subtract m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    m1, m2 = m2.coerce( self )
    return m1.subtract m2
    raise( SY::QuantityError, "Unable to perform #add with #{m2.quantity}!" )
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
