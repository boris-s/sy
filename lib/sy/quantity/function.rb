# coding: utf-8

# require 'active_support/core_ext/module/delegation'

# Some quantities can be defined as functions of other quantities.
# This class represents such mapping of one quantity to another.
# For example, scaled quantities can be expressed as their
# standard quantity scaled by a ratio. For composed quantities,
# function can be found that maps them to other quantities of the
# same dimension. Nonstandard quantities can be expressed as a
# function of their parent quantity. Ruby does have its built-in
# function class, Proc. But procs are generally not bijective, and
# even if they are, it is not easy to figure out the inverse
# function from a Proc. This class represents bijective functions
# which carry their own inverse function with them. For example,
# let's consider dimensionless quantity DozenAmount, whose standard
# quantity is amount. Then dozen amount d is converted into unit
# amount by multiplying by 12: f(m) = m * 12. In Ruby lambda
# notation, this would be f = -> m { m * 12 }. But the although
# everybody knows that the inverse conversion is achieved by
# dividing by 12, having the object -> m { m * 12 }, there is no
# easy way to find that its inverse is -> m { m / 12 }. For this
# reasons, this class is introduced.
#
class SY::Quantity::Function
  require_relative 'ratio'

  class << self
    # Constructor of an identity function.
    #
    def identity
      SY::Quantity::Ratio.new 1
    end

    # Simple multiplication by a coefficient. Example: Function
    # DozenAmount is constructed as Function.ratio( 12 ). Closure
    # of this function is -> m { m * 12 }, inverse closure is
    # -> m { m / 12 }. This lambda can be used to convert dozens
    # into units and vice versa.
    # 
    def ratio coefficient
      SY::Quantity::Ratio.new( coefficient )
    end

    # Simple addition of a constant number. Example: Function
    # CelsiusTemperature is created as Function.addition( 253.15 )
    # Its closure is -> m { m + 253.15 }. It can be used to convert
    # degrees of Celsius into kelvins. Its inverse closure is
    # -> m { m - 253.15 }, which can be used to convert kelvins
    # back to degrees of Celsius.
    # 
    def addition constant
      "offset".( constant ).must.be_a Numeric
      new( -> m { m + constant }, inverse: -> m { m - constant } )
    end

    # TODO:
    # Think about linear, logarithmic and negative logarithmic
    # constructors (for degrees of Fahrenheit, decibels, pH etc.)
  end

  selector :closure, :inverse_closure
  delegate :call, :[], to: :closure

  # The constructor expects the function closure (in Ruby lambda
  # notation) as the first argument. The second mandatory parameter
  # :inverse expects inverse closure as its argument. Example
  #
  # Quantity::Function.new -> m { m * 2 }, inverse: -> m { m / 2 }
  #
  def initialize( closure, inverse: )
    @closure = "first argument".( closure ).must.be_a Proc
    @inverse_closure =
      "argument of inverse:".( inverse ).must.be_a Proc
  end

  # Inquirer whether the function is of SY::Quantity::Ration type.
  # 
  def ratio?
    false
  end

  # Returns an instance of SY::Quantity::Function, which is an
  # inverse function of the reeceiver. Since SY::Quantity::Function
  # instances carry their inverse closures with them, inverting
  # them is simply achieved by swapping the function closure
  # (accessible via +#closure+ method) and its inverse closure
  # (accessible via +#inverse_closure+ method).
  # 
  def inverse
    self.class.new( inverse_closure, inverse: closure )
  end

  # Function composition (f * g).
  # 
  def * other
    f, g = closure, other.closure 
    f_inv, g_inv = inverse_closure, other.inverse_closure
    self.class.new -> m { f.( g.( m ) ) },
                   inverse: -> m { g_inv.( f_inv.( m ) ) }
  end

  # Composition with inverse of the other function.
  #
  def / other
    self * other.inverse
  end

  # Raising to a power.
  # 
  def ** n
    "exponent".( n ).must.be_kind_of Integer
    return self.class.identity if n.zero?
    return inverse ** -n if n < 0
    f, _f = closure, inverse_closure
    self.class.new -> m { n.times.inject m do |m, _| f.( m ) end },
      inverse: -> m { n.times.inject m do |m, _| _f.( m ) end }
  end
end # class SY::Quantity::Function
