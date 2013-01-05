#encoding: utf-8

# This class represents a magnitude of a metrological quantity. A magnitude
# is basically a pair [quantity, amount].
# 
class SY::Magnitude
  # TODO: privatize #new method

  # Magnitudes are comparable.
  include Comparable
  # Magnitudes respond to unit methods.
  include SY::ExpressibleInUnits
  
  attr_reader :quantity, :amount

  class << self
    # Constructor of magnitudes of a given quantity.
    # 
    def of *args
      ꜧ = args.extract_options!
      qnt = case args.size
            when 0 then
              ꜧ.must_have( :quantity, syn!: :of )
              ꜧ.delete :quantity
            when 1 then args.shift
            else
              raise AErr, "Too many ordered arguments!"
            end
      return qnt.new_magnitude *( ꜧ.empty? ? args : args << ꜧ )
    end
  end # class << self
  
  delegate :dimension,
           :dimensionless?,
           :standard_unit,
           to: :quantity

  # A magnitude is basically a pair [quantity, number]. However, typically,
  # a quantity owns its own parametrized subclass of Magnitude.
  # 
  def initialize *args
    ꜧ = args.extract_options!
    @quantity = ꜧ.must_have :quantity, syn!: :of
    n = ꜧ[:amount] || 1
    @amount = case n
              when SY::Magnitude then
                raise TErr, dim_complaint( n ) unless same_dimension? n
                n.numeric_value_in_standard_unit
              else n end
    raise SY::NegativeAmountError, "Attempt to create a magnitude with " +
      "amount (#@amount)!" if @amount < 0
  end

  # Absolute value of a Magnitude: A new magnitude instance with amount equal
  # to the absolute value of this magnitude's amount.
  # 
  def abs
    SY::Magnitude.of( quantity, amount: amount.abs )
  end

  # Rounded value of a Magnitude: A new magnitude with rounded amount.
  # 
  def round *args
    quantity.amount amount.round( *args )
  end

  # Whether the magnitude is zero.
  # 
  delegate :zero?, to: :amount

  # Magnitudes compare by their numbers. Compared magnitudes must be of
  # the same quantity.
  # 
  def <=> other
    case other
    when SY::Magnitude then
      raise TErr, dim_complaint( other ) unless same_dimension? other
      if same_quantity? other then
        amount <=> other.amount
      else
        q1, q2 = other.quantity.coerce( self.quantity )
        begin
          return self.( q1 ) <=> other.( q2 )
        rescue SY::IncompatibleQuantityError
          raise SY::IncompatibleQuantityError,
                "Impossible to compare #{quantity} with #{other.quantity}!"
        end
      end
    else
      raise TErr, "A Magnitude cannot be compared with a #{other.class}!"
    end
  end

  # Addition.
  # 
  def + other
    case other
    when SY::Magnitude then
      raise TErr, dim_complaint( other ) unless same_dimension? other
      if same_quantity? other then
        begin
          quantity.amount( amount + other.amount )
        rescue NegativeAmountError
          raise NegativeAmountError,
                "Amount #{amount} + #{other.amount} would be negative."
        end
      else
        q1, q2 = other.quantity.coerce( self.quantity )
        begin
          return self.( q1 ) + other.( q2 )
        rescue SY::IncompatibleQuantityError
          raise SY::IncompatibleQuantityError,
            "Impossible to add #{other.quantity} to #{quantity}!"
        end
      end
    else
      raise TErr, "Magnitudes cannot be added to #{other.class}!"
    end
  end

  # Subtraction.
  # 
  def - other
    case other
    when SY::Magnitude then
      raise TErr, dim_complaint( other ) unless same_dimension? other
      if same_quantity? other then
        begin
          quantity.amount( amount - other.amount )
        rescue NegativeAmountError
          raise NegativeAmountError,
            "Amount #{amount} - #{other.amount} would be negative!"
        end
      else
        q1, q2 = other.quantity.coerce( self.quantity )
        begin
          return self.( q1 ) + other.( q2 )
        rescue SY::IncompatibleQuantityError
          raise SY::IncompatibleQuantityError,
                "Impossible to subtract #{other.quantity} from #{quantity}!"
        end
      end
    else
      raise TErr, "Unable to subtract #{other.class} from a magnitude!"
    end
  end

  # Multiplication.
  # 
  def * other
    case other
    when Numeric then
      quantity.amount( amount * other )
    when SY::Magnitude then
      ( quantity * other.quantity ).amount( amount * other.amount )
    else
      raise TErr, "Unable to multiply a magnitude by #{other.class}!"
    end
  end

  # Division.
  # 
  def / other
    case other
    when Numeric then
      quantity.amount( amount / other )
    when SY::Magnitude
      ( quantity / other.quantity ).amount( amount / other.amount )
    else
      raise TErr, "Unable to divide a magnitude by #{other.class}!"
    end
  end

  # Exponentiation.
  # 
  def ** exponent
    case exponent
    when Numeric then
      ( quantity ** exponent ).amount( amount ** exponent )
    when SY::Magnitude then
      # Raising is allowed only to a dimensionless magnitude
      if exponent.dimensionless? then
        self ** exponent.to_f
      else
        raise TErr, "Only dimensionless magnitudes (and numbers) are " +
          "eligible as exponents in exponentiation (attempted " +
          "exponentiation to a magnitude of dimension #{dimension})!"
      end
    end
  end

  # Type coercion for magnitudes.
  # 
  def coerce other
    case other
    when Numeric then
      return SY::Dimension.zero.standard_quantity.amount( other ), self
    else
      raise TErr, "#{other.class} cannot be coerced into a magnitude!"
    end
  end

  # Expresses the magnitude numerically in multiples of another magnitude
  # (which must be of compatible quantity).
  # 
  def numeric_value_in other
    if Symbol === other || String === other then
      # Digest the string into the intended unit:
      other = other.to_s.split( '.' ).reduce 1 do |pipe, ß| pipe.send ß end
    end
    raise TErr, dim_complaint( other ) unless same_dimension? other
    if same_quantity?( other ) then
      amount / other.amount
    else # use Quantity#coerce for incompatible quantities
      q1, q2 = other.quantity.coerce( quantity )
      self.( q1 ).numeric_value_in other.( q2 )
    end
  end
  alias :in :numeric_value_in

  # Gives the magnitude as a numeric value in its standard unit.
  # 
  def numeric_value_in_standard_unit
    numeric_value_in( standard_unit )
  end
  alias :to_f :numeric_value_in_standard_unit

  # Changes the quantity of the magnitude, provided that the dimensions
  # match.
  # 
  def reframe other_quantity
    # make sure that the dimensions match
    raise TErr, dim_complaint( other_quantity ) unless
      same_dimension? other_quantity
    # perform the quantity "replacement"
    other_quantity.amount self
  end
  alias :call :reframe

  # Returns a SignedMagnitude instance with same amount and positive sign.
  # 
  def +@
    quantity.new_signed_magnitude amount: amount
  end

  # Returns a SignedMagnitude instance with same absolute value of the
  # amount, but opposite sign.
  # 
  def -@
    quantity.new_signed_magnitude amount: -amount
  end

  # True if the amount is smaller than zero, false otherwise. Always false for
  # unsigned magnitudes, true for signed magnitudes with negative amount.
  # 
  def negative?
    amount < 0
  end

  # Opposite of #negative?
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
  def to_s
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

    number = self.in quantity.standard_unit
    prefix = ''
    unit = quantity.standard_unit
    exponent = 1
    unit_presentation = prefix, unit, exponent

    number_ς = default_amount_format % number
    unit_presentation_ς = SY::SPS.( [ "#{prefix}#{unit.short}" ], [ exponent ] )
    
    return [ number_ς, unit_presentation_ς ].join '.'
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


  # Treats a magnitude as a unit, in which the argument should be expressed.
  # The method is provided mainly for compatibility with Unit#to_magnitude.
  # 
  def to_magnitude factor=1
    if factor == 1 then self else self * factor end
  end

  private

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
        raise TErr, "#{other} does not have quantity!"
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
    "%#.#{amount_formatting_precision}g"
  end

  def amount_formatting_precision
    @amount_formatting_precision ||= default_amount_formatting_precision
  end

  def default_amount_formatting_precision
    3
  end
end # class SY::Magnitude
