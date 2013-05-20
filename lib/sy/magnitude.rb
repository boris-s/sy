# -*- coding: utf-8 -*-
# This module stores assets pertaining to a magnitude – be it absolute magnitude
# (physical number of unit objects), or relative magnitude (magnitude differnce).
# 
module SY::Magnitude
  class << self
    # Constructs absolute magnitudes of a given quantity.
    # 
    def absolute *args
      ꜧ = args.extract_options!
      qnt = ꜧ[:quantity] || ꜧ[:of] || args.shift
      return qnt.absolute.magnitude ꜧ[:amount]
    end

    # Constructs relative magnitudes of a given quantity.
    # 
    def difference *args
      ꜧ = args.extract_options!
      qnt = ꜧ[:quantity] || ꜧ[:of] || args.shift
      return qnt.relative.magnitude ꜧ[:amount]
    end

    # Constructs magnitudes of a given quantity.
    # 
    def of qnt, args={}
      return qnt.magnitude args[:amount]
    end

    # Returns zero magnitude of a given quantity.
    # 
    def zero
      return absolute 0
    end
  end

  # Magnitudes are comparable.
  # 
  include Comparable

  # Magnitudes respond to unit methods.
  # 
  include SY::ExpressibleInUnits

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
    quantity.absolute.magnitude amount.abs
  end

  # Reframes into the relative quantity.
  # 
  def relative
    quantity.relative.magnitude amount
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

  # Compatible magnitudes compare by their amounts.
  # 
  def <=> m2
    return amount <=> m2.amount if quantity == m2.quantity
    raise SY::QuantityError, "Mismatch: #{quantity} <=> #{m2.quantity}!"
  end

  # Addition.
  # 
  def + m2
    return magnitude amount + m2.amount if quantity == m2.quantity
    # return self if m2 == SY::ZERO
    raise SY::QuantityError, "Mismatch: #{quantity} + #{other.quantity}!"
  end

  # Subtraction.
  # 
  def - m2
    return magnitude amount - m2.amount if quantity == m2.quantity
    # return self if m2 == SY::ZERO
    raise SY::QuantityError, "Mismatch: #{quantity} - #{m2.quantity}!"
  end

  # Multiplication.
  # 
  def * m2
    case m2
    when Numeric then
      magnitude amount * m2
    # when SY::ZERO then
    #   return magnitude 0
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
  def eql other
    raise NotImplementedError
  end

  # Percent operator (remainder after division)
  # 
  def %
    raise NotImplementedError
  end

  # Type coercion for magnitudes.
  # 
  def coerce m2
    case m2
    when Numeric then return SY::Amount.relative.magnitude( m2 ), self
    else
      raise TErr, "#{self} cannot be coerced into a #{m2.class}!"
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
    # step 1: produce pairs [number, unit_presentation],
    #         where unit_presentation is an array of triples
    #         [prefix, unit, exponent], which together give the
    #         correct dimension for this magnitude, and correct
    #         factor so that number * factor == self.amount
    # step 2: define a goodness function for them
    # step 3: define a satisfaction criterion
    # step 4: maximize this goodness function until the satisfaction
    #         criterion is met
    # step 5: interpolate the string from the chosen choice
    
    # so, let's start doing it
    # how do we produce the first choice?
    # if the standard unit for this quantity is named, we'll start with it
    
    # let's say that the abbreviation of this std. unit is Uu, so the first
    # choices will be:
    # 
    #                        amount.Uu
    #                        (amount * 1000).µUu
    #                        (amount / 1000).kUu
    #                        (amount * 1_000_000).nUu
    #                        (amount / 1_000_000).MUu
    #                        ...
    #                        
    # (let's say we'll use only short prefixes)
    #
    # which one do we use?
    # That depends. For example, CelsiusTemperature is never rendered with
    # SI prefixes, so their cost should be +Infinity
    # 
    # Cost of the number could be eg.:
    #
    #          style:                cost:
    #          3.141                 0
    #          31.41, 314.1          1
    #          0.3141                2
    #          3141.0                3
    #          0.03141               4
    #          31410.0               5n
    #          0.003141              6
    #          ...
    #          
    # Default cost of prefixes could be eg.
    #
    #          unit representation:  cost:
    #          U                     0
    #          dU                    +Infinity
    #          cU                    +Infinity
    #          mU                    1
    #          dkU                   +Infinity
    #          hU                    +Infinity
    #          kU                    1
    #          µU                    2
    #          MU                    2
    #          nU                    3
    #          GU                    3
    #          pU                    4
    #          TU                    4
    #          fU                    5
    #          PU                    5
    #          aU                    6
    #          EU                    6
    #
    # Cost of exponents could be eg. their absolute value, and +1 for minus sign
    #
    # Same unit with two different prefixes may never be used (cost +Infinity)
    #
    # Afterwards, there should be cost of inconsistency. This could be implemented
    # eg. as computing the first 10 possibilities for amount: 1 and giving them
    # bonuses -20, -15, -11, -8, -6, -5, -4, -3, -2, -1. That would further reduce the variability of the
    # unit representations.
    #
    # Commenting again upon default cost of prefixes, prefixes before second:
    #
    #          prefix:               cost:
    #          s                     0
    #          ms                    4
    #          ns                    5
    #          ps                    6
    #          fs                    7
    #          as                    9
    #          ks                    +Infinity
    #          Ms                    +Infinity
    #          ...
    #
    # Prefixes before metre
    #
    #          prefix:               cost:
    #          m                     0
    #          mm                    2
    #          µm                    2
    #          nm                    3
    #          km                    3
    #          Mm                    +Infinity
    #          ...
    #          

    # number, unit_presentation = choice

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

  # def to_s unit=quantity.units.first, number_format='%.3g'
  #   begin
  #     return to_string( unit ) if unit and unit.abbreviation
  #   rescue
  #   end
  #   # otherwise, use units of basic dimensions – here be the magic:
  #   hsh = dimension.to_hash
  #   symbols, exponents = hsh.each_with_object Hash.new do |pair, memo|
  #     dimension_letter, exponent = pair
  #     std_unit = SY::Dimension.basic( dimension_letter ).standard_unit
  #     memo[ std_unit.abbreviation || std_unit.name ] = exponent
  #   end.to_a.transpose
  #   # assemble the superscripted product string:
  #   sps = SY::SPS.( symbols, exponents )
  #   # and finally, interpolate the string
  #   "#{number_format}#{sps == '' ? '' : '.' + sps}" % amount
  #   "#{amount}#{sps == '' ? '' : '.' + sps}"
  # end
  
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
end
