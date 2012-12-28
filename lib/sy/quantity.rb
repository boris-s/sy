#encoding: utf-8

module SY
  # This class represents a metrological quantity.
  # 
  class Quantity
    include NameMagic
    attr_reader :dimension, :magnitude, :factorization

    class << self
      # Dimension-based quantity constructor. Examples:
      # <tt>Quantity.of Dimension.new( "L.T⁻²" )</tt>
      # <tt>Quantity.of "L.T⁻²"</tt>
      # 
      def of *args
        ꜧ = args.extract_options!
        dim = case args.size
              when 0 then
                ꜧ.must_have :dimension, syn!: :of
                ꜧ.delete :dimension
              else args.shift end
        args << ꜧ.merge!( dimension: Dimension.new( dim ) )
        return new *args
      end

      # Composition-based quantity constructor. Examples:
      # <tt>Quantity.compose( Speed => 1, Time => -1 )</tt>
      # 
      def compose *args
        ꜧ = args.extract_options!
        fac = case args.size
              when 0 then
                ꜧ.must_have :factorization
                ꜧ.delete :factorization
              else args.shift end
        args << ꜧ.merge!( factorization: fac )
        return new *args
      end

      # Standard quantity. Example:
      # <tt>Quantity.standard of: Dimension.new( "L.T⁻²" )</tt>
      # or
      # <tt>Quantity.standard of: "L.T⁻²"
      # (Both should give Acceleration as their result.)
      # 
      def standard *args
        ꜧ = args.extract_options!
        dim = case args.size
              when 0 then
                ꜧ.must_have :dimension, syn!: :of
                ꜧ.delete :dimension
              else args.shift end
        return dim.standard_quantity
      end

      # Dimensionless quantity constructor alias.
      # 
      def dimensionless *args
        ꜧ = args.extract_options!
        raise TE, "Dimension not zero!" unless ꜧ[:dimension].zero? if
          ꜧ.has? :dimension, syn!: :of
        new *( args << ꜧ.merge!( dimension: Dimension.zero ) )
      end
    end

    # Standard constructor of a metrological quantity. A quantity may have
    # a name and a dimension.
    # 
    def initialize *args
      ꜧ = args.extract_options!
      if ꜧ.has? :factorization then
        @factorization = ꜧ[:factorization]
        @dimension = dimension_of_factorization( @factorization )
      else
        @dimension = SY.Dimension( ꜧ.must_have :dimension )
      end
      @magnitude = Class.new( Magnitude )
      @unit = Class.new @magnitude do include UnitMixin end
    end

    def factorization
      @factorization ||= default_factorization
    end

    # Writer of standard unit
    # 
    def standard_unit= unit
      @standard_unit = unit.tE_kind_of ::SY::Unit
      # Make it the most favored unit
      @units.unshift( unit ).uniq!
    end

    # Reader of standard unit.
    # 
    def standard_unit
      @standard_unit ||= Unit.of self
    end

    # Presents an array of units ordered as favored by this quantity.
    # 
    def units
      @units ||= []
    end

    # Creates a new magnitude pertinent to this quantity. Takes one argument —
    # amount of the magnitude.
    # 
    def new_magnitude *args
      ꜧ = args.extract_options!
      @magnitude.new *args, ꜧ.merge!( of: self )
    end
    alias :amount :new_magnitude

    # Creates a new unit pertinent to this quantity.
    # 
    def new_unit *args
      # FIXME - creation of a new unit
    end

    # Quantity arithmetic: multiplication.
    # 
    def * other
      ç.compose factorization.merge other.factorization do |qnt, exp1, exp2|
        exp1 + exp2
      end
    end

    # Quantity arithmetic: division.
    # 
    def / other
      ç.compose factorization.merge other.factorization do |qnt, exp1, exp2|
        exp1 - exp2
      end
    end

    # Quantity arithmetic: power to a number.
    # 
    def ** number
      ç.compose Hash[ factorization.map { |qnt, exp| [ qnt, exp * number ] } ]
    end

    # Inquirer whether the quantity is dimensionless.
    # 
    def dimensionless?
      dimension.zero?
    end

    # Make this quantity the standard quantity for its dimension.
    # 
    def standard
      Dimension.standard_quantities[ dimension ]
    end

    def to_s
      if name.nil? then dimension.to_s else name.to_s end
    end

    def inspect
      "#<#{ç.name.match( /[^:]+$/ )[0]}: #{name.nil? ? dimension : name} >"
    end

    def coerce other
      case other
      when Quantity then
        # By default, coercion between quantities doesn't exist. The basic
        # purpose of having quantities is to avoid mutual mixing of
        # incompatible magnitudes, as in "one cannot sum pears with apples".
        # 
        if other == self then return other, self else
          raise TE, "Different quantities (up to exceptions) do not mix."
        end
      when Numeric then
        return Quantity.dimensionless, self
      else
        raise TE, "#{other} cannot be coerced into a quantity."
      end
    end

    private

    def same_dimension? other
      case other
      when Quantity then dimension == other.dimension
      when Magnitude then dimension == other.dimension
      when Numeric then dimensionless?
      when Dimension then dimension == other
      else
        raise AE, "The object <#{other.class}:#{other.object_id}> cannot " +
          "be coerced into quantity."
      end
    end

    def default_factorization
      dimension.to_hash.each_with_object Hash.new do |pair, ꜧ|
        dim, exp = pair
        ꜧ.merge!( SY.Dimension( dim ).standard_quantity => exp ) if exp > 0
      end
    end

    def dimension_of_factorization factorization
      factorization.map { |quantity, exponent|
        quantity.dimension * exponent
      }.reduce :+
    end
  end # class Quantity
end # module SY
