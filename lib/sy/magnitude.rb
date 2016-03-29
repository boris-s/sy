# coding: utf-8

# This module defines common assets of a magnitude – be it absolute (number of
# unit objects), or relative (magnitude difference).
# 
module SY::Magnitude
  class << self
    # Constructs an absolute magnitude of a given quantity.
    # 
    def absolute( of: nil, amount: nil )
      of.absolute.magnitude( amount )
    end

    # Constructs a relative magnitude of a given quantity.
    # 
    def difference( of: nil, amount: nil )
      of.relative.magnitude( amount )
    end

    # Constructs a magnitude of a given quantity.
    # 
    def of( quantity, amount: nil )
      quantity.magnitude( amount )
    end

    # Zero magnitude of a given quantity.
    # 
    def zero( of: nil )
      absolute of: of, amount: 0
    end

    # Magnitude 1 of a given quantity.
    # 
    def one( of: nil )
      absolute of: of, amount: 1
    end
  end

  # Magnitudes respond to unit methods.
  # 
  include SY::ExpressibleInUnits

  # Magnitudes are comparable.
  # 
  include Comparable

  # Three-way comparison operator of magnitudes.
  # 
  def <=> m2
    return amount <=> m2.amount if quantity == m2.quantity
    return self <=> m2.( quantity ) if quantity.coerces? m2.quantity
    apply_through_coerce :<=>, m2
  end

  attr_reader :quantity, :amount
  alias in_standard_unit amount

  # Delegations to amount:
  # 
  delegate :zero?, to: :amount
  delegate :to_f, to: :amount

  # Delegations to quantity:
  # 
  delegate :dimension,
           :dimensionless?,
           :standard_unit,
           :relative?,
           :absolute?,
           :magnitude,
           :relationship,
           to: :quantity

  # Computes absolute value and reframes into the absolute quantity.
  # 
  def absolute
    quantity.absolute.magnitude( amount.abs )
  end

  # Reframes into the relative quantity.
  # 
  def relative
    quantity.relative.magnitude( amount )
  end

  # Reframes the magnitude into its relative quantity.
  # 
  def +@
    quantity.relative.magnitude( amount )
  end

  # Reframes the magnitude into its relative quantity, with negative amount.
  # 
  def -@
    quantity.relative.magnitude( -amount )
  end

  # Absolute value of a magnitude (no reframe).
  # 
  def abs
    magnitude amount.abs
  end

  # Rounded value of a Magnitude: A new magnitude with rounded amount.
  # 
  def round *args
    magnitude amount.round( *args )
  end

  # Addition.
  # 
  def + m2
    return magnitude amount + m2.amount if quantity == m2.quantity
    return self + m2.( quantity ) if quantity.coerces? m2.quantity
    apply_through_coerce :+, m2
  end

  # Subtraction.
  # 
  def - m2
    return magnitude amount - m2.amount if quantity == m2.quantity
    return self - m2.( quantity ) if quantity.coerces? m2.quantity
    apply_through_coerce :-, m2
  end

  # Multiplication.
  # 
  def * m2
    case m2
    when Numeric then
      magnitude amount * m2
    # when SY::ZERO then
    #   return magnitude 0
    when Matrix then
      m2.map { |e| self * e }
    else
      ( quantity * m2.quantity ).magnitude( amount * m2.amount )
    end
  end

  # Division.
  # 
  def / m2
    case m2
    when Numeric then
      magnitude amount / m2
    # when SY::ZERO then
    #   raise ZeroDivisionError, "Attempt to divide #{self} by #{SY::ZERO}."
    when Matrix then
      amount / m2 * quantity.magnitude( 1 )
    else
      ( quantity / m2.quantity ).magnitude( amount / m2.amount )
    end
  end

  # Exponentiation.
  # 
  def ** exp
    case exp
    when SY::Magnitude then
      raise SY::DimensionError, "Exponent must have zero dimension! " +
        "(exp given)" unless exp.dimension.zero?
      ( quantity ** exp.amount ).magnitude( amount ** exp.amount )
    else
      ( quantity ** exp ).magnitude( amount ** exp )
    end
  end

  # Same magnitudes <em>and</em> same (#eql) quantities.
  # 
  def eql? other
    quantity == other.quantity && amount == other.amount
  end

  # Percent operator (remainder after division)
  # 
  def % m2
    return magnitude amount % m2.amount if quantity == m2.quantity
    return self % m2.( quantity ) if quantity.coerces? m2.quantity
    apply_through_coerce :%, m2
  end

  # Type coercion for magnitudes.
  # 
  def coerce m2
    if m2.is_a? Numeric then
      return SY::Amount.relative.magnitude( m2 ), self
    elsif m2.is_a? Matrix then
      return m2 * SY::UNIT, self
    elsif quantity.coerces? m2.quantity then
      return m2.( quantity ), self
    else
      raise TypeError, "#{self} cannot be coerced into a #{m2.class}!"
    end
  end

  # Gives the magnitude as a plain number in multiples of another magnitude,
  # supplied as argument. The quantities must match.
  # 
  def in m2
    case m2
    when Symbol, String then
      begin
        self.in eval( "1.#{m2}" ).aT_kind_of SY::Magnitude # digest it
      rescue TypeError
        raise TypeError, "Evaluating 1.#{m2} does not result in a magnitude; " +
          "method collision with another library?"
      end
    when SY::Magnitude then
      quantity.measure( of: m2.quantity ).w.( amount ) / m2.amount
    else
      raise TypeError, "Unexpected type for Magnitude#in method! (#{m2.class})"
    end
  end

  # Reframes a magnitude into a different quantity. Dimension must match.
  # 
  def reframe q2
    case q2
    when SY::Quantity then q2.read self
    when SY::Unit then q2.quantity.read self
    else raise TypeError, "Unable to reframe into a #{q2.class}!" end
  end

  # Reframes a magnitude into a <em>relative</em> version of a given quantity.
  # (If absolute quantity is supplied as an argument, its relative colleague
  # is used to reframe.)
  # 
  def call q2
    case q2
    when SY::Quantity then q2.relative.read self
    when SY::Unit then q2.quantity.relative.read self
    else raise TypeError, "Unable to reframe into a #{q2.class}!" end
  end

  # True if amount is negative. Implicitly false for absolute quantities.
  # 
  def negative?
    amount < 0
  end

  # Opposite of #negative?. Implicitly true for absolute quantities.
  # 
  def nonnegative?
    amount >= 0
  end

  # Gives the magnitude written "naturally", in its most favored units.
  # It is also possible to supply a unit in which to show the magnitude
  # as the 1st argument (by default, the most favored unit of its
  # quantity), or even, as the 2nd argument, the number format (by default,
  # 3 decimal places).


  # further remarks: depending on the area of science the quantity
  # is in, it should have different preferences for unit presentation.
  # Different areas prefer different units for different dimensions.
  
  # For example, if the quantity is "Molarity²", its standard unit will
  # be anonymous and it magnitudes of this quantity should have preference
  # for presenting themselves in μM², or in mΜ², or such
  
  # when attempting to present number Molarity².amount 1.73e-7.mM
  

  # 
  def to_s( unit=quantity.units.first || quantity.standard_unit,
            number_format=default_amount_format )
    begin
      un = unit.short || unit.name
      if un then
        number = self.in unit
        number_ς = number_format % number
        prefix = ''
        exp = 1
        # unit_presentation = prefix, unit, exp
        unit_ς = SY::SPS.( [ "#{prefix}#{unit.short}" ], [ exp ] )
        [ number_ς, unit_ς ].join '.'
      else
        number = amount
        # otherwise, use units of component quantities
        ꜧ = quantity.composition.to_hash
        symbols, exponents = ꜧ.each_with_object Hash.new do |pair, memo|
          qnt, exp = pair
          if qnt.standard_unit.name
            std_unit = qnt.standard_unit
            memo[ std_unit.short || std_unit.name ] = exp
          else
            m = qnt.magnitude( 1 ).to_s
            memo[ m[2..-1] ] = exp
            number = m[0].to_i * number
          end
        end.to_a.transpose
        # assemble SPS
        unit_ς = SY::SPS.( symbols, exponents )
        # interpolate
        number_ς = number_format % number
        return number_ς if unit_ς == '' || unit_ς == 'unit'
        [ number_ς, unit_ς ].join '.'
      end
    rescue
      fail
      number_ς = number_format % amount
      [ number_ς, "unit[#{quantity}]" ].join '.'
    end
  end

  # Inspect string of the magnitude
  # 
  def inspect
    "#<#{çς}: #{self} >"
  end

  # Without arguments, it returns a new magnitude equal to self. If argument
  # is given, it is treated as factor, by which the amount is to be muliplied.
  # 
  def to_magnitude
    magnitude( amount )
  end

  private

  # Gives the amount of standard quantity corresponding to this magnitude,
  # if such conversion is possible.
  # 
  def to_amount_of_standard_quantity
    return amount if quantity.standard?
    amount * quantity.relationship.to_amount_of_standard_quantity
  end

  def same_dimension? other
    case other
    when SY::Magnitude then dimension == other.dimension
    when Numeric then dimension.zero?
    when SY::Quantity then dimension == other.dimension
    when SY::Dimension then dimension == other
    else
      raise TErr, "The object (#{other.class} class) does not " +
        "have dimension comparable to SY::Dimension defined"
    end
  end

  def same_quantity? other
    case other
    when SY::Quantity then quantity == other
    else
      begin
        quantity == other.quantity
      rescue NoMethodError
        raise TypeError, "#{other} does not have quantity!"
      end
    end
  end

  # The engine for constructing #to_s strings.
  # 
  def construct_to_s( named_unit=default_named_unit,
                      number_format=default_amount_format )
    name = named_unit.name.tE "must exist", "the unit name"
    abbrev_or_name = named_unit.short || name
    "#{number_format}.#{ str == '' ? unit : str }" %
      numeric_value_in( unit )
  end

  def to_s_with_unit_using_abbreviation named_unit=default_named_unit
    "%s.#{named_unit.abbreviation}"
  end

  def to_s_with_unit_using_name
    # FIXME
  end

  # Error complaint about incompatible dimensions.
  # 
  def dim_complaint obj1=self, obj2
    "#{obj1} not of the same dimension as #{obj2}!"
  end

  # String describing this class.
  # 
  def çς
    "Magnitude"
  end

  # Default named unit to be used in expressing this magnitude.
  # 
  def default_named_unit
    standard_unit
  end

  # Default format string for expressing the amount of this magnitude.
  # 
  def default_amount_format
    "%.#{amount_formatting_precision}g"
  end

  def amount_formatting_precision
    @amount_formatting_precision ||= default_amount_formatting_precision
  end

  def default_amount_formatting_precision
    3
  end

  # Applies an operator on self with otherwise incompatible second operand.
  # 
  def apply_through_coerce operator, operand2
    begin
      compat_obj_1, compat_obj_2 = operand2.coerce( self )
    rescue SY::DimensionError
      msg = "Mismatch: #{dimension} #{operator} #{operand2.dimension}!"
      fail SY::DimensionError, msg
    rescue SY::QuantityError
      msg = "Mismatch: #{quantity} #{operator} #{operand2.quantity}!"
      fail SY::QuantityError, msg
    rescue NoMethodError
      fail TypeError, "#{operand2.class} can't be coerced into #{quantity}!"
    else
      compat_obj_1.send( operator, compat_obj_2 )
    end
  end
end
