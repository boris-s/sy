# -*- coding: utf-8 -*-
# Qualities specific to relative magnitudes (mixin).
# 
module SY::SignedMagnitude
  # Relative magnitude constructor takes :quantity (alias :of) argument and
  # :amount argument. Amount is allowed to be negative.
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
                rescue NameError, NoMethodError
                  amount
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
