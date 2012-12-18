#encoding: utf-8

module SY
  # This class represents a magnitude of a metrological quantity.
  # 
  class Magnitude
    include UnitMethodsMixin
    include Comparable

    # Constructor of magnitudes of a given quantity.
    # 
    def self.of *args
      ꜧ = args.extract_options!
      case args.size
      when 0 then new ꜧ
      when 1 then new ꜧ.merge! quantity: args[0]
      else
        raise ArgumentError, "Too many ordered arguments."
      end
    end
    
    attr_reader :quantity, :number
    alias :n :number
    delegate :dimension, :basic_unit, :fav_units, to: :quantity

    # A magnitude is basically a pair [quantity, number].
    # 
    def initialize *args
      ꜧ = args.extract_options!
      @quantity = ꜧ[:quantity] || ꜧ[:of]
      raise ArgumentError unless @quantity.kind_of? Quantity
      @number = ꜧ[:number] || ꜧ[:n]
      raise NegativeMagnitudeError, "Attempt to create a magnitude " +
        "with negative number (#@number)." unless @number >= 0
    end
    # idea: for more complicated units (offsetted, logarithmic etc.),
    # conversion closures from_basic_unit, to_basic_unit

    # Magnitudes compare by their numbers. Compared magnitudes must be of
    # the same quantity.
    # 
    def <=> other
      case other
      when Magnitude then
        aE_same_quantity other
        self.n <=> other.n
      else
        raise ArgumentError,
          "A Magnitude cannot be compared with a #{other.class}"
      end
    end
      
    # Addition.
    # 
    def + other
      case other
      when Magnitude then
        aE_same_dimension( other )
        if same_quantity?( other ) then
          begin
            self.class.of( quantity, n: self.n + other.n )
          rescue NegativeMagnitudeError
            raise MagnitudeSubtractionError,
              "Attempt to subtract greater magnitude from a smaller one."
          end
        else
          compatible_quantity_1, compatible_quantity_2 =
            other.quantity.coerce( self.quantity )
          self.class.of( compatible_quantity_1, n: self.n ) +
            other.class.of( compatible_quantity_2, n: other.n )
        end
      else
        raise ArgumentError, "Magnitudes can only be added to compatible " +
          "other magnitudes."
      end
    end

    # Subtraction.
    # 
    def - other
      case other
      when Magnitude then
        aE_same_dimension( other )
        if same_quantity?( other ) then
          begin
            self.class.of( quantity, n: self.n - other.n )
          rescue NegativeMagnitudeError
            raise MagnitudeSubtractionError,
              "Attempt to subtract greater magnitude from a smaller one."
          end
        else
          compatible_quantity_1, compatible_quantity_2 =
            other.quantity.coerce( self.quantity )
          self.class.of( compatible_quantity_1, n: self.n ) +
            other.class.of( compatible_quantity_2, n: other.n )
        end
      else
        raise ArgumentError, "Magnitudes can only be subtracted from " +
          "compatible other magnitudes."
      end
    end

    # Multiplication.
    # 
    def * other
      case other
      when Magnitude then
        self.class.of( quantity * other.quantity, n: self.n * other.n )
      when Numeric then [1, other]
        self.class.of( quantity, n: self.n * other )
      else
        raise ArgumentError,
          "Magnitudes only multiply with other magnitudes and numbers."
      end
    end

    # Division.
    # 
    def / other
      case other
      when Magnitude
        self.class.of( quantity / other.quantity, n: self.n / other.n )
      when Numeric then [1, other]
        self.class.of( quantity, n: self.n / other )
      else
        raise ArgumentError,
          "Magnitudes only divide by magnitudes and numbers."
      end
    end

    # Exponentiation.
    # 
    def ** exponent
      raise ArgumentError, "Magnitudes can only be exponentiated " +
        "to numbers." unless arg.is_a? Numeric
      self.class.of( quantity ** arg, n: self.n ** arg )
    end

    # Gives the magnitude as a numeric value in a given unit. The 'unit' must
    # be a magnitude of the same dimension and of quantity compatible with
    # the receiver.
    # 
    def numeric_value_in other
      case other
      when Symbol, String then
        other = other.to_s.split( '.' ).reduce 1 do |pipe, sym|
          pipe.send sym
        end
      end
      aE_same_dimension( other )
      if same_quantity?( other ) then
        self.number / other.number
      else
        comp_quantity_1, comp_quantity_2 =
          other.quantity.coerce( self.quantity )
        self.class.of( comp_quantity_1, n: self.number ).
          numeric_value_in other.class.of( comp_quantity_2, n: other.number )
      end
    end
    alias :in :numeric_value_in

    # Gives the magnitude as a numeric value in the basic unit of the
    # quantity of this magnitude.
    # 
    def numeric_value_in_basic_unit
      numeric_value_in BASIC_UNITS[self.quantity]
    end
    alias :to_f :numeric_value_in_basic_unit

    # Changes the quantity of the magnitude, provided that the dimensions
    # match.
    # 
    def is_actually! other_quantity
      raise ArgumentError, "supplied quantity dimension must match!" unless
        same_dimension? other_quantity
      # perform the quantity change:
      puts "Hello! Other quantity is #{other_quantity}."
      self.class.of( other_quantity, n: self.number )
      return self
    end
    alias :call :is_actually!

    # Gives a string expressing the magnitude in given compatible units.
    #
    def string_in unit=BASIC_UNITS[self.quantity]
      str = ( unit.symbol || unit.name ).to_s
      ( str == "" ? "%.2g" : "%.2g.#{str}" ) % numeric_value_in( unit )
    end

    # Returns a SignedMagnitude instance with same value and positive sign.
    # 
    def +@
      SignedMagnitude.plus quantity, number: n
    end

    # Returns a SignedMagnitude instance with same absolute value, but
    # negative sign.
    # 
    def -@
      SignedMagnitude.minus quantity, number: n
    end

    # Magnitude of the same quantity, whose number was subjected to #abs call.
    # 
    def abs
      self.class.of quantity, number: n.abs
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

    # #to_s converter gives the magnitude in its most favored units
    # 
    def to_s                         # :nodoc:
      unit = fav_units[0]
      str = if unit then string_in( unit )
            else # use fav_units of basic dimensions
              hsh = dimension.to_hash
              symbols, exponents = hsh.each_with_object Hash.new do |pair, memo|
                sym, val = pair
                u = Dimension.basic( sym ).fav_units[0]
                memo[u.symbol || u.name] = val
              end.to_a.transpose
              sps = SPS.( symbols, exponents )
              "%.2g#{sps == '' ? '' : '.' + sps}" % number
            end
    end

    def inspect                      # :nodoc:
      "#<Magnitude: #{to_s} of #{quantity} >"
    end

    def coerce other                 # :nodoc:
      case other
      when Numeric then
        return self.class.of( Quantity.dimensionless, n: other ), self
      when Magnitude then
        aE_same_dimension other
        compatible_quantity_1, compatible_quantity_2 =
          other.quantity.coerce( self.quantity )
        return self.class.of( compatible_quantity_1, n: self.number ),
               other.class.of( compatible_quantity_2, n: other.number )
      else
        raise ArgumentError, "Object #{other} cannot be coerced into a " +
          "compatible magnitude."
      end
    end

    private

    def same_dimension? other
      case other
      when Numeric then dimension.zero?
      when Magnitude then dimension == other.dimension
      when Quantity then dimension == other.dimension
      when Dimension then dimension == other
      else
        raise ArgumentError, "The object (#{other.class} class) does not " +
          "have defined dimension comparable to SY::Dimension"
      end
    end

    def same_quantity? other
      case other
      when Magnitude then quantity == other.quantity
      when Quantity then quantity == other
      else
        raise ArgumentError, "The object (#{other.class} class) does not " +
          "have quantity (SY::Quantity)"
      end
    end

    def aE_same_dimension other
      raise ArgumentError, "Magnitude not of the same dimension as " +
        "#{other}" unless same_dimension? other
    end

    def aE_same_quantity other
      raise ArgumentError, "Magnitude not of the same quantity as " +
        "#{other}" unless same_quantity? other
    end
  end # class Magnitude

  # Magnitude is generally an absolute value. SignedMagnitude allows magnitude
  # to carry a +/- sign, allowing it to stand in for negative numbers.
  # 
  class SignedMagnitude < Magnitude
    def initialize oo
      @quantity = oo[:quantity] || oo[:of]
      raise ArgumentError unless @quantity.kind_of? Quantity
      @number = oo[:number] || oo[:n]
    end
  end
end
