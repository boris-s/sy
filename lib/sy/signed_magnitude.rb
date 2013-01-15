#encoding: utf-8

# Qualities specific to relative magnitudes.
# 
module SY::SignedMagnitude
  # Relative magnitude constructor takes :quantity (alias :of) named argument,
  # and :amount named argument, where :amount is allowed to be negative.
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
    # BigDecimal is not going to be used by default anymore, so now these
    # are only remaining remarks about BigDecimal use.
    # 
    # @amount = begin
    #             BigDecimal( args[:amount] )
    #           rescue ArgumentError
    #             BigDecimal( args[:amount], SY::NUMERIC_FILTER )
    #           rescue TypeError => err
    #             if args[:amount].nil? then
    #               BigDecimal( "1", SY::NUMERIC_FILTER )
    #             else
    #               raise err # tough luck
    #             end
    #           end
  end

  # Addition.
  # 
  def + m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    return quantity.absolute.magnitude( amount + m2.amount ) if
      m2.quantity == quantity.absolute
    m1, m2 = m2.coerce( self )
    return m1 + m2
    raise SY::QuantityError, "Unable to perform #{quantity} + #{m2.quantity}!"
  end

  # Subtraction.
  # 
  def - m2
    return magnitude( amount - m2.amount ) if m2.quantity == quantity.relative
    return quantity.relative.magnitude( amount - m2.amount ) if
      quantity == m2.quantity
    m1, m2 = m2.coerce( self )
    return m1 - m2
    raise SY::QuantityError, "Unable to perform #{quantity} + #{m2.quantity}!"
  end

  private

  # String describing this class.
  # 
  def çς
    "±Magnitude"
  end
end # module SY::SignedMagnitudeMixin
