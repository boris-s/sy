# coding: utf-8

# require 'active_support/core_ext/module/delegation'

# Ratio is a quantity function meaning that the quantity is simply upscaled
# or downscaled version of the standard quantity of the dimension.
#
class SY::Quantity::Ratio < SY::Quantity::Function
  selector :coefficient

  def closure
    c = coefficient
    -> m { m * c }
  end

  def inverse_closure
    c = coefficient
    -> m { m / c }
  end

  def initialize coefficient
    @coefficient = coefficient
  end

  # Inquirer whether the function is a SY::Quantity::Ratio.
  # 
  def ratio?
    true
  end

  # Returns an instance of SY::Quantity::Function inverse to the
  # receiver. This is achieved simply by swapping the function closure
  # (accessible via +#closure+ method) and its inverse closure (accessible
  # via +#inverse_closure+ method).
  # 
  def inverse
    self.class.new( 1 / coefficient )
  end

  # Function composition (f * g).
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
end
