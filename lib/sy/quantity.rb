#encoding: utf-8
    
module SY
  # This class represents a metrological quantity.
  # 
  class Quantity
    # #of constructor. Example:
    # q = Quantity.of Dimension.new( "L.T⁻²" )
    def self.of( dim, oj = {} ); new oj.merge( dimension: dim ) end

    # #standard constructor. Example:
    # q = Quantity.standard of: Dimension.new( "L.T⁻²" )
    def self.standard( oo ); new( oo ).set_as_standard end

    # Dimensionless quantity constructors:
    def self.zero( oj = {} ); new oj.merge( dimension: Dimension.zero ) end
    def self.null oj = {}; zero oj end
    def self.dimensionless oj = {}; zero oj end

    attr_reader :name, :dimension
    def name=( ɴ ); @name = ɴ.blank? ? nil : ɴ.to_s.capitalize end
    
    # Quantity is little more then a combination of a name and a
    # metrological dimension.
    def initialize oj
      @dimension = Dimension.new oj[:dimension] || oj[:of]
      ɴ = oj[:name] || oj[:ɴ]
      @name = ɴ.blank? ? nil : ɴ.to_s.capitalize
    end

    # Convenience shortcut to register a name of the basic unit of
    # self in the UNITS table. Admits either syntax:
    # quantity.name_basic_unit "name", symbol: "s"
    # or
    # quantity.name_basic_unit "name", "s"
    def name_basic_unit( ɴ, oj = nil )
      u = Unit.basic( oj.respond_to?(:keys) ? oj.merge( of: self, ɴ: ɴ ) :
                      { of: self, ɴ: ɴ, abbr: oj } )
      BASIC_UNITS[self] = u
    end
    alias :ɴ_basic_unit :name_basic_unit

    # #basic_unit convenience reader of the BASIC_UNITS table
    def basic_unit; BASIC_UNITS[self] end

    # #fav_units convenience reader of the FAV_UNITS table
    def fav_units; FAV_UNITS[self] end

    # #to_s convertor
    def to_s; "#{name.nil? ? "quantity" : name} (#{dimension})" end
    
    # Inspector
    def inspect
      "#{name.nil? ? 'unnamed quantity' : 'quantity "%s"' % name} (#{dimension})"
    end

    # Arithmetics
    # #*
    def * other
      msg = "Quantities only multiply with Quantities, Dimensions and " +
        "Numerics (which leaves them unchanged)"
      case other
      when Numeric then self
      when Quantity then self.class.of dimension + other.dimension
      when Dimension then self.class.of dimension + other
      else raise ArgumentError, msg end
    end

    # #/
    def / other
      msg = "Quantities only divide with Quantities, Dimensions and " +
        "Numerics (which leaves them unchanged)"
      case other
      when Numeric then self
      when Quantity then self.class.of dimension - other.dimension
      when Dimension then self.class.of dimension - other
      else raise ArgumentError, msg end
    end

    # #**
    def ** num; self.class.of self.dimension * Integer( num ) end

    # Make this quantity the standard quantity for its dimension
    def set_as_standard; QUANTITIES[dimension.to_a] = self end
  end # class Quantity
end # module SY
