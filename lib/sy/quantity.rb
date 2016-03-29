#encoding: utf-8

# Metrological quantity is the key class of SY. A quantity has its physical
# dimension, but beyond that, it is characterized by its physical meaning and
# context in which it is used. For example, SY::Amount and SY::MoleAmount are
# both dimensionless quantities, but the second one counts in moles and is
# used in the context of physical chemistry. Quantities SY::ThermalCapacity
# and SY::Entropy have both the same physical dimension, but they have
# different physical meaning. It is not easy to programatically capture the
# often conventions of the different fields of science, and SY achieves this
# by properly defining SY::Quantity class and the mutual relationships between
# its instances.
# 
class SY::Quantity
  # include NameMagic

  class << self
    # Constructor of a new quantity of the supplied dimension. Example:
    # q = Quantity.of Dimension.new( "L.T⁻²" )
    # 
    # FIXME: Figure out how to denote Ruby code in the documentation.
    # 
    def of dimension, **options
      new options.merge( dimension: dimension )
    end

    # Constructor of a new dimensionless quantity.
    # 
    def dimensionless **options
      fail NotImplementedError
      # new options.merge( dimension: Dimension.zero )
    end

    # #standard constructor. Example:
    # q = Quantity.standard of: Dimension.new( "L.T⁻²" )
    def standard( oo )
      fail NotImplementedError
      # new( oo ).set_as_standard
    end
  end

  # attr_reader :name, :dimension
  # def name=( ɴ ); @name = ɴ.blank? ? nil : ɴ.to_s.capitalize end

  # 
  def initialize **options
    return
    # @dimension = Dimension.new options[:dimension] || options[:of]
    # self.name = options[:name] if options[:name]
  end

  # # Convenience shortcut to register a name of the basic unit of
  # # self in the UNITS table. Admits either syntax:
  # # quantity.name_basic_unit "name", symbol: "s"
  # # or
  # # quantity.name_basic_unit "name", "s"
  # def name_basic_unit( ɴ, oj = nil )
  #   u = Unit.basic( oj.respond_to?(:keys) ? oj.merge( of: self, ɴ: ɴ ) :
  #                   { of: self, ɴ: ɴ, abbr: oj } )
  #   BASIC_UNITS[self] = u
  # end
  # alias :ɴ_basic_unit :name_basic_unit

    # # #basic_unit convenience reader of the BASIC_UNITS table
    # def basic_unit; BASIC_UNITS[self] end

    # # #fav_units convenience reader of the FAV_UNITS table
    # def fav_units; FAV_UNITS[self] end

    # # #to_s convertor
    # def to_s; "#{name.nil? ? "quantity" : name} (#{dimension})" end
    
    # # Inspector
    # def inspect
    #   "#{name.nil? ? 'unnamed quantity' : 'quantity "%s"' % name} (#{dimension})"
    # end

    # # Arithmetics
    # # #*
    # def * other
    #   msg = "Quantities only multiply with Quantities, Dimensions and " +
    #     "Numerics (which leaves them unchanged)"
    #   case other
    #   when Numeric then self
    #   when Quantity then self.class.of dimension + other.dimension
    #   when Dimension then self.class.of dimension + other
    #   else raise ArgumentError, msg end
    # end

    # # #/
    # def / other
    #   msg = "Quantities only divide with Quantities, Dimensions and " +
    #     "Numerics (which leaves them unchanged)"
    #   case other
    #   when Numeric then self
    #   when Quantity then self.class.of dimension - other.dimension
    #   when Dimension then self.class.of dimension - other
    #   else raise ArgumentError, msg end
    # end

    # # #**
    # def ** num; self.class.of self.dimension * Integer( num ) end

    # # Make this quantity the standard quantity for its dimension
    # def set_as_standard; QUANTITIES[dimension.to_a] = self end
end # class SY::Quantity
