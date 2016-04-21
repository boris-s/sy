# coding: utf-8

# Metrological quantity is the key class of SY. A quantity may have
# its physical dimension, but beyond that, it is characterized by
# its meaning and context in which it is used. For example,
# quantities SY::Amount and SY::MoleAmount are both dimensionless,
# but the second one counts in moles and is used in the context of
# chemistry. Quantities SY::ThermalCapacity and SY::Entropy have
# both the same physical dimension, but their meaning is different.
# It is not easy to capture the conventions of different fields of
# science in a single abstraction. SY therefore does not try to
# cover all existing conventions out there. Instead, it tries to
# define SY::Quantity in a way that can cover 80% of usecases
# within a reasonably concise abstraction.
# 
# Everybody knows that physical quantities have dimensions. Time
# has dimension TIME, Speed has dimension LENGTH.TIME⁻¹,
# ThermalCapacity has dimension MASS.LENGTH².TIME⁻².TEMPERATURE⁻¹,
# while Amount and MoleAmount are dimensionless. Quantities can
# undergo multiplication operation with other quantities, and the
# result is a composed quantity. Quantity term (reified as
# SY::Quantity::Term class) is a product of a number of quantities
# raised to certain exponents (such as "Length.Time⁻¹").
#
# It turns out that when one tries to capture quantity in a
# software abstraction, the quantities need to know how did they
# arise from other quantities. In other words, quantities need to
# know their composition. This wouldn't be the case if dimensional
# analysis was sufficient to simplify quantity terms. But dimension
# is not enough to tell that Molarity is not the same thing as
# Amount.Length⁻³ when both quantities have the same dimension
# (LENGTH⁻³). Moreover, certain quantities represent specific
# functions of other quantities. For example, CelsiusTemperature is
# converted to Temperature (measured in kelvins) by adding 273.15
# to its magnitude. MoleAmount is Amount scaled by Avogadro
# constant. In SY, function which maps quantity to its parent
# quantity is reified as class SY::Quantity::Function. It might
# seem that the function alone might be enough to distinguish
# Molarity from Amount.Length⁻³, since the former can be converted
# to the latter by multiplying the magnitude by Avogadro constant,
# but putting this into practice would force too much
# responsibility on SY::Quantity::Function class. It is better if
# the way quantities are composed of other quantities is reified as
# SY::Quantity::Composition class. Although there is global
# quantity composition table (SY::Quantity::Composition::Table),
# when you do calculation with units, anonymous Quantity instances
# are temporarily constructed, and these should not be induced to
# the global composition table. For this reason, Quantity instances
# need to carry its composition as their own attribute. In short,
# inner workings of SY::Quantity are too complicated for you to
# understand and you'd better rely that I spent a lot of
# computational effort to get it right. Just joking.
# 
# Due to the above, 4 types of quantities are recognized in SY:
# standard, nonstandard, scaled and composed. Standard quantities
# are unique to each dimension and their function is implicitly set
# to identity function. Scaled quantities arise by multiplying
# already defined quantities by a ratio. Composed quantities are
# constructed by indicating the quantity term from which they
# arise. Finally, nonstandard quantities are defined by indicating
# the (unary) functions of other quantities other than simple
# scaling. For example, pH is a nonstandard quantity which arises
# as a negative logarithm of concentration. CelsiusTemperature is
# a nonstandard quantity arising by offseting standard Temperature
# (whose standard unit is kelvin). Examples:
# 
# 1. Standard quantities belong to a dimension and their function
#    is implicitly identity function.
# 
#      Length = Quantity.standard of: Dimension[ :LENGTH ]
# 
# 2. Scaled quantities arise from a preexisting quantity (other
#    than a nonstandard quantity) scaled by a ratio.
# 
#      Nᴀ = 6.02214e23
#      MoleAmount = Quantity.scaled of: Amount, ratio: Nᴀ
# 
#    Syntactic sugar for the above is:
# 
#      MoleAmount = Amount / Nᴀ
# 
# 3. Composed quantities arise from quantity terms. (Note that
#    quantity terms may not include nonstandard quantities.)
# 
#      Speed = Quantity.composed( Length: 1, Time: -1 )
# 
#    Syntactic sugar for the above is:
# 
#      Speed = Length / Time
# 
# 4. Finally, nonstandard quantities are defined by indicating a
#    function of another quantity other than scaling by a ratio.
# 
#      CelsiusTemperature =
#        Quantity.nonstandard of: Temperature,
#                             function: -> x { x + 273.15 },
#                             inverse: -> x { x - 273.15 }
# 
#    There is syntactic sugar available for this particular type
#    of nonstandard quantities:
# 
#      CelsiusTemperature = Temperature - 273.15
# 
#    Note, however, that this syntactic sugar does not apply to
#    more complex nonstandard quantities, which have to be defined
#    explicitly using Quantity.nonstandard constructor.
# 
class SY::Quantity
  ★ NameMagic and permanent_names!

  require_relative 'quantity/function'
  require_relative 'quantity/ratio'
  require_relative 'quantity/term'
  require_relative 'quantity/composition'
  require_relative 'quantity/multiplication_table'

  # Error to indicate incompatible quantities.
  # 
  class Error < TypeError; end

  class << self
    # Standard quantity of the supplied dimension. Example:
    # 
    #   q = Quantity.standard of: Dimension[ "L.T⁻²" ]
    # 
    def standard of:, **named_args
      # This method goes down the difficult path of imitating a
      # constructor. The problem is that an unsuspecting user
      # could be asking to construct an instance with different
      # parameters. Luckily, the only allowed parameters here are
      # those related to naming: :name (alias :ɴ) and :name!.
      # Normally, NameMagic takes care of these automatically, but
      # in this difficult situation, they have to be handled
      # manually.
      dimension = SY::Dimension[ of ]
      # If no named arguments were supplied, we are done.
      return dimension.standard_quantity if named_args.empty?
      # The caller did supply named arguments. If this method
      # was a quantity constructor, we would just pass them forth
      # to .new constructor. However, there will be no constructor
      # call here, since the instance already exists:
      quantity = dimension.standard_quantity
      # Handle the named arguments.
      named_args named_args do
        may_have :name, alias: :ɴ
        fail "Parameters :name (:ɴ) and :name! may not be both " +
             "given!" if has? :name! if has? :name
        note "name the instance using either #name= or #name!"
        name = delete :name
        name_with_bang = delete :name!
        must.be_empty
        # Do the naming.
        quantity.name = name if name
        quantity.name! name_with_bang if name_with_bang
      end
      # Finally, return the quantity.
      return quantity
    end

    # Constructor of a new scaled quantity. Example:
    # 
    #   DozenAmount = Quantity.scaled of: Amount, ratio: 12
    # 
    # FIXME: Now I hit another problem. Scaled quantities are
    # scaled with respect to their parent quantity, or are they
    # scaled with respect to their standard quantity?
    # 
    def scaled parent, ratio: 1, **named_args
      dimension = of.dimension
      Quantity::Scaled.new( parent, ratio: ratio, **named_args )
    end

    # Constructor of a new scaled quantity. Example:
    # 
    #   q = Quantity.of Dimension.new( "L.T⁻²" )
    # 
    def of dimension, ratio: 1, **named_args
      new dimension: dimension, **named_args
    end

    # Constructor of a new dimensionless quantity.
    # 
    def dimensionless **options
      new dimension: SY::Dimension.zero, **options
    end

    # Constructor of nonstandard quantities.
    # 
    def nonstandard( parent, function: )
      # TODO: Think about other nonstandard quantities: linear
      # such as degrees of Fahrenheit, logarithmic (decibels),
      # negative logarithmic (pH) etc.
    end
  end

  selector :dimension, :function

  # The parameters needed to construct a quantity depend on the
  # type of quantity we are constructing. There are two types of
  # elementary quantities (standard and nonstandard)
  # 
  def initialize **nn
    named_args nn do # describe and process named arguments
      » "quantity constructor may have explicitly given dimension"
      may_have :dimension
      if has? :dimension then
        @dimension = SY::Dimension[ delete( :dimension ) ]
        » "if dimension is given, composition must not be given"
        must.not_have :composition
        » "function may be given"
        may_have :function
        » "but parent quantity must not be given"
        must.not_have :parent
        @function = SY::Quantity::Function.new( delete :function )

        # FIXME: :function has to be handled. If it's a Ratio, then
        # this constructor defines a scaled quantity with respect
        # to the standard quantity of its dimension. If it's a
        # general function, then this constructor defines a
        # nonstandard quantity whose parent quantity is the
        # standard quantity of the supplied dimension.
      else
        # Other ways of constructing quantities than just providing
        # dimension and function can be employed

        # If it does, it must not have explicit composition.
        fail "Dimension and composition may not be given " +
          "both at the same time" if has? :composition
        # Now, if function is not given, we can construct the
        # right
        # away a new quantity. We are done.
      end
    end
    
    # @function defaults to identity function.
    @function ||= SY::Quantity::Function.identity

    # Construct Magnitude parametrized subclass for the instance.
    param_class!( { Magnitude: SY::Magnitude },
                  with: { quantity: self } )

    # The composition table should learn about new composed
    # quantities the moment these are named. (Another way would
    # be to construct unnamed quantities and introduce them to
    # the table explicitly, provided the coder knows what she is
    # doing.)
    # 
    # Do they need to know how they were defined? It would seem to
    # me that the answer is no, so long as @function is well
    # handled...
  end

  # Inquirer whether this is a nonstandard quantity.
  # 
  def nonstandard?
    false
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

  # A quantity can be multiplied by another quantity, or by a
  # number. When multiplied by a quantity, the result is a
  # composed quantity. When multiplied by a number, the result is
  # a scaled daughter of the receiver.
  # 
  def * other
    case other
    when SY::Quantity then multiply_by_quantity( other )
    when Numeric then multiply_by_number( other )
    else
      fail TypeError, <<-MSG
        A quantity can only be multiplied by another quantity or
        a number! (Attempt to multiply by a #{other.class} has
        occurred.)
      MSG
    end
  end

  # Creates inverse quantity.
  # 
  def inverse
    # Compose the inversion term.
    term = Term[ self => -1 ]
    # Reduce the term to quantity.
    inversion_result = term.to_quantity
    # Return the result.
    return inversion_result
  end

  # A quantity can be divided by another quantity, or by a
  # number. When divided by a quantity, the result is a
  # composed quantity. When divided by a number, the result is
  # a scaled daughter of the receiver.
  # 
  def / other
    case other
    when SY::Quantity then divide_by_quantity( other )
    when Numeric then divide_by_number( other )
    else
      fail TypeError, <<-MSG
        A quantity can only be divided by another quantity or
        a number! (Attempt to divide by a #{other.class} has
        occurred.)
      MSG
    end
  end

  # Raises the receiver to a number.
  # 
  def ** number
    argument number do
      fail "A quantity can only be raised to an integer " +
           "exponent" unless is_a? Numeric
    end
    # Compose the power term.
    term = Term[ self => number ]
    # Reduce the term to quantity.
    inversion_result = term.to_quantity
    # Return the result.
    return inversion_result
  end

  # FIXME: Write the description.
  # 
  def to_s
    super
    # FIXME: This should be a customized method like in Dimension.
  end

  # FIXME: Write the description.
  # 
  def inspect
    super
    # FIXME: This should be a customized method like in Dimension.
  end

  private

  # Constructs a daughter quantity by multiplying self by a number.
  # Note that the daughter quantity will have to _divide_ its
  # magnitude by the number to convert to parent quantity.
  # 
  def multiply_by_number( number )
    SY::Quantity.scaled( of: self, ratio: 1 / number )
  end

  # Constructs a daughter quantity by dividing self by a number.
  # Note that the daughter quantity will have to _multiply_ its
  # magnitude by the number to convert it to parent quantity.
  # 
  def divide_by_number( number )
    SY::Quantity.scaled( of: self, ratio: number )
  end

  # Multiplies self with another quantity.
  # 
  def multiply_by_quantity( quantity )
    if quantity.nonstandard? then
      msg = "Attempt to multiply #{self} by #{quantity}, " +
            "a nonstandard quantity, has occurred. Nonstandard " +
            "quantities may not be multiplied by other quantities!"
      fail TypeError, msg
    end
    # Compose the multiplication term.
    term = Term[ self => 1, quantity => 1 ]
    # Reduce the term to quantity.
    multiplication_result = term.to_quantity
    # Return the result.
    return multiplication_result
  end

  # Divides self by another quantity using multiplication table.
  # 
  def divide_by_quantity( quantity )
    if quantity.nonstandard? then
      msg = "Attempt to divide #{self} by #{quantity}, " +
            "a nonstandard quantity, has occurred. Nonstandard " +
            "quantities may not be divided by other quantities!"
      fail TypeError, msg
    end
    # Compose the division term.
    term = Term[ self => 1, quantity => 1 ]
    # Reduce the term to quantity.
    division_result = term.to_quantity
    # Return the result.
    return division_result
  end
end # class SY::Quantity
