#encoding: utf-8

# This class represents a metrological quantity.
# 
class SY::Quantity
  include NameMagic
  attr_reader :dimension, :magnitude, :factorization
  
  # The keys of this hash are unary or binary mathematical operations on
  # quantities. They are stored as and array, whose 1st element is the
  # operator method, and the rest are the operands (eg. [ :/, Length, Time ],
  # translated as Length / Time, aka. Speed).
  # 
  OPERATION_TABLE = Hash.new { |ꜧ, missing_key|
    begin
      operator = missing_key[0].to_sym # eg :/
      operands = missing_key[1..-1]    # eg [Length, Time]
    rescue NoMethodError
      nil
    else
      case operator
      when :* then
        op1, op2 = operands.aT { size == 2 }
        ꜧ[missing_key] = SY::Quantity.compose op1 => 1, op2 => 1
      when :/ then
        op1, op2 = operands.aT { size == 2 }
        ꜧ[missing_key] = SY::Quantity.compose op1 => 1, op2 => -1
      when :** then
        op1, op2 = operands.aT { size == 2 }
        ꜧ[missing_key] = SY::Quantity.compose op1 => op2.aT_is_a( Numeric )
      else
        raise TypeError, "Unrecognized operator: #{operator}"
      end
    end
  }

  def OPERATION_TABLE.[]( *args )
    super args
  end

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
      args << ꜧ.merge!( dimension: SY::Dimension.new( dim ) )
      return new *args
    end

    # Composition-based quantity constructor. Examples:
    # <tt>Quantity.compose( Speed => 1, Time => -1 )</tt>
    # 
    def compose *args
      ꜧ = args.extract_options!
      comp = case args.size
             when 0 then
               if ꜧ.has? :composition then
                 comp = ꜧ.delete :composition
               else
                 comp = ꜧ.dup.tap { ꜧ.clear }
               end
             else
               raise AErr, "Unexpected ordered arguments."
             end
      return new *args, ꜧ.merge!( composition: comp )
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
      raise TErr, "Dimension not zero!" unless ꜧ[:dimension].zero? if
        ꜧ.has? :dimension, syn!: :of
      new *( args << ꜧ.merge!( dimension: Dimension.zero ) )
    end
  end
  
  # Standard constructor of a metrological quantity. A quantity may have
  # a name and a dimension.
  # 
  def initialize *args
    ꜧ = args.extract_options!
    if ꜧ.has? :composition then
      @composition = ꜧ[:composition]
      @dimension = dimension_of_composition( @composition )
      raise AErr, "Conflict in arguments: Explicitly stated dimension " +
        "different from the composition dimension!" unless
        @dimension == ꜧ[:dimension] if ꜧ.has? :dimension, syn!: :of
    else
      @dimension = SY.Dimension( ꜧ.must_have :dimension )
    end
    @magnitude = Class.new( SY::Magnitude )
    @signed_magnitude = Class.new @magnitude do include SY::SignedMixin end
    @unit = Class.new @magnitude do include SY::UnitMixin end
  end

  def composition
    @composition ||= default_composition
  end

  # Writer of standard unit
  # 
  def standard_unit= unit
    @standard_unit = unit.aT_kind_of @unit
    # Make it the most favored unit
    units.unshift( unit ).uniq!
  end

  # Reader of standard unit.
  # 
  def standard_unit *args
    ꜧ = args.extract_options!
    @standard_unit ||= new_unit *args
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
    @magnitude.new *args, ꜧ.merge!( quantity: self )
  end

  def amount *args
    ꜧ = args.extract_options!
    raise AErr, "#amount requires exactly 1 ordered argument" unless
      args.size == 1
    new_magnitude ꜧ.merge!( amount: args[0] )
  end
  alias :amount :new_magnitude

  # Creates a new unit pertinent to this quantity.
  # 
  def new_unit *args
    ꜧ = args.extract_options!
    @unit.new *args, ꜧ.merge!( quantity: self )
  end

  # Quantity arithmetic: multiplication.
  # 
  def * other
    OPERATION_TABLE[ :*, self, other ]
  end

  # Quantity arithmetic: division.
  # 
  def / other
    OPERATION_TABLE[ :/, self, other ]
  end

  # Quantity arithmetic: power to a number.
  # 
  def ** number
    OPERATION_TABLE[ :**, self, number ]
  end

  # Inquirer whether the quantity is dimensionless.
  # 
  def dimensionless?
    dimension.zero?
  end

  # Make this quantity the standard quantity for its dimension.
  # 
  def standard
    SY::Dimension.standard_quantities[ dimension ]
  end

  # Produces a string briefly describing the quantity.
  # 
  def to_s
    if name.nil? then dimension.to_s else name.to_s end
  end

  # Produces the inspect string of the quantity.
  # 
  def inspect
    "#<Quantity: #{name.nil? ? dimension : name} >"
  end

  def coerce other
    case other
    when Numeric then
      return SY::Quantity.dimensionless, self
    when SY::Quantity then
      # By default, coercion between quantities doesn't exist. The basic
      # purpose of having quantities is to avoid mutual mixing of
      # incompatible magnitudes, as in "one cannot sum pears with apples".
      # 
      if other == self then
        return other, self
      else
        raise SY::IncompatibleQuantityError,
              "Different quantities (up to exceptions) do not mix!"
      end
    else
      raise TErr, "A #{other.class} cannot be coerced into a quantity!"
    end
  end

  private

  def same_dimension? other
    case other
    when Numeric then dimensionless?
    else
      dimension == other.dimension
    end
  end

  def default_composition
    dimension.to_hash.each_with_object Hash.new do |pair, ꜧ|
      dim, exp = pair
      ꜧ.merge!( SY.Dimension( dim ).standard_quantity => exp ) if exp.abs > 0
    end
  end

  def dimension_of_composition comp
    comp.map { |quantity, exponent|
      quantity.dimension * exponent
    }.reduce( :+ )
  end
end # class SY::Quantity
