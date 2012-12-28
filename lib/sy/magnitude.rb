#encoding: utf-8

module SY
  # This class represents a magnitude of a metrological quantity. A magnitude
  # is basically a pair [quantity, amount].
  # 
  class Magnitude
    # TODO: privatize #new method

    include UnitMethodsMixin # ensuring that magnitudes respond to unit methods
    include Comparable

    attr_reader :quantity, :amount

    class << self
      # Constructor of magnitudes of a given quantity.
      # 
      def of *args
        args = constructor_args *args
        quantity = args[-1].delete :quantity
        return quantity.new_magnitude *args
      end

      private

      # Private method to process and validate construcotr arguments.
      # 
      def constructor_args *args
        ꜧ = args.extract_options!
        qnt = case args.size
              when 0 then
                ꜧ.must_have :quantity, syn!: :of
                ꜧ[:quantity]
              when 1 then args.shift
              else
                raise AE, "Too many ordered arguments."
              end
        amount = ꜧ[ :amount ] || 1
        return *args, ꜧ.merge( quantity: qnt, amount: amount )
      end
    end

    delegate :dimension,
             :dimensionless?,
             to: :quantity

    # A magnitude is basically a pair [quantity, number]. However, typically,
    # a quantity will own its own anonymous subclass of Magnitude, which is
    # actually used to create magnitudes.
    # 
    def initialize *args
      ꜧ = args.extract_options!
      @quantity = ꜧ.must_have :quantity, syn!: :of
      n = ꜧ[:amount] || 1
      @amount = case n
                when Magnitude then
                  raise TE, dim_complaint( n ) unless same_dimension? n
                  n.numeric_value_in_standard_unit
                else n end
      raise NegativeAmountError, "Attempt to create a magnitude with " +
        "negative amount (#@amount). Signed magnitude can be created eg. " +
        "by using unary +/- operator on a magnitude object." if @amount < 0
    end

    # Absolute value of a Magnitude: A new magnitude instance with amount equal
    # to the absolute value of this magnitude's amount.
    # 
    def abs
      ::SY::Magnitude.of quantity, amount: amount.abs
    end

    # Rounded value of a Magnitude: A new magnitude with rounded amount.
    # 
    def round *args
      ç.of quantity, amount: amount.round( *args )
    end

    # Whether the magnitude is zero.
    # 
    delegate :zero?, to: :amount

    # Magnitudes compare by their numbers. Compared magnitudes must be of
    # the same quantity.
    # 
    def <=> other
      case other
      when Magnitude then
        raise TypeError, DIM_ERR_MSG unless same_dimension? other
        if same_quantity? other then
          amount <=> other.amount
        else
          compat_q_1, compat_q_2 = other.quantity.coerce( self.quantity )
          begin
            return self.( compat_q_1 ) <=> other.( compat_q_2 )
          rescue IncompatibleQuantityError
            raise IncompatibleQuantityError,
              "Impossible to compare #{quantity} with #{other.quantity}."
          end
        end
      else
        return self if other.respond_to? :zero? and other.zero? rescue
        raise IncompatibleQuantityError,
          "A Magnitude cannot be compared with a #{other.class}"
      end
    end

    # Addition.
    # 
    def + other
      case other
      when Magnitude then
        raise TypeError, DIM_ERR_MSG unless same_dimension? other
        if same_quantity? other then
          # same quantity magnitudes add freely
          begin
            ç.of quantity, amount: amount + other.amount
          rescue NegativeAmountError
            raise NegativeAmountError,
              "Attempt to subtract greater magnitude from a smaller one."
          end
        else
          # use Quantity#coerce for incompatible quantities
          compat_q_1, compat_q_2 = other.quantity.coerce( self.quantity )
          begin
            self.( compat_q_1 ) + other.( compat_q_2 )
          rescue NegativeAmountError
            raise NegativeAmountError,
              "Attempt to subtract greater magnitude from a smaller one."
          rescue IncompatibleQuantityError
            raise IncompatibleQuantityError,
              "Impossible to add #{quantity} with #{other.quantity}."
          end
        end
      else
        raise IncompatibleQuantityError, "Magnitudes may only be added to " +
          "compatible other magnitudes (adding to a #{other.ç} attempted)."
      end
    end

    # Subtraction.
    # 
    def - other
      case other
      when Magnitude then
        raise TypeError, DIM_ERR_MSG unless same_dimension? other
        if same_quantity?( other ) then
          # same quantity magnitudes subtract freely
          begin
            ç.of quantity, amount: amount - other.amount
          rescue NegativeAmountError
            raise NegativeAmountError,
              "Attempt to subtract greater magnitude from a smaller one."
          end
        else
          # use Quantity#coerce for incompatible quantities
          compat_q_1, compat_q_2 = other.quantity.coerce( self.quantity )
          begin
            self.( compat_q_1 ) - other.( compat_q_2 )
          rescue NegativeAmountError
            raise NegativeAmountError,
              "Attempt to subtract greater magnitude from a smaller one."
          rescue IncompatibleQuantityError
            raise IncompatibleQuantityError,
              "Impossible to subtract #{other.quantity} from #{quantity}."
          end
        end
      else
        raise TypeError, "Magnitudes can only be subtracted from " +
          "compatible other magnitudes."
      end
    end

    # Multiplication.
    # 
    def * other
      case other
      when Magnitude then
        ç.of ( quantity * other.quantity ).dimension.standard_quantity,
             amount: amount * other.amount
      when Numeric then
        ç.of quantity, amount: amount * other
      else
        raise TypeError, "Magnitudes only multiply with other magnitudes " +
          "and numbers. (Multiplication with a #{other.ç} attempted.)"
      end
    end

    # Division.
    # 
    def / other
      case other
      when Magnitude
        ç.of ( quantity / other.quantity ).dimension.standard_quantity,
             amount: amount / other.amount
      when Numeric then
        ç.of quantity, amount: amount / other
      else
        raise TypeError, "Magnitudes only divide with magnitudes and " +
          "numbers. (Division by a #{other.ç} attempted.)"
      end
    end

    # Exponentiation.
    # 
    def ** exponent
      case exponent
      when Numeric then
        ç.of ( quantity ** exponent ).dimension.standard_quantity,
             amount: amount ** exponent
      when Magnitude then
        # Raising to a dimensionless magnitude is allowed (it is converted
        # to a number using #to_f method):
        if exponent.dimensionless? then self ** exponent.to_f else
          # while attempts to raise to a not dimensionless magnitude raise:
          raise TypeError, "Before using a magnitude as an exponent in " +
            "exponentiation, it has to  has to be converted to a number " +
            "(try #in or #to_f methods)."
        end
      else
        raise TypeError, "Magnitudes can only be exponentiated to numbers " +
          "or equivalents. (Exponentiation to a #{other.ç} attempted.)"
      end
    end

    # Type coercion for magnitudes.
    # 
    def coerce other
      case other
      when Numeric then
        return ç.of( Dimension.zero.standard_quantity,
                     amount: other ), self
      when Magnitude then
        aE_same_dimension other
        compat_q_1, compat_q_2 = other.quantity.coerce( quantity )
        return other.( compat_q_2 ), self.( compat_q_1 )
      else
        raise TypeError, "Object #{other} cannot be coerced into a " +
          "compatible magnitude."
      end
    end

    # Gives the magnitude as a numeric value in a given unit. The 'unit' must
    # be a magnitude of a quantity compatible with the receiver (at least of
    # same physical dimension).
    # 
    def numeric_value_in other
      case other
      when Symbol, String then
        # Digest other into the intended type
        other = other.to_s.split( '.' ).reduce 1 do |pipe, sym|
          pipe.send sym
        end
      end
      raise TypeError, DIM_ERR_MSG unless same_dimension? other
      if same_quantity?( other ) then amount / other.amount else
        # use Quantity#coerce for incompatible quantities
        qnt1, qnt2 = other.quantity.coerce( quantity )
        self.( qnt1 ).numeric_value_in other.( qnt2 )
      end
    end
    alias :in :numeric_value_in

    # Gives the magnitude as a numeric value in the basic unit of the
    # quantity of this magnitude.
    # 
    def numeric_value_in_standard_unit
      numeric_value_in( quantity.standard_unit )
    end
    alias :to_f :numeric_value_in_standard_unit

    # Changes the quantity of the magnitude, provided that the dimensions
    # match.
    # 
    def reframe other_quantity
      # make sure that the dimensions match
      raise TypeError, "When reframing, the dimensions must match! " +
        "(Reframing a magnitude of #{dimension} dimension into a quantity " +
        "of #{other_quantity.dimension} dimension attempted.)" unless
          same_dimension? other_quantity
      # and perform the quantity change
      ç.of( other_quantity, amount: amount )
    end
    alias :call :reframe

    # Returns a SignedMagnitude instance with same amount and positive sign.
    # 
    def +@
      SignedMagnitude.of quantity, amount: amount
    end

    # Returns a SignedMagnitude instance with same absolute value of the
    # amount, but opposite sign.
    # 
    def -@
      SignedMagnitude.of quantity, amount: amount
    end

    # Inquirer whether the number of the magnitude is greater of equal than
    # zero. Always true for Magnitude instances, false for negatively signed
    # SignedMagnitude instances.
    # 
    def nonnegative?
      number >= 0
    end

    # Inquirer whether the number of the magnitude is smaller than zero. Always
    # false for Magnitude instances, true for negatively signed SignedMagnitude
    # instances.
    # 
    def negative?
      number < 0
    end



    # further remarks: depending on the area of science the quantity
    # is in, it should have different preferences for unit presentation.
    # Different areas prefer different units for different dimensions.
    
    # For example, if the quantity is "Molarity²", its standard unit will
    # be anonymous and it magnitudes of this quantity should have preference
    # for presenting themselves in μM², or in mΜ², or such
    
    # when attempting to present number Molarity².amount 1.73e-7.mM
    
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
      #          31410.0               5
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

      number, unit_presentation = choice
      number_ς = default_amount_format % number
      unit_presentation_ς = SPS.( *unit_presentation.transpose )

      return [ number_string, unit_presentation ].join '.'
    end


    # Gives the magnitude written "naturally", in its most favored units.
    # It is also possible to supply a unit in which to show the magnitude
    # as the 1st argument (by default, the most favored unit of its
    # quantity), or even, as the 2nd argument, the number format (by default,
    # 3 decimal places).
    # 
    def to_s unit=quantity.units.first, number_format='%.3g'
      begin
        return to_string( unit ) if unit and unit.abbreviation
      rescue
      end
      # otherwise, use units of basic dimensions – here be the magic:
      hsh = dimension.to_hash
      symbols, exponents = hsh.each_with_object Hash.new do |pair, memo|
        dimension_letter, exponent = pair
        std_unit = Dimension.basic( dimension_letter ).standard_unit
        memo[ std_unit.abbreviation || std_unit.name ] = exponent
      end.to_a.transpose
      # assemble the superscripted product string:
      sps = SPS.( symbols, exponents )
      # and finally, interpolate the string
      "#{number_format}#{sps == '' ? '' : '.' + sps}" % amount
    end

    # Inspect string of the magnitude
    # 
    def inspect
      "#<#{çς}: #{self} >"
    end

    private

    def same_dimension? other
      case other
      when Numeric then dimension.zero?
      when Magnitude then dimension == other.dimension
      when Quantity then dimension == other.dimension
      when Dimension then dimension == other
      else
        raise TypeError, "The object (#{other.class} class) does not " +
          "have defined dimension comparable to SY::Dimension"
      end
    end

    def same_quantity? other
      case other
      when Magnitude then quantity == other.quantity
      when Quantity then quantity == other
      else
        raise TypeError, "The object (#{other.class} class) does not " +
          "have quantity (SY::Quantity)"
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
      "#{obj1} not of the same dimension as #{obj2} !!!"
    end

    # String describing this class.
    # 
    def çς
      "Magnitude"
    end

    # Default named unit to be used in expressing this magnitude.
    # 
    def default_named_unit
      quantity.standard_unit
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
  end # class Magnitude

  # Magnitude is generally an absolute value. SignedMagnitude allows magnitude
  # to carry a +/- sign, allowing it to stand in for negative numbers.
  # 
  module SignedMagnitudeMixin
    # SignedMagnitude has overriden #initialize method to allow negative
    # number of the magnitude.
    # 
    def initialize *args
      begin
        super
      rescue NegativeAmountError # just swallow it silently
      end
      # it's O.K. for a SignedMagnitude to have negative @amount
    end

    private

    # String describing this class.
    # 
    def çς
      "±Magnitude"
    end
  end

  class SignedMagnitude < Magnitude
    include SignedMagnitudeMixin
  end
end # module SY
