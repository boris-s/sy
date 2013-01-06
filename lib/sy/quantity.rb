#encoding: utf-8

class SY::QuantityComposition
end

# Quantity.
# 
class SY::Quantity
  include NameMagic
  attr_reader :dimension, :magnitude, :unit, :relationship

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
      return SY.Dimension( dim ).standard_quantity
    end
    
    # Dimensionless quantity constructor alias.
    # 
    def dimensionless *args
      ꜧ = args.extract_options!
      raise TErr, "Dimension not zero!" unless ꜧ[:dimension].zero? if
        ꜧ.has? :dimension, syn!: :of
      new *( args << ꜧ.merge!( dimension: SY::Dimension.zero ) )
    end

    def << other
      puts "Hello from custom #<<"
    end
  end
  
  # Standard constructor of a metrological quantity. A quantity may have
  # a name and a dimension.
  # 
  def initialize args={}
    @relative = args[:relative]      # relative vs. absolute quantity
    if args.has? :composition then
      @composition = SY::Quantity::Composition.new args[:composition]
      @dimension = @composition.dimension
    else
      @dimension = SY.Dimension( args.must_have :dimension, syn!: :of )
    end
    # Prepare parametrized magnitude class
    mixin = magnitude_mixin
    @magnitude = Class.new do
      include SY::Magnitude
      include mixin
    end
    # and unit class.
    @unit = Class.new @magnitude do
      include SY::Unit
    end
  end

  # Is the quantity relative?
  #
  def relative?
    @relative ? true : false
  end

  # Is the quantity absolute? (Opposite of #relative?)
  # 
  def absolute?
    ! relative?
  end

  # Relative quantity related to this quantity.
  # 
  def relative_quantity
    @relative_quantity or
      self.relative_quantity = relative? ? self : construct_relative_quantity
  end

  def relative_quantity= qnt
    @relative_quantity = qnt
  end

  # Absolute quantity related to this quantity.
  # 
  def absolute_quantity
    @absolute_quantity or
      self.absolute_quantity = absolute? ? self : construct_absolute_quantity
  end

  def absolute_quantity= qnt
    @absolute_quantity = qnt
  end

  def composition
    @composition ||= default_composition
  end

  # Writer of standard unit
  # 
  def standard_unit_set unit, relationship
    @relationship = relationship
    @standard_unit = unit.aE { |u| u.quantity == quantity }
  end

  def reletionship_set magnitude_of_other_quantity
    # FIXME: Other quantity must be
    # 1. other, different from this one
    # 2. must have same relative/absolute status as this quantity
    # 3. the partner relative/absolute quantity must not have
    #    conflicting relationship
    #
    # ... actually, already dimensions wil be divided into
    # L/ΔL, T/ΔT, M/ΔM, 
    # 
    @relationship = magnitude_of_other_quantity
  end

  # Reader of standard unit.
  # 
  def standard_unit args={}
    @standard_unit ||= new_unit args
  end

  # Presents an array of units ordered as favored by this quantity.
  # 
  def units
    @units ||= []
  end

  # Constructs a new absolute magnitude of this quantity.
  # 
  def new_magnitude arg
    @magnitude.new quantity: self, amount: arg
  end

  # Constructs a new unit of this quantity.
  # 
  def new_unit args={}
    unit.new args.merge( quantity: self )
  end

  # Quantity multiplication.
  # 
  def * other
    OPERATION_TABLE[ :*, self, other ]
  end

  # Quantity division.
  # 
  def / other
    OPERATION_TABLE[ :/, self, other ]
  end

  # Quantity raising to a number.
  # 
  def ** number
    OPERATION_TABLE[ :**, self, number ]
  end

  # Is the quantity dimensionless?
  # 
  def dimensionless?
    dimension.zero?
  end

  # Make the quantity standard for its dimension.
  # 
  def standard!
    SY::Dimension.standard_quantities[ dimension ] = self
  end

  # Returns the standard quantity for this quantity's dimension.
  # 
  def standard
    dimension.standard_quantity
  end

  # A string briefly describing the quantity.
  # 
  def to_s
    name.nil? ? "[#{dimension}]" : name.to_s
  end

  # Inspect string.
  # 
  def inspect
    "#<Quantity: #{to_s} >"
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

  def construct_relative_quantity
    if name then
      ç.new dimension: dimension, relative: true, name: "#{name}Difference"
    else
      ç.new dimension: dimension, relative: true
    end
  end

  def construct_absolute_quantity
    if name && name.to_s.ends_with?( "Difference" ) &&
        ! ( stripped_name = name[0..("Difference".size - 1)] ).empty? then
      ç.new dimension: dimension, relative: false, name: stripped_name
    else
      ç.new dimension: dimension, relative: false
    end
  end

  def magnitude_mixin
    relative? ? SY::SignedMagnitudeMixin : SY::AbsoluteMagnitudeMixin
  end

  def same_dimension? other
    case other
    when Numeric then dimensionless?
    else
      dimension == other.dimension
    end
  end

  def default_composition
    ꜧ = dimension.to_hash.each_with_object Hash.new do |pair, ꜧ|
      dim, exp = pair
      ꜧ.merge!( SY.Dimension( dim ).standard_quantity => exp ) if exp.abs > 0
    end
    return SY::Quantity::Composition.new ꜧ
  end

  # Composition of quantities.
  # 
  class Composition
    # Constructor of an empty composition.
    # 
    def self.empty
      new Hash.new
    end

    attr_reader :hash

    def to_hash
      hash
    end

    delegate :empty?, to: :hash
    
    # Takes a hash or equivalent (including another Composition object) and
    # uses it to construct a Composition instance.
    # 
    def initialize composition_hash
      @hash = composition_hash.to_hash.modify do |key, val|
        [ SY.Quantity( key ), Integer( val ) ]
      end.reject { |key, val| val.zero? }
    end

    # Inquirer whether the composition is atomic. Atomic compositions
    # consist of only a single quantity with basic dimension in exponent 1.
    # 
    def atomic?
      return false if @hash.size > 1
      qnt, exp = @hash.first
      return false if exp != 1
      qnt.dimension.basic? || qnt.dimension.zero?
    end

    # Merges two compositions.
    # 
    def merge other
      ç.new( hash.merge( other.to_hash ) { |_, v1, v2| v1 + v2 } )
    end
    
    # Try to simplify the composition by decomposing its quantities.
    # 
    def expand
      return self if atomic?
      ç.new( hash.each.reduce( ç.empty ) { |acc, pair|
               comp, exp = pair
               exp.times.reduce acc do |acc, _| acc.merge comp end
             } )
    end

    # TODO: Over here, quantity factorization will be a problem

    # Compositions compare by their hashes.
    # 
    def == other
      hash == other.hash
    end

    def dimension
      hash.map { |qnt, exp| qnt.dimension * exp }.reduce SY::Dimension.zero, :+
    end
  end
end # class SY::Quantity
