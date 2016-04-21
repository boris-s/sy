# coding: utf-8

# Quantity::Function serves to define a quantity as a function of
# another (parent) quantity. For example, CelsiusTemperature is
# defined as Temperature offset by 273.15. Many quantities are
# defined as simply scaled versions of their parent quantities
# (eg. MoleAmount vs. Amount is scaled by Nᴀ). Since two-way
# conversion between parent and daughter quantities is needed, and
# since standard Proc fuctions are not easily invertible, instances
# of Quantity::Function carry both forward and inverse closure.
#
class SY::Quantity::Function
  # Scaled quantities have function Quantity::Ratio
  require_relative 'ratio'

  class << self
    # Constructor of identity function.
    #
    def identity
      SY::Quantity::Ratio.new 1
    end

    # Constructor of SY::Quantity::Ratio. Example:
    #
    #   f = SY::Function.ratio( 12 )
    #   
    # can be used to construct DozenAmount
    # 
    #   DozenAmount = SY::Quantity.scaled( Amount, function: f )
    # 
    def ratio coefficient
      SY::Quantity::Ratio.new( coefficient )
    end

    # Constructor of an offset function. Example:
    #
    #   f = SY::Function.offset( 273.15 )
    #   
    # can be used to construct CelsiusTemperature
    # 
    #   CelsiusTemperature =
    #     SY::Quantity.nonstandard( Temperature, function: f )
    #
    def offset constant
      "offset".( constant ).must.be_a Numeric
      new( -> m { m + constant }, inverse: -> m { m - constant } )
    end
  end

  # Selector #closure of instances of SY::Quantity::Function gives
  # access to @closure property, holding a Proc-type function that
  # can be used to convert a quantity to its parent quantity.
  # 
  selector :closure

  # Selector #inverse_closure of instances of
  # SY::Quantity::Function gives access to @inverse_closure
  # property, a Proc-type function inverse to the function
  # available under selector #closure.
  # 
  selector :inverse_closure

  delegate :call, :[], to: :closure

  # The constructor expects a Proc-type argument and its inverse
  # under :inverse keyword. Example:
  #
  # f = Quantity::Function
  #       .new( -> m { m * 2 }, inverse: -> m { m / 2 } )
  #
  def initialize( closure, inverse: )
    @closure = "first argument".( closure )
      .must.be_a Proc
    @inverse_closure = "argument of inverse:".( inverse )
      .must.be_a Proc
  end

  # Inquirer whether the function is of SY::Quantity::Ratio type.
  # Set to return _false_ by default, redefined to return _true_
  # in SY::Quantity::Ratio.
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
