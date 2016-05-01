# coding: utf-8

# Class Quantity is the key class of SY. Quantity is more important
# than dimension, because it defines physical meaning and context.
# Example: quantities SY::Amount and SY::MoleAmount are both
# dimensionless, but the second one counts in moles and is used in
# the context of chemistry. Quantities SY::ThermalCapacity and
# SY::Entropy have both the same physical dimension, but their
# meaning is different. Quantities in different fields of science
# abide by different conventions. SY therefore does not try to
# cover all existing cases out there. Instead, SY::Quantity is
# designed to cover 80% usecases within a concise abstraction.
# 
# Physical quantities typically have dimensions. Time has dimension
# TIME, Speed has dimension LENGTH.TIME⁻¹, ThermalCapacity has
# dimension MASS.LENGTH².TIME⁻².TEMPERATURE⁻¹. Amount and
# MoleAmount are dimensionless – can be considered of zero
# dimension. Quantities can be multiplied by other quantities, and
# the result is a composed quantity. Dimensions of the factor
# quantities are also composed. However, dimensional analysis is
# not sufficient to simplify quantity terms. Quantity term (reified
# as SY::Quantity::Term class) is, expectedly, a product of a
# number of quantities raised to certain exponents. Example:
# SY::Quantity::Term[ "Length.Time⁻¹" ]. Again, dimension does not
# suffice to determine that Molarity is not the same thing as
# Amount.Length⁻³ – both are of dimension LENGTH⁻³. Quantity
# compositions are reified as class SY::Quantity::Composition.
#
# Certain quantities are defined as functions of other quantities
# (parent quantities). These functions are reified as class
# SY::Quantity::Function. Examples: CelsiusTemperature is defined
# as Temperature (measured in kelvins) offset by 273.15.K.
# MoleAmount is Amount scaled by Avogadro constant. In SY,
# this function is reified as SY::Quantity::Function.
# 
# From the above, 4 distinct types of quantities can be identified:
# standard, nonstandard, scaled and composed:
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

  # Exception to indicate incompatible quantities.
  # 
  class Error < TypeError; end

  # Exception to indicate unrelated quantities.
  # 
  class NotRelated < Error; end

  class << self
    # Standard quantity of the supplied dimension. Example:
    # 
    #   q = Quantity.standard of: Dimension[ "L.T⁻²" ]
    # 
    def standard of:, **named_args
      dimension = SY::Dimension[ of ]
      # Standard quantity comes from Dimension#standard_quantity,
      # which takes no arguments.
      quantity = dimension.standard_quantity
      # If we also received no named_args, all is fine:
      return dimension.standard_quantity if named_args.empty?
      # However, if we did receive named_args, it means the caller
      # tries to name the quantity instance (named_args not related
      # to naming are not permitted). Naming may succeed or fail.
      # To .new constructor, NameMagic provides full automation of
      # the naming-related parameters, but since .standard goes
      # through Dimension#standard_quantity, we have to call
      # either NameMagic#name= or NameMagic#name! manually.
      name, name_with_bang = named_args named_args do
        may_have :name, alias: :ɴ
        fail "Parameters :name (:ɴ) and :name! must not be both " +
             "given!" if has? :name! if has? :name
        » "we received :name xor :name! argument"
        [ delete( :name ), delete( :name! ) ].tap {
          » "no parameters except :name / :ɴ / :name! are allowed"
          » "(and :name! is available only for compatibility)"
          must.be_empty
        }
      end
      # Method #name= or #name! is used accordingly.
      quantity.name = name if name
      quantity.name! name_with_bang if name_with_bang
      return quantity
    end

    # Constructor of a new scaled quantity. Example:
    # 
    #   DozenAmount = Quantity.scaled of: Amount, ratio: 12
    # 
    # Answer: When deriving quantities from other quantities, the
    # function is always defined with respect to their parent
    # quantity. More precisely, the function maps from magnitudes
    # of the daugther quantity to the parent quantity.
    # to their parent quantity. This doesn't need to be standard
    # quantity. When there is a need for conversion between two
    # quantities, then this is possible if a path can be found
    # between the two. If the two are of the same dimension
    # 
    def scaled from:, factor: 1, **named_args
      "factor".( factor ).must.be_kind_of Numeric
      new parent: from,
          function: Ratio.new( 1.0 / factor ),
          **named_args
    end

    # Constructor of a new quantity from a dimension. Example:
    # 
    #   q = Quantity.of Dimension.new( "L.T⁻²" )
    # 
    def of dimension:, factor: 1, **named_args
      new dimension: SY::Dimension[ dimension ],
          # function: SY::Quantity::Ratio.new( factor ),
          **named_args
    end

    # Constructor of a new dimensionless quantity.
    # 
    def dimensionless **named_args
      new dimension: SY::Dimension.zero, **named_args
    end

    # Constructor of nonstandard quantities.
    # 
    def nonstandard( parent, function: )
      # TODO: Think about other nonstandard quantities: linear
      # such as degrees of Fahrenheit, logarithmic (decibels),
      # negative logarithmic (pH) etc.

      # TODO: I wonder how to formalize "protection" of quantities
      # that I used in my definition earlier to protect quantities
      # from decomposing into a term of the standard quantities of
      # the base dimensions. Is it that there should be more than
      # one standard quantity allowed for each dimension? All equal
      # to each other? Or should the "protected" quantity be
      # introduced as a nonstandard quantity?
    end
  end

  selector :dimension, :function

  # The parameters needed to construct a quantity depend on the
  # type of quantity we are constructing. The parameters are:
  #
  # * dimension: If given, must be of SY::Dimension class.
  # * function: If given, must be of SY::Quantity::Function class.
  #
  # Note that the above requirements make .new constructor quite
  # demanding and clumsy for everyday use. Its main purpose is to
  # be a servant of more convenient constructors .of, .standard,
  # .scaled, .composed and .nonstandard.
  # 
  def initialize **nn
    # Let's note that I will make #new constructor demanding. The
    # constructor requires correct types and is non-fool-proof.

    named_args nn do # describe and process named arguments
      » "quantity constructor may have explicitly given dimension"
      if @dimension = delete( :dimension ) then
        » "if dimension is given, composition must not be given"
        must.not_have :composition
        » "function may be given, but parent quantity must not"
        may_have :function
        must.not_have :parent
        @function = delete :function
        # If function is not given, initialization is done.

        # Just perhaps, to set missing @function to identity, but
        # let's not do it until the need is obvious.
    
        # # @function defaults to identity function.
        # @function ||= SY::Quantity::Function.identity

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

        # Composition table should learn about new composed
        # quantities the moment these are named. (Another way would
        # be to construct unnamed quantities and introduce them to
        # the table explicitly.)
      end
    end

    # Construct a parametrized subclass of Magnitude.
    param_class!( { Magnitude: SY::Magnitude },
                  with: { quantity: self } )
  end

  # Inquirer method whether this is a derived quantity.
  # 
  def derived?
    false
  end

  # Inquirer method whether this is a scaled quantity.
  # 
  def scaled?
    false
  end

  # Inquirer method whether this is a nonstandard quantity.
  # 
  def nonstandard?
    false
  end

  # Inquirer method whether this is a composed quantity.
  # 
  def composed?
    false
  end

  # Inquirer method whether this is a basic quantity. Note that
  # basic quantity is one that is neither composed nor derived.
  # 
  def basic?
    not composed? || derived?
  end

  # Inquirer method whether this is a standard quantity of its
  # dimension.
  # 
  def standard?
    self == dimension.standard_quantity
  end

  # Inquirer method whether this is a dimensionless quantity. Note
  # that counterintuitively, class SY::Quantity is more crucial
  # than SY::Dimension. Although it is true that most widely used
  # quantities do have their physical dimension, SY makes it
  # possible to construct new quantities without giving a
  # dimension, in which case null dimension is implied if asked
  # for. It is also possible to supply null dimension to the
  # relevant SY::Quantity constructors explicitly. In both cases,
  # the resulting quantity is dimensionless, unless its descent or
  # composition (if any) implies otherwise.
  # 
  def dimensionless?
    fail NotImplementedError
  end

  # FIXME: I wonder why this convenience shortcut was needed.
  # Maybe I'll figure after I read old sy.rb again...
  # 
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

  # FIXME: Dtto.
  # 
  # # #basic_unit convenience reader of the BASIC_UNITS table
  # def basic_unit; BASIC_UNITS[self] end

  # FIXME: Dtto.
  # 
  # # #fav_units convenience reader of the FAV_UNITS table
  # def fav_units; FAV_UNITS[self] end

  # # FIXME: For now, I don't think second multiplication_table
  # # (apart from the one owned by SY::Quantity::Term) is not
  # # necessary at the moment.
  # delegate :multiplication_table, to: "self.class"

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

  # A quantity can be divided by another quantity, or by a number.
  # When divided by a quantity, the result is a composed quantity.
  # When divided by a number, the result is a scaled daughter
  # quantity of the receiver.
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

  # Returns a magnitude of the quantity.
  # 
  def magnitude number
    self.Magnitude[ self, number ]
  end

  # Returns a conversion function to another quantity.
  # 
  def conversion_function_to( other )
    "argument".( other ).must.be_a SY::Quantity
    return SY::Quantity::Ratio.new 1.0 if self == other
    # Find the relevant function sequence and reduce it using :*
    begin
      function_sequence_to( other ).reduce :*
    rescue SY::Quantity::NotRelated
      fail SY::Quantity::NotRelated, <<-MSG.heredoc
        Quantities #{self} and #{other} are not related, therefore
        conversion function between them cannot be found!
      MSG
    end
  end
  # FIXME: #>> alias not tested!
  alias >> conversion_function_to

  # Returns a conversion function from another quantity.
  # 
  def conversion_function_from( other )
    "argument".( other ).must.be_a SY::Quantity
    return SY::Quantity::Ratio.new 1.0 if self == other
    # Find the relevant function sequence and reduce it using :*
    begin
      function_sequence_from( other ).reduce :*
    rescue SY::Quantity::NotRelated
      fail SY::Quantity::NotRelated, <<-MSG.heredoc
        Quantities #{self} and #{other} are not related, therefore
        conversion function between them cannot be found!
      MSG
    end
  end
  # FIXME: #<< alias not tested!
  alias << conversion_function_from

  # FIXME: Write the description.
  # 
  def to_s
    super
    # FIXME: This should be a customized method like in Dimension.
    # FIXME: Earlier code was:
    # 
    # "#{name.nil? ? "quantity" : name} (#{dimension})"
  end

  # FIXME: Write the description.
  # 
  def inspect
    super
    # FIXME: This should be a custom method (see eg. Dimension).
    # FIXME: Earlier code was:
    # 
    # [ name.nil? ? 'unnamed quantity' : 'quantity "%s"' % name,
    #   dimension ].join ' '
  end

  protected

  # Returns a sequence of SY::Quantity::Function-type objects
  # corresponding to a path of directly related quantities from
  # self to another quantity given as an argument. Each function in
  # the sequence performs one step of conversion chain from self
  # towards the other quantity. The argument must be a quantity. If
  # the receiver and the argument are not related, exception
  # SY::Quantity::NotRelated is raised.
  # 
  def function_sequence_to( other )
    path_to( other ).map { |q1, arrow, q2|
      # Let's remember that for a derived quantity, function (if
      # any) converts to its parent quantity.
      case arrow
      when :< then q1.function
      when :> then q2.function.inverse
      end
    }
  end

  # Returns a sequence of SY::Quantity::Function-type objects
  # corresponding to a path of directly related quantities from a
  # quantity given as argument to self. Each function in the
  # sequence performs one step of conversion in the direction from
  # other quantity to self. The argument must be a quantity. If the
  # receiver and the argument are not related, exception
  # SY::Quantity::NotRelated is raised.
  # 
  def function_sequence_from( other )
    path_from( other ).map { |q1, arrow, q2|
      # Let's remember that for a derived quantity, function (if
      # any) converts to its parent quantity.
      case arrow
      when :< then q1.function
      when :> then q2.function.inverse
      end
    }
  end

  # Returns a path from self to a related quantity given as an
  # argument. The path is an array of triples [ q1, sign, q2 ],
  # where within each triple, q1 and q2 are directly related
  # quantities (forming an edge of the path) and sign is one of
  # symbols :< or :>, denoting whether q1 is a daughter of q2, or
  # vice versa. The contract of the method requires that the
  # supplied argument must be a quantity. If a path cannot be
  # found, SY::Quantity::NotRelated is raised.
  # 
  def path_to( other )
    return [] if other == self
    begin
      fail NotRelated unless derived?
      parent.path_to( other ).unshift [ self, :<, parent ]
    rescue NotRelated
      fail NotRelated, "Quantities #{self} and #{other} are " +
                       "not related!" unless other.derived?
      path_to( other.parent ) << [ other.parent, :>, other ]
    end
  end

  # Returns a path to self from a related quantity given as an
  # argument. The path is an array of triples [ q1, sign, q2 ],
  # where within each triple, q1 and q2 are directly related
  # quantities (forming an edge of the path) and sign is one of
  # symbols :< or :>, denoting whether q1 is a daughter of q2, or
  # vice versa. The contract of the method requires that the
  # supplied argument must be a SY::Quantity. If a path cannot be
  # found, SY::Quantity::NotRelated is raised.
  # 
  def path_from( other )
    other.path_to( self )
  end

  private

  # Constructs a daughter quantity by multiplying self by a number.
  # Note that the daughter quantity will have to _divide_ its
  # magnitude by the number to convert to parent quantity.
  # 
  def multiply_by_number( number )
    SY::Quantity.scaled( from: self, factor: 1.0 / number )
  end

  # Constructs a daughter quantity by dividing self by a number.
  # Note that the daughter quantity will have to _multiply_ its
  # magnitude by the number to convert it to parent quantity.
  # 
  def divide_by_number( number )
    SY::Quantity.scaled( from: self, factor: number.to_f )
  end

  # Multiplies self with another quantity. Requires that the
  # argument be a quantity other than a nonstandard quantity.
  # 
  def multiply_by_quantity( quantity )
    if quantity.nonstandard? then fail TypeError, <<-COMPLAINT
        Attempt to multiply #{self} by #{quantity}, a nonstandard
        quantity, has occurred. Nonstandard quantities may not be
        multiplied by other quantities!
      COMPLAINT
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
