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
    # ```ruby
    # q = Quantity.of Dimension.new( "L.T⁻²" )
    # ```
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

    # FIXME: The question is: Do quantities need their composition?
    # Do they need to know how they were defined? It would seem to me
    # that the answer is no, so long as @function is well handled...
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

  delegate :multiplication_table, to: "self.class"

  # Applies multiplication table to a quantity term.
  # 
  def apply_multiplication_table( **hash )
    fail NotImplementedError

    # First thing, we will check the multiplication table
    # for the quantity term. If it is not found there, we
    # will have to start looking into what we got.
    # 
    # But let's not do it quite yet. I imagine this
    # multiplication table here as a kind of second
    # cache to save all the code below, while the real
    # multiplication table is defined by Term class.
    # 
    # multiplication_table[ { self => 1, hash => -1 } ]

    # hash should be of size 1, with a quantity as its key
    # and either 1 or -1 as its value (exponent).

    fail ArgumentError unless hash.size == 1
    q2, exp = hash.to_a
    fail ArgumentError unless exp == 1 || exp == -1
    f, g = function, q2.function

    if f.ratio? and g.ratio? then
      term = Term[ self => 1, other => exp ]
    else
      msg = "Multiplication or division of two quantities requires that both " +
            "are either standard quantities or scaled versions of standard " +
            "quantities. But %s!"
      info = if f.ratio? then
               "quantity #{g} is not a scaled version of #{g.standard}"
             elsif g.ratio? then
               "quantity #{f} is not a scaled version of #{f.standard}"
             else
               "neither #{f} nor #{g} is a scaled version of standard " +
                 "quantities of their dimensions"
             end
      fail TypeError, msg % info
    end

    # Now we call Term#simplify or Term#beautify or whatever method will tell
    # us to which quantity does the term reduce.
    result = term.reduce_to_quantity

    # And finally, we cache the term in the multiplication table here.
    multiplication_table.cache( hash => result )

    return result
  end

  # FIXME: Write the description.
  # 
  def + other
    fail NotImplementedError
  end

  # FIXME: Write the description.
  # 
  def -@ other
    fail NotImplementedError
  end

  # FIXME: Write the description.
  # 
  def - other
    fail NotImplementedError
  end

  # Multiplication of a quantity can occur with another quantity, or with a
  # number. When multiplied by a number, a new quantity is constructed as
  # expected. When multiplied by a quantity, both quantities are required to
  # have simple ratio as their function. (Internally, the method uses
  # quantity multiplication table to avoid creation of the excessive number
  # of SY::Quantity instances.)
  # 
  def * other
    case other
    when SY::Quantity then
      apply_multiplication_table( other => 1 )
    when Numeric
      fail NotImplementedError
      # FIXME: Maybe this is wrong and function / Ratio.new( other ) is right.
      self.class.new of: dimension, function: function * Ratio.new( other )
    else
      fail TypeError, "A quantity can only be multiplied by another " +
                      "quantity or by a number!"
    end
  end

  # FIXME: Write the description.
  # 
  def inverse
    fail NotImplementedError
  end

  # A quantity can be divided by another quantity, or by a number. When divided
  # by a number, a new quantity is constructed as expected. When divided by
  # a quantity, both quantities are required to have simple ratio as their
  # function. (Internally, the method uses quantity multiplication table to
  # avoid creation of the excessive number of SY::Quantity instances.)
  # 
  def / other
    case other
    when SY::Quantity then
      apply_multiplication_table( other => -1 )
    when Numeric
      fail NotImplementedError
      # FIXME: Maybe this is wrong and function * Ratio.new( other ) is right.
      self.class.new of: dimension, function: function / Ratio.new( other )
    else
      fail TypeError, "A quantity can only be multiplied by another " +
                      "quantity or by a number!"
    end
  end

  # FIXME: Write the description.
  # 
  def ** num
    fail NotImplementedError
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
