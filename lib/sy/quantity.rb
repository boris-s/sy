#encoding: utf-8

# Quantity.
# 
class SY::Quantity
  include NameMagic
  attr_reader :dimension, :Magnitude, :Unit, :composition, :relationship

  # The keys of this hash are unary or binary mathematical operations on
  # quantities. They are stored as and array, whose 1st element is the
  # operator method, and the rest are the operands (eg. [ :/, Length, Time ],
  # translated as Length / Time, aka. Speed).
  # 
  OPERATION_TABLE = Hash.new { |ꜧ, missing_key|
    case missing_key
    when SY::Quantity::Composition then
      missing_key.simplify.to_quantity
    else
      begin
        operator = missing_key.shift.to_sym         # +, -, *, / ...
        operands = missing_key.map { |e|            # Length, Time, Mass ...
          SY::Quantity::Composition.new e => 1
        }
      rescue NoMethodError
        nil
      else
        ꜧ[missing_key] = operator.to_proc.call( *operands )
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
    args.may_have :relative        # relative quantity vs. absolute quantity
    args.may_have :composition     # quantity composition from other quantities
    args.may_have :dimension, syn!: :of
    args.may_have :relationship    # rel. to a chosen equidimensional qnt
    @relative = args[:relative]
    @dimension, @composition = init_dimension_and_composition( args )
    @relationship = init_relationship( args )
    @Magnitude, @Unit = prepare_parametrized_magnitude_and_unit_class
  end

  def composition
    @composition ||= @dimension.to_composition
  end

  # Is the quantity relative?
  #
  def relative?
    @relative ? true : false
  end

  # Is the quantity absolute? (Opposite of #relative?)
  # 
  def absolute?
    not relative?
  end

  # Relative quantity related to this quantity.
  # 
  def relative
    @relative_quantity ||= relative? ? self : construct_relative_quantity
  end

  # Relative quantity setter.
  # 
  def relative_quantity= qnt
    @relative_quantity = qnt
  end

  # Absolute quantity related to this quantity.
  # 
  def absolute
    @absolute_quantity ||= absolute? ? self : construct_absolute_quantity
  end

  # Absolute quantity setter.
  # 
  def absolute_quantity= qnt
    @absolute_quantity = qnt
  end

  # Reader of standard unit.
  # 
  def standard_unit args={}
    @standard_unit ||= unit args
  end

  # Presents an array of units ordered as favored by this quantity.
  # 
  def units
    @units ||= []
  end

  # Constructs a new absolute magnitude of this quantity.
  # 
  def magnitude arg
    @Magnitude.new quantity: self, amount: arg
  end

  # Constructs a new unit of this quantity.
  # 
  def unit args={}
    @Unit.new( args.merge( quantity: self ) ).tap { |u| ( units << u ).uniq! }
  end

  # Constructor of a new standard unit (replacing the current @standard_unit).
  # For standard units, amount is implicitly 1. So :amount name argument, when
  # supplied, has a different meaning – sets the relationship of its quantity.
  # 
  def new_standard_unit args={}
    # Newbie help.
    explain_amount_of_standard_units if args[:amount].is_a? Numeric
    # For standard units, :amount has special meaning of :relationship.
    args.may_have :relationship, syn!: :amount
    # Call private method to take care of :relationship arg.
    init_relationship( args )
    # Remove now unneeded :relationship named argument
    args.delete :relationship
    # and substitue amount 1 as required for standard units.
    args.update amount: 1
    # Replace @standard_unit with the newly constructed unit.
    @standard_unit = unit( args ).tap { |u| ( units.unshift u ).uniq! }
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
      self.class
        .new dimension: dimension, relative: true, name: "#{name}Difference"
    else
      self.class.new dimension: dimension, relative: true
    end
  end

  def construct_absolute_quantity
    if relative? and
        name && name.to_s.ends_with?( "Difference" ) and
        not ( stripped = name[0..("Difference".size - 1)] ).empty? then
      self.class.new dimension: dimension, relative: false, name: stripped
    else
      self.class.new dimension: dimension, relative: false
    end
  end

  def same_dimension? other
    dimension == other.dimension
  end

  def explain_amount_of_standard_units
    raise TErr, "The amount of standard units is, by definition, 1. When " +
      ":amount named parameter fis supplied to the construtor of a " +
      "standard unit, it has different meaning: It must be given as " +
      "a magnitude of another quantity of the same dimension, and it " +
      "establishes relationship between this and the other quantity."
  end

  def init_dimension_and_composition ꜧ
    case tentative_cmp = ꜧ[:composition]
    when nil then
      dim = SY.Dimension( ꜧ.must_have :dimension, syn!: :of )
      cmp = nil
    else
      cmp = SY::Quantity::Composition.new( tentative_cmp )
      dim = cmp.dimension
    end
    return dim, cmp
  end

  def init_relationship ꜧ
    rel = ꜧ[:relationship]
    SY::Quantity::Relationship.new( self, rel ) if rel
  end

  def prepare_parametrized_magnitude_and_unit_class
    mç = Class.new do include SY::Magnitude end # magnitude class
    uç = Class.new mç do include SY::Unit end # unit class
    mixin = relative? ? SY::SignedMagnitude : SY::AbsoluteMagnitude
    mç.class_exec { include mixin }
    qnλ = lambda { name ? "#{name}@%s" : "#<Quantity:#{object_id}@%s>" }
    mç.singleton_class               # customized to_s
      .class_exec { define_method :to_s do qnλ.call % "Magnitude" end }
    uç.singleton_class               # customized to_s
      .class_exec { define_method :to_s do qnλ.call % "Unit" end }
    return mç, uç
  end

  # Relationship of quantities. Provides import and export closures to convert
  # a quantity into another quantity.
  #
  # A relationship instance is immutable, has 4 important attributes and 2 more
  # attributes supplying convenience closures. The 4 important attributes are:
  #
  # * quantity - source quantity in a relationship
  # * other_quantity - target quantity in a relationship
  # * im - import closure, converting amount of other_quantity into quantity
  # * ex - export closure, converting amount in quantity into other_quantity
  #
  # The 2 convenience closures are:
  # 
  # * import - like im, but operates on magnitudes
  # * export - like ex, but operates on magnitudes
  # 
  class Relationship
    attr_reader :quantity, :other_quantity, :ex, :im, :export, :import

    # Standard constructor takes 2 arguments: Source quantity and relationship
    # specification. The relationship specification may be a magnitude of a
    # different, but equidimensional quantity, in which case import and export
    # closures are constructed using ratio specified by the magnitude, with
    # no offset. The relationship specification may also be given explicitly,
    # as hash of 3 named arguments: :other_quantity, :export, and :import
    # (the latter 2 specifying export and import closure). If relationship
    # specification is itself a Relationship instance, its other_quantity,
    # and import/export closures are simply used without any change.
    # 
    def initialize qnt, relspec
      # This quantity:
      @quantity = qnt
      # Prepare @other_quantity and @im / @ex closures.
      case relspec
      when SY::Magnitude then init_from_magnitude( relspec )
      when SY::Quantity::Relationship then init_from_relationship( relspec )
      else init_from_hash( relspec ) end
      # Prepare @import and @export closures.
      prepare_import_and_export_closures
    end

    private

    def init_from_magnitude m
      @other_quantity = m.quantity.aT_not_equal( @quantity )
      ratio = m.amount
      @ex = lambda { |amount1| amount1 / ratio }
      @im = lambda { |amount2| amount2 * ratio }
    end

    def init_from_relationship rel
      @other_quantity, @ex, @im = rel.other_quantity, rel.ex, rel.im
    end

    def init_from_hash ꜧ
      @other_quantity, @ex, @im = ꜧ[:other_quantity], ꜧ[:ex], ꜧ[:im]
    end

    def prepare_import_and_export_closures
      @export = lambda { |mgn1| @other_quantity.magnitude @ex.( mgn1.amount ) }
      @import = lambda { |mgn2| @quantity.magnitude @im.( mgn2.amount ) }
    end
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
    def + other
      self.class.new( hash.merge( other.to_hash ) { |_, v1, v2| v1 + v2 } )
    end
    alias :merge :+

    # Subtracts two compositions.
    # 
    def - other
      self.class.new( hash.merge( other.to_hash ) { |_, v1, v2| v1 - v2 } )
    end

    # Multiplication by a number.
    # 
    def * number
      self.class.new( hash.with_values do |v| v * number end )
    end

    # Division by a number.
    # 
    def / number
      self.class.new( hash.with_values do |val|
                        raise TErr, "Compositions with rational exponents " +
                          "not implemented!" if val % number != 0
                        val / number
                      end )
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
    def simplify
      self
    end

    def to_quantity
      ꜧ = self.class.instance_variable_get( :@quantity ) ||
        ç.instance_variable_set( :@quantity,
                                 Hash.new { |ꜧ, key|
                                   case key
                                   when Hash then
                                     ꜧ[key] = SY::Quantity.compose key
                                   else
                                     ꜧ[key.to_hash]
                                   end
                                 } )
      ꜧ[self]
    end

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
