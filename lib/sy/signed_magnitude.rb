# -*- coding: utf-8 -*-
# Qualities specific to relative magnitudes (mixin).
# 
module SY::SignedMagnitude
  # Relative magnitude constructor takes :quantity (alias :of) argument and
  # :amount argument. Amount is allowed to be negative.
  # 
  def initialize( of: nil, amount: nil )
    puts "Constructing AbsoluteMagnitude of #{of}, amount: #{amount}" if SY::DEBUG
    fail ArgumentError, "Quantity (:of) argument missing!" if of.nil?
    @quantity = of
    @amount = case amount
              when Numeric then
                puts "This amount is a Numeric, using it directly" if SY::DEBUG
                amount
              when nil then
                puts "This amount is 'nil', using 1 instead" if SY::DEBUG
                1
              else
                begin
                  puts "Amount #{amount} will be reframed to #{@quantity}" if SY::DEBUG
                  amount.( @quantity ).amount
                rescue NameError, NoMethodError
                  puts "fail, amount #{amount} will be used directly" if SY::DEBUG
                  amount
                end
              end
  end

  # Addition.
  # 
  # TODO: Figure out which module comes on the top in Quantity@Magnitude, whether Magnitude
  # or SignedMagnitude, and therefore, whether it is necessary to adjust this method.
  def + m2
    return magnitude( amount + m2.amount ) if quantity == m2.quantity
    return quantity.absolute.magnitude( amount + m2.amount ) if
      quantity.absolute == m2.quantity
    compat_1, compat_2 = m2.coerce self
    return compat_1 + compat_2
  end

  # Subtraction.
  #
  # TODO: ditto
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
