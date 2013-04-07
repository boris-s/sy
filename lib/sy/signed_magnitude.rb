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
  end

  # Addition.
  # 
  def + m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    return quantity.absolute.magnitude( amount + m2.amount ) if
      quantity.absolute == m2.quantity
    compat_1, compat_2 = m2.coerce self
    return compat_1 + compat_2
  end

  # Subtraction.
  # 
  def - m2
    return magnitude( amount - m2.amount ) if m2.quantity == quantity.relative
    return quantity.relative.magnitude( amount - m2.amount ) if
      quantity == m2.quantity
    compat_1, compat_2 = m2.coerce self
    return compat_1 - compat_2
  end

  private

  # String describing this class.
  # 
  def çς
    "±Magnitude"
  end
end # module SY::SignedMagnitudeMixin
