# coding: utf-8

# Quantity::Ratio is a function that is used to define a quantity
# as a scaled version of another (parent) quantity. Mathematically,
# it is a simple multiplication by a coefficient. If a quantity has
# a function Ratio( coefficient ), it means that a magnitude of
# that quantity can be converted to its parent quantity by
# multiplying the number by the coefficient. Inverse conversion is
# achieved by dividing the magnitude of the parent quantity by the
# coefficient.
#
class SY::Quantity::Ratio < SY::Quantity::Function
  selector :coefficient

  # Returns a proc that can be used to convert a quantity to its
  # parent quantity.
  # 
  def closure
    c = coefficient
    -> m { m * c }
  end

  # Returns a proc that can be used to convert parent quantity back
  # to its daughter quantity.
  # 
  def inverse_closure
    c = coefficient
    -> m { m / c }
  end

  # The constructor of SY::Quantity::Ratio take only one argument:
  # The coefficient which converts a quantity to its parent
  # quantity. (More precisely, when a magnitude of a quantity can
  # be converted to its parent quantity by multiplying by the
  # coefficient.)
  # 
  def initialize coefficient
    @coefficient = coefficient
  end

  # Inquirer whether the function is of SY::Quantity::Ratio type.
  # Set to return _true_.
  # 
  def ratio?
    true
  end

  # Returns an instance of SY::Quantity::Function inverse to the
  # receiver. This is achieved simply by inverting the @coefficient
  # property.
  # 
  def inverse
    self.class.new( 1 / coefficient )
  end

  # Function composition (f * g). Composition of two Ratio-type
  # functions is handled separately and returns also a Ratio-type
  # function. (Otherwise, the result is a general type
  # SY::Quantity::Function.)
  # 
  def * other
    case other
    when SY::Quantity::Ratio then
      self.class.new( coefficient * other.coefficient )
    else
      super
    end
  end

  # Raising to a power.
  # 
  def ** n
    self.class.new( coefficient ** n )
  end
end # class SY::Quantity::Ratio
