#encoding: utf-8

module SY
  # This class represents a metrological quantity.
  # 
  class Quantity
    include NameMagic
    attr_reader :dimension

    
    attr_writer :standard_unit

    # Quantity constructor. Example:
    # <tt>Quantity.of Dimension.new( "L.T⁻²" )</tt>
    # 
    def self.of *args
      hash = args.extract_options!
      case args.size
      when 0 then new hash
      when 1 then new( hash.merge dimension: args[0] )
      else
        raise ArgumentError,
          "Too many ordered arguments (args.size for at most 1)!"
      end
    end

    # Standard quantity accessor. Example:
    # <tt>Quantity.standard of: Dimension.new( "L.T⁻²" )</tt>
    # or
    # <tt>Quantity.standard of: "L.T⁻²"
    # (Both should give Acceleration as their result.)
    # 
    def self.standard *args, &block
      hash = args.extract_options!
      dim = Dimension.new hash.must_have( :dimension, syn!: :of )
      Dimension.new( hash.must_have( :dimension, syn!: :of ) )
        .standard_quantity
    end

    # Dimensionless quantity constructor alias.
    # 
    def self.dimensionless hash={}
      new hash.merge( dimension: Dimension.zero )
    end

    # Standard constructor of a metrological quantity. A quantity may have
    # a name and a dimension.
    # 
    def initialize *args
      hash = args.extract_options!
      @dimension = Dimension.new hash.must_have( :dimension, syn!: :of )
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

    # Quantity arithmetic: multiplication.
    # 
    def * other
      case other
      when Numeric then self
      when Quantity then ç.standard of: dimension + other.dimension
      when Dimension then ç.standard of: dimension + other
      else
        raise ArgumentError, "Quantities only multiply with quantities, " +
          "dimensions and numbers (the last case having no effect)."
      end
    end

    # Quantity arithmetic: division.
    # 
    def / other
      case other
      when Numeric then self
      when Quantity then ç.standard of: dimension - other.dimension
      when Dimension then ç.standard of: dimension - other
      else
        raise ArgumentError, "Quantities only divide with quantities, " +
          "dimensions and numbers (the last case having no effect)."
      end
    end

    # Quantity arithmetic: power to a number.
    # 
    def ** number
      ç.standard of: dimension * Integer( number )
    end

    # Inquirer whether the quantity is dimensionless.
    # 
    def dimensionless?
      dimension.zero?
    end

    # Make this quantity the standard quantity for its dimension.
    # 
    def set_as_standard
      ::SY::Dimension.standard_quantities[ dimension ] = self
    end

    def to_s                         # :nodoc:
      if name.nil? then dimension.to_s else name.to_s end
    end

    def inspect                      # :nodoc:
      "#<#{ç.name.match( /[^:]+$/ )[0]}: #{name.nil? ? dimension : name} >"
    end

    def coerce other                 # :nodoc:
      case other
      when Quantity then
        # By default, coercion between quantities doesn't work:
        # Quantities are quantities so as not to mix together, as in
        # "you cannot sum pears with apples". But in some special cases,
        # this could conceivably be overridden so that <em>some</em>
        # quantities would be coercible to others.
        # 
        if other == self then return other, self else
          raise TypeError, "Different quantities (up to exceptions) " +
            "do not mix with each other."
        end
      when Numeric then
        return Quantity.dimensionless, self
      else
        raise TypeError, "Object #{other} cannot be coerced into a quantity."
      end
    end

    private

    def same_dimension? other
      case other
      when Dimension then dimension == other
      when Quantity then dimension == other.dimension
      when Magnitude then dimension == other.dimension
      when Numeric then dimensionless?
      else
        raise ArgumentError, "The object <#{other.class}:#{other.object_id}> " +
          "cannot be coerced into quantity."
      end
    end
  end # class Quantity
end # module SY
