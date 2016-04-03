# coding: utf-8

# require 'active_support/core_ext/module/delegation'

# Every quantity has a function, which maps from the quantity to its standard
# quantity. More precisely, having a magnitude m of quantity Q with function
# f, this can be transformed to a magnitude s of its standard quantity by
# expression: s = f( m ). In Ruby, functions are conveniently expressed as
# closures, but in converting quantities, we are interested both in function
# and its inverse function. Moreover, functions of quantities are frequently
# quite simple. For example, let's consider dimensionless quantity
# DozenAmount, whose standard quantity is amount. Then the amount d in dozens
# is converted to the amount simply by multiplying by twelve: f(m) = m *
# 12. We could express this as a lambda: f = -> m { m * 12 }. But the problem
# is, that when we want to convert Amount to DozenAmount, ordinary Ruby
# lambdas offer no easy way of finding their inverse function. For these
# reasons, Quantity::Function class is introduced here.
#
class SY::Quantity::Function
  class << self
    # Constructor of an identity function.
    #
    def identity
      new( -> m { m }, inverse: -> m { m } )
    end

    # Simple multiplication by a constant coefficient. Example: Function of
    # DozenAmount is Function.multiplication( 12 ). Lambda of this function
    # is -> m { m * 12 }. This lambda can be used to convert dozens into
    # units. Its inverse is -> m { m / 12 }, which can be used to convert
    # units into dozens.
    # 
    def multiplication coefficient
      coefficient.aT_is_a Numeric
      fail TypeError, "Coefficient must be non-zero!" if coefficient == 0
      new( -> m { m * coefficient }, inverse: -> m { m / coefficient } )
    end

    # Simple addition of a constant number. Example: Function of
    # CelsiusTemperature is (approximately) Function.addition( 253.15
    # ). Lambda of this function is -> m { m + 253.15 }. This lambda can be
    # used to convert degrees of Celsius into kelvins. Its inverse is -> m {
    # m - 253.15 }, which can be used to convert kelvins back to degrees of
    # Celsius.
    # 
    def addition constant
      constant.aT_is_a Numeric
      new( -> m { m + constant }, inverse: -> m { m - constant } )
    end

    # TODO: Think about .linear, .logarithmic and .negative_logarithmic
    # (for decibels, pH etc.) as seen in old measure.rb.
  end

  selector :closure, :inverse_closure
  delegate :call, :[], to: :closure

  # The constructor expects the function in lambda notation as the first
  # argument and the inverse function in lambda notation as +inverse:+
  # argument. Example:
  #
  # Quantity::Function.new -> m { m * 2 }, inverse: -> m { m / 2 }
  #
  def initialize closure,
                 inverse: fail( ArgumentError, "Inverse function required!" )
    @closure = closure.aT_is_a Proc
    @inverse_closure = inverse.aT_is_a Proc
  end

  # Returns an instance of SY::Quantity::Function inverse to the
  # receiver. This is achieved simply by swapping the function closure
  # (accessible via +#closure+ method) and its inverse closure (accessible
  # via +#inverse_closure+ method).
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
    n.aT_is_a Integer
    return self.class.identity if n.zero?
    return inverse ** -n if n < 0
    f, _f = closure, inverse_closure
    self.class.new -> m { n.times.inject m do |m, _| f.( m ) end },
                   inverse: -> m { n.times.inject m do |m, _| _f.( m ) end }
  end
end
