#encoding: utf-8

module SY
  # This class represents a metrological quantity.
  # 
  class Quantity
    # Quantity constructor. Example:
    # <tt>Quantity.of Dimension.new( "L.T⁻²" )</tt>
    # 
    def self.of *args
      ꜧ = args.extract_options!
      case args.size
      when 0 then new( ꜧ )
      when 1 then new( ꜧ.merge dimension: args[0] )
      else raise ArgumentError, "too many arguments" end
    end

    # Standard quantity constructor. Example:
    # <tt>Quantity.standard of: Dimension.new( "L.T⁻²" )</tt>
    # 
    def self.standard *args
      of( *args ).set_as_standard
    end

    # Dimensionless quantity constructor.
    # 
    def self.zero hash={}
      new hash.merge( dimension: Dimension.zero )
    end

    # Dimensionless quantity constructor alias.
    # 
    def self.null hash={}
      zero( hash )
    end

    # Dimensionless quantity constructor alias.
    # 
    def self.dimensionless hash={}
      zero( hash )
    end

    attr_reader :name, :dimension

    # Name writer.
    # 
    def name=( name )
      @name = if name.blank? then nil else name.to_s.capitalize end
    end

    # Standard constructor of a metrological quantity. A quantity may have
    # a name and a dimension.
    # 
    def initialize *args
      ꜧ = args.extract_options!
      @dimension = Dimension.new ꜧ[:dimension] || ꜧ[:of]
      ɴ = ꜧ[:name] || ꜧ[:ɴ]
      @name = if ɴ.blank? then nil else ɴ.to_s.capitalize end
    end

    # Convenience shortcut to register a name of the basic unit of the
    # quantity in SY::UNITS table. Admits either syntax:
    # <tt>quantity.name_basic_unit "name", symbol: "s"</tt>
    # or
    # <tt>quantity.name_basic_unit "name", "s"<tt>
    # 
    def name_basic_unit( name, hash=nil )
      BASIC_UNITS[self] = Unit.basic( if hash.respond_to?(:keys) then
                                        hash.merge( of: self, ɴ: name )
                                      else # second type syntax
                                        { of: self, ɴ: name, abbr: hash }
                                      end )
    end
    alias :ɴ_basic_unit :name_basic_unit

    # Convenience reader of the SY::BASIC_UNITS table.
    # 
    def basic_unit
      BASIC_UNITS[self]
    end

    # Convenience reader of the FAV_UNITS table.
    # 
    def fav_units
      FAV_UNITS[self]
    end

    # Quantity arithmetic: multiplication.
    # 
    def * other
      case other
      when Numeric then self
      when Quantity then self.class.of dimension + other.dimension
      when Dimension then self.class.of dimension + other
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
      when Quantity then self.class.of dimension - other.dimension
      when Dimension then self.class.of dimension - other
      else
        raise ArgumentError, "Quantities only divide with quantities, " +
          "dimensions and numbers (the last case having no effect)."
      end
    end

    # Quantity arithmetic: power to a number.
    # 
    def ** number
      self.class.of self.dimension * Integer( number )
    end

    # Inquirer whether the quantity is dimensionless.
    # 
    def dimensionless?
      dimension.zero?
    end

    # Make this quantity the standard quantity for its dimension.
    # 
    def set_as_standard
      QUANTITIES[dimension.to_a] = self
    end

    def to_s                         # :nodoc:
      if name.nil? then dimension.to_s else name.to_s end
    end

    def inspect                      # :nodoc:
      "#<Quantity: #{name.nil? ? dimension : name} >"
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
          raise ArgumentError, "Different quantities (up to exceptions) " +
            "do not mix with each other."
        end
      else
        raise ArgumentError, "Object #{other} cannot be coerced into " +
          "a quantity"
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
