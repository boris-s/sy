#encoding: utf-8

# SY Quantity subclass representing nonstandard
# quantities. Nonstandard quantities may not be multiplied or
# divided by other quantities. They may not enter into quantity
# terms.
# 
class SY::Quantity::Nonstandard < SY::Quantity
  # Inquirer whether this is a nonstandard quantity.
  # 
  def nonstandard?
    false
  end

  # Nonstandard quantities may not be inverted.
  # 
  def inverse
    fail TypeError, <<-ERROR_MESSAGE
      Attempt to invert a nonstandard quantity #{self} has
      occurred, but nonstandard quantities may not be inverted!
    ERROR_MESSAGE
  end

  private

  # Constructs a daughter quantity by multiplying self by a number.
  # Note that the daughter quantity will have to _divide_ its
  # magnitude by the number to convert to parent quantity.
  # 
  def multiply_by_number( number )
    SY::Quantity.nonstandard of: self,
      function: SY::Quantity::Function.ratio( 1 / number )
  end

  # Constructs a daughter quantity by dividing self by a number.
  # Note that the daughter quantity will have to _multiply_ its
  # magnitude by the number to convert it to parent quantity.
  # 
  def divide_by_number( number )
    SY::Quantity.nonstandard of: self,
      function: SY::Quantity::Function.ratio( number )
  end

  # Nonstandard quantity may not be multiplied by a quantity.
  # 
  def multiply_by_quantity( quantity )
    fail TypeError, <<-ERROR_MESSAGE
      Attempt to multiply #{self}, a nonstandard quantity,
      with #{quantity} has occurred, but nonstandard quantities
      may not be multiplied by other quantities!
    ERROR_MESSAGE
  end

  # Nonstandard quantity may not be divided by a quantity.
  # 
  def divide_by_quantity( quantity )
    fail TypeError, <<-ERROR_MESSAGE
      Attempt to divide #{self}, a nonstandard quantity,
      by #{quantity} has occurred, but nonstandard quantities
      may not be divided by other quantities!
    ERROR_MESSAGE
  end
end # class::SY::Quantity::Nonstandard
