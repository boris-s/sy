#encoding: utf-8

module SY
  # This class represents a magnitude of a metrological quantity. A magnitude
  # is basically a pair [quantity, amount].
  # 
  class Magnitude
    include UnitMethodsMixin # ensuring that magnitudes respond to unit methods
    include Comparable

    # Constructor of magnitudes of a given quantity.
    # 
    def self.of *args
      ꜧ = args.extract_options!
      case args.size
      when 0 then new ꜧ
      when 1 then new ꜧ.merge!( quantity: args[0] )
      else
        raise ArgumentError, "Too many ordered arguments."
      end
    end

    attr_reader :quantity, :amount

    delegate :dimension,
             :dimensionless?,
             to: :quantity

    # A magnitude is basically a pair [quantity, number].
    # 
    def initialize *args
      hash = args.extract_options!
      @quantity = hash.must_have :quantity, syn!: :of
      raise TypeError, "Named argument :quantity must be of " +
        "SY::Quantity class." unless @quantity.is_a? ::SY::Quantity
      @amount = case am = hash[:amount] || 1
                when Magnitude then
                  tE_same_dimension( am )
                  am.numeric_value_in_standard_unit
                else am end
      raise NegativeAmountError, "Attempt to create a magnitude " +
        "with negative amount (#@amount)." unless @amount >= 0
    end

    # Absolute value of a Magnitude: A new magnitude instance with amount equal
    # to the absolute value of this magnitude's amount.
    # 
    def abs
      ::SY::Magnitude.of quantity, amount: amount.abs
    end

    # Whether the magnitude is zero.
    # 
    def zero?
      amount.zero?
    end

    # Magnitudes compare by their numbers. Compared magnitudes must be of
    # the same quantity.
    # 
    def <=> other
      case other
      when Magnitude then
        tE_same_dimension other # different dimensions do not compare
        if same_quantity? other then
          rslt = amount <=> other.amount
          return amount <=> other.amount
        else
          # use Quantity#coerce for incompatible quantities
          compat_q_1, compat_q_2 = other.quantity.coerce( quantity )
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
        tE_same_dimension other # different dimensions do not mix
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
        return self if other.respond_to? :zero? and other.zero? rescue
        raise IncompatibleQuantityError, "Magnitudes may only be added to " +
          "compatible other magnitudes (adding to a #{other.ç} attempted)."
      end
    end

    # Subtraction.
    # 
    def - other
      case other
      when Magnitude then
        tE_same_dimension other # different dimensions do not mix
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
        return ç.of( if other.zero? then quantity else
                       Dimension.zero.standard_quantity
                     end, amount: other ), self
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
      tE_same_dimension( other )
      if same_quantity?( other ) then amount / other.amount else
        # use Quantity#coerce for incompatible quantities
        compat_q_1, compat_q_2 = other.quantity.coerce( quantity )
        self.( compat_q_1 ).numeric_value_in other.( compat_q_2 )
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
      "#<#{ç.name.match( /[^:]+$/ )[0]}: #{to_s} >"
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

    def tE_same_dimension other
      raise TypeError, "#{self} not of the same dimension as " +
        "#{other}" unless same_dimension? other
    end

    def tE_same_quantity other
      raise TypeError, "#{self} not of the same quantity as " +
        "#{other}" unless same_quantity? other
    end

    # The engine for constructing #to_s strings.
    #
    def to_string unit=quantity.standard_unit, number_format='%.3g'
      str = ( unit.abbreviation || unit.name ).to_s
      "#{number_format}.#{ str == '' ? unit : str }" %
        numeric_value_in( unit )
    end
  end # class Magnitude

  # Magnitude is generally an absolute value. SignedMagnitude allows magnitude
  # to carry a +/- sign, allowing it to stand in for negative numbers.
  # 
  class SignedMagnitude < Magnitude

    # SignedMagnitude has overriden #initialize method to allow negative
    # number of the magnitude.
    # 
    def initialize *args
      begin
        super
      rescue
        NegativeAmountError
      end # just swallow it silently,
      # it's O.K. for a SignedMagnitude to have negative @amount
    end
  end
end # module SY
