#encoding: utf-8

# require 'y_support/core_ext/module'
# require 'y_support/unicode'

# Metrological quantity is the key class of SY. A quantity has its physical
# dimension, but beyond that, it is characterized by its physical meaning and
# context in which it is used. For example, SY::Amount and SY::MoleAmount are
# both dimensionless quantities, but the second one counts in moles and is
# used in the context of physical chemistry. Quantities SY::ThermalCapacity
# and SY::Entropy have both the same physical dimension, but they have
# different physical meaning. It is not easy to programatically capture the
# conventions regarding the use of quantities in the different fields of
# science. SY achieves this by properly defining SY::Quantity class and the
# mutual relationships between its instances.
# 
class SY::Quantity
  require_relative 'quantity/function'
  ★ NameMagic

  # This error indicates incompatible quantities.
  # 
  class Error < TypeError; end

  class << self
    # Constructor of a new quantity of the supplied dimension. Example:
    # q = Quantity.of Dimension.new( "L.T⁻²" )
    # 
    # FIXME: Figure out how to denote Ruby code in the documentation.
    # 
    def of dimension, **options
      new dimension: dimension, **options
    end

    # Constructor of a new dimensionless quantity.
    # 
    def dimensionless **options
      new dimension: SY::Dimension.zero, **options
    end

    # Returns standard quantity of the supplied dimension. Example:
    # 
    # q = Quantity.standard of: Dimension.new( "L.T⁻²" )
    # 
    def standard **options
      SY::Dimension[ options[:dimension] || options[:of] ].standard_quantity
    end
  end

  selector :dimension, :function

  # Quantity takes dimension as a parameter (can be supplied under :dimension
  # or :of keyword).
  # 
  def initialize **options
    @dimension = SY::Dimension[ options.may_have :dimension, syn!: :of ]
    param_class!( { Magnitude: SY::Magnitude }, with: { quantity: self } )
    @function = if options.has? :function then
                  options[ :function ].aT_is_a SY::Quantity::Function
                else
                  SY::Quantity::Function.identity
                end
  end

  # # Convenience shortcut to register a name of the basic unit of
  # # self in the UNITS table. Admits either syntax:
  # # quantity.name_basic_unit "name", symbol: "s"
  # # or
  # # quantity.name_basic_unit "name", "s"
  # def name_basic_unit( ɴ, oj = nil )
  #   u = Unit.basic( oj.respond_to?(:keys) ? oj.merge( of: self, ɴ: ɴ ) :
  #                   { of: self, ɴ: ɴ, abbr: oj } )
  #   BASIC_UNITS[self] = u
  # end
  # alias :ɴ_basic_unit :name_basic_unit

  # # #basic_unit convenience reader of the BASIC_UNITS table
  # def basic_unit; BASIC_UNITS[self] end

  # # #fav_units convenience reader of the FAV_UNITS table
  # def fav_units; FAV_UNITS[self] end

  # # #to_s convertor
  # def to_s; "#{name.nil? ? "quantity" : name} (#{dimension})" end
    
  # # Inspector
  # def inspect
  #   "#{name.nil? ? 'unnamed quantity' : 'quantity "%s"' % name} (#{dimension})"
  # end

  # Arithmetics

  # FIXME: Write the description.
  # 
  def + other
  end

  # FIXME: Write the description.
  # 
  def -@ other
  end

  # FIXME: Write the description.
  # 
  def - other
  end

  # The result of the multiplication operator depends on the type of the
  # supplied operand. If the operand is another quantity, the result of the
  # multiplication is their product. If the operand is a number, the result
  # of the multiplication is a quantity scaled down by the operand.
  # 
  def * other
    # TODO: Here comes the fun part. It turns out, that it would be worthwile
    # to recognize different subtypes of quantities' functions. Standard
    # quantities always have identity function as their function, so it seems
    # as if they did not even need one. But if we practice redeclaring which
    # quantity is standard (for its dimension) later, then it need be known
    # that only quantities with identity function can become standard
    # quantities. So far so simple.
    # 
    # But as soon as we start multiplying the quantities, it turns out that
    # for the quantities, which are upscaled or downscaled versions of their
    # respective standard quantities, their function can be determined quite
    # easily. But if any of the multiplicands have some other function than
    # scaling by a factor, it is no longer possible to ascribe function to
    # the resulting quantity. In this way, the resulting quantity has pretty
    # much nothing to do with the multiplicands. It can sometimes seem that
    # the dimension of the resulting quantity arises from the multiplicands'
    # dimension, but this is just an illusion. Multiplication of two
    # quantities together should be prohibited if any of them has any other
    # function than simple scaling.
    # 
    # So as the first thing, we need two kinds of quantity functions.
    # 
    case other
    when SY::Quantity then
      fail TypeError, "Quantities with functions other than ratios cannot be multiplied together!" unless function.is_a? SY::Quantity::Ratio and other.function.is_a? SY::Quantity::Ratio
    else 
      other.aT_is_a Numeric
      # FIXME
    end

  end

  # FIXME: Write the description.
  # 
  def inverse
  end

  # FIXME: Write the description.
  # 
  def / other
    #   msg = "Quantities only divide with Quantities, Dimensions and " +
    #     "Numerics (which leaves them unchanged)"
    #   case other
    #   when Numeric then self
    #   when Quantity then self.class.of dimension - other.dimension
    #   when Dimension then self.class.of dimension - other
    #   else raise ArgumentError, msg end
  end

  # FIXME: Write the description.
  # 
  def ** num
  # self.class.of self.dimension * Integer( num )
  end

  # FIXME: Write the description.
  # 
  def to_s
    super # FIXME: This should be a customized method like in Dimension
  end

  # FIXME: Write the description.
  # 
  def inspect
    super # FIXME: This should be a customized method like in Dimension
  end
end # class SY::Quantity
