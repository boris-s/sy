#encoding: utf-8

# Quantity.
# 
class SY::Quantity
  include NameMagic

  RELATIVE_QUANTITY_NAME_SUFFIX = "±"

  attr_reader :MagnitudeModule, :Magnitude, :Unit
  attr_reader :dimension, :composition, :relationship

  def MagnitudeModule
    @MagnitudeModule ||= if absolute? then
                           Module.new { include SY::Magnitude }
                         else
                           absolute.MagnitudeModule
                         end
  end

  # Parametrized magnitude class.
  # 
  def Magnitude
    if @Magnitude then @Magnitude else
      mmod = MagnitudeModule()
      mixin = relative? ? SY::SignedMagnitude : SY::AbsoluteMagnitude
      qnt_ɴ_λ = -> { name ? "#{name}@%s" : "#<Quantity:#{object_id}@%s>" }

      @Magnitude = Class.new do
        include mmod
        include mixin

        singleton_class.class_exec do
          define_method :to_s do       # Customized #to_s. It must be a proc,
            qnt_ɴ_λ.call % "Magnitude" # since the quantity owning @Magnitude
          end                          # might not be named yet as of now.
        end
      end
    end
  end

  # Parametrized unit class.
  # 
  def Unit
    @Unit ||= if relative? then absolute.Unit else
                qnt = self
                ɴλ = -> { name ? "#{name}@%s" : "#<Quantity:#{object_id}@%s>" }

                Class.new Magnitude() do # Unit class.
                  include SY::Unit

                  singleton_class.class_exec do
                    define_method :standard do |args={}|      # Customized #standard.
                      @standard ||= new args.merge( quantity: qnt )
                    end
                  
                    define_method :to_s do       # Customized #to_s. (Same consideration
                      qnt_ɴ_λ.call % "Unit"      # as for @Magnitude applies.)
                    end
                  end
                end
              end
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
  end
  
  # Standard constructor of a metrological quantity. A quantity may have
  # a name and a dimension.
  # 
  def initialize args
    puts "init #{args}"
    @relative = args[:relative]
    comp = args[:composition]
    if comp.nil? then # composition not given
      dim = args[:dimension] || args[:of]
      @dimension = SY.Dimension( dim )
    else
      @composition = SY::Quantity::Composition.new( comp )
      @dimension = @composition.dimension
    end
    rel = args[:relationship]
    @relationship = SY::Quantity::Map.new( rel ) if rel
  end

  def composition
    @composition ||= @dimension.to_composition
  end


  def import magnitude2
    q2, amount2 = magnitude2.quantity, magnitude2.amount
    magnitude mapping_to( q2 ).im.( amount2 )
  end
  
  def export amount1, quantity2
    mapping_to( quantity2 ).export( amount1, quantity2 )
  end

  # Asks for a relationship of this quantity to another quantity.
  # 
  def mapping_to q2
    puts "#{self.inspect} asked about mapping to #{q2}" if SY::DEBUG
    return SY::Quantity::Map.identity if q2 == self or q2 == colleague
    raise SY::DimensionError, "#{self} vs. #{q2}!" unless same_dimension? q2
    return q2.mapping_to( self ).inverse if standard? or colleague.standard?
    m1 = begin
           @relationship or
             colleague.relationship or
             composition.infer_relationship
         rescue NoMethodError
           raise SY::QuantityError,"Mapping from #{self} to #{q2} cannot be inferred!"
         end
    return m1 if q2 == standard || q2.colleague == standard
    m1 * standard.mapping_to( q2 )
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
    relative? ? self : colleague
  end

  # For an absolute quantity, colleague is the corresponding relative quantity.
  # Vice-versa, for a relative quantity, colleague is its absolute quantity.
  # 
  def colleague
    @colleague ||= if self == SY::Amount then SY::AmountDifference else
                     puts "#{self} constructing colleague"
                     construct_colleague
                   end
  end

  # Absolute quantity related to this quantity.
  # 
  def absolute
    absolute? ? self : colleague
  end

  # Reader of standard unit.
  # 
  def standard_unit
    Unit().standard
  end

  # Presents an array of units ordered as favored by this quantity.
  # 
  def units
    @units ||= []
  end

  # Constructs a new absolute magnitude of this quantity.
  # 
  def magnitude arg
    Magnitude().new quantity: self, amount: arg
  end

  # Constructs a new unit of this quantity.
  # 
  def unit args={}
    Unit().new( args.merge( quantity: self ) ).tap { |u| ( units << u ).uniq! }
  end

  # Constructor of a new standard unit (replacing the current @standard_unit).
  # For standard units, amount is implicitly 1. So :amount name argument, when
  # supplied, has a different meaning – sets the relationship of its quantity.
  # 
  def new_standard_unit args={}
    explain_amount_of_standard_units if args[:amount].is_a? Numeric # n00b help
    # For standard units, amount has special meaning of setting up relationship.
    args.may_have( :relationship, syn!: :amount )
    rel = args.delete :relationship
    @relationship = SY::Quantity::Map.new( rel ) if rel
    args.update amount: 1 # substitute amount 1 as required for standard units
    # Replace @standard_unit with the newly constructed unit.
    Unit().instance_variable_set( :@standard,
                                 unit( args )
                                   .tap { |u| ( units.unshift u ).uniq! } )
  end

  # Quantity multiplication.
  # 
  def * q2
    puts "#{self.name} * #{q2.name}" if SY::DEBUG
    SY::Quantity::Composition.new( self => 1, q2 => 1 ).to_quantity
  end

  # Quantity division.
  # 
  def / q2
    puts "#{self.name} / #{q2.name}" if SY::DEBUG
    SY::Quantity::Composition.new( self => 1, q2 => -1 ).to_quantity
  end

  # Quantity raising to a number.
  # 
  def ** num
    puts "#{self.name} ** #{num}" if SY::DEBUG
    SY::Quantity::Composition.new( self => num ).to_quantity
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

  # Is the dimension standard?
  # 
  def standard?
    self == standard
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
    puts "in coerce #{other}"
    case other
    when Numeric then
      return SY::Amount, self
    when SY::Quantity then
      # By default, coercion between quantities doesn't exist. The basic
      # purpose of having quantities is to avoid mutual mixing of
      # incompatible magnitudes, as in "one cannot sum pears with apples".
      # 
      if other == self then
        return other, self
      else
        raise SY::QuantityError, "#{other} and #{self} do not mix!"
      end
    else
      raise TErr, "#{self} cannot be coerced into a #{other.class}!"
    end
  end

  private

  def construct_colleague
    puts "#{self} performs #construct_colleague" if SY::DEBUG
    ɴ = name
    ʀsuffix = SY::Quantity::RELATIVE_QUANTITY_NAME_SUFFIX
    rel = relative?
    puts rel ? "#{self} is relative" : "#{self} is absolute"
    constr_named = ->( ɴ, ʀ ) { composition.to_quantity name: ɴ, relative: ʀ }
    constr_anon = ->( ʀ ) { composition.to_quantity relative: ʀ }
    # enough of preliminaries
    if not rel then
      inst = ɴ ? constr_named.( "#{ɴ}#{ʀsuffix}", true ) : constr_anon.( true )
      inst.aT { relative? }
    elsif ɴ.to_s.ends_with?( ʀsuffix ) && ɴ.size > ʀsuffix.size
      inst = constr_named.( ɴ.to_s[0..ɴ.size-ʀsuffix.size-1], false )
      inst.aT { absolute? }
    else inst = constr_anon.( false ).aT { absolute? } end
    inst.instance_variable_set :@colleague, self
    return inst
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

  # Represents relationship of two quantities. Provides import and export
  # conversion closures. Instances are immutable and have 2 attributes:
  #
  # * im - import closure, converting amount of quantity 1 into quantity 2
  # * ex - export closure, converting amount of quantity 2 into quantity 1
  #
  # Convenience methods for mapping magnitudes are:
  # 
  # * import - like im, but operates on magnitudes
  # * export - like ex, but operates on magnitudes
  # 
  class Map
    class << self
      def identity
        new 1
      end
    end

    attr_reader :ex, :im, :ratio

    # Takes either a magnitude (1 argument), or 2 named arguments :im, :ex
    # speficying amount import and export closure. For a magnitude, these
    # closures are constructed automatically, assuming simple ratio rule.
    # 
    def initialize arg
      case arg
      when Hash then
        @ex, @im = arg[:ex], arg[:im]
      else
        @ratio = r = arg
        @ex = lambda { |amount1| amount1 * r }
        @im = lambda { |amount2| amount2 / r }
      end
    end

    def import magnitude, from_quantity
      from_quantity.magnitude @im.( magnitude.amount )
    end

    def export magnitude, to_quantity
      to_quantity.magnitude @ex.( magnitude.amount )
    end

    def inverse
      self.class.new begin
                       1 / @ratio
                     rescue NoMethodError, TypeError
                       i, e = im, ex
                       { im: e, ex: i } # swap closures
                     end
    end

    def * r2 # mapping composition
      ç.new begin
              @ratio * r2.ratio
            rescue NoMethodError, TypeError
              i1, i2, e1, e2 = im, r2.im, ex, r2.ex
              { ex: lambda { |a1| e2.( e1.( a1 ) ) }, # export compose
                im: lambda { |a2| i1.( i2.( a2 ) ) } } # import compose
            end
    end

    def / r2
      self * r2.inverse
    end

    def ** n
      ç.new begin
              n == 1 ? @ratio * 1 : @ratio ** n
            rescue NoMethodError, TypeError
              i, e = im, ex
              { ex: lambda { |a1| n.times.reduce a1 do |m, _| e.( m ) end },
                im: lambda { |a2| n.times.reduce a2 do |m, _| i.( m ) end } }
            end
    end

    protected

    def []( *args ); send *args end
  end

  # Composition of quantities.
  # 
  class Composition
    class << self
      alias __new__ new

      # The #new constructor of Composition is being changed to always
      # return same instance, if instance with that hash as already been
      # created.
      # 
      def new arg
        puts "Composition#new( #{arg.to_hash.with_keys &:name} )" if SY::DEBUG
        ꜧ = case arg
            when self then return arg
            else arg end
        # Let's see whether the instance already exists.
        return instances.find { |inst| inst.to_hash == ꜧ } ||
          __new__( ꜧ ).tap { |inst| instances << inst }
      end

      # Presents class-owned instances (array).
      # 
      def instances
        return @instances ||= []
      end

      # Constructor of an empty composition.
      # 
      def empty
        new Hash.new
      end

      # Cache for quantity construction.
      # 
      def quantity_table
        @quantity_table ||= Hash.new { |ꜧ, args|
          puts "constructing #{args}" if SY::DEBUG
          if args.has? :name, syn!: :ɴ then
            ɴ = args.delete :name
            ꜧ[args].tap { |ɪ| ɪ.name = ɴ }
          else
            comp = args[ :composition ]
            rel = args[ :relative ]
            ꜧ[args] = if comp.empty? then
                        rel ? SY::AmountDifference : SY::Amount
                      elsif comp.size == 1 && comp.first[1] == 1 then
                        ɪ = comp.first[0]
                        if rel then
                          if ɪ.relative? then ɪ else
                            if ɪ.instance_variable_get :@colleague then ɪ.colleague else
                              SY::Quantity.new args
                            end
                          end
                        else
                          if ɪ.absolute? then ɪ else
                            if ɪ.instance_variable_get :@colleague then ɪ.colleague else
                              SY::Quantity.new args
                            end
                          end
                        end
                      else
                        SY::Quantity.new args
                      end
          end
        }
      end
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
      @hash = composition_hash.to_hash.modify do |qnt, exp|
        [ qnt, Integer( exp ) ]
      end
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

    def simplify
      puts "simplifying #{hash}" if SY::DEBUG
      ꜧ = hash.dup
      begin
        ꜧ_old = ꜧ.dup
        SY::QUANTITY_SIMPLIFICATION_RULES.each { |rule| rule.( ꜧ ) }
      end while ꜧ != ꜧ_old
      puts "result is #{ꜧ}" if SY::DEBUG
      return ç.new ꜧ
    end

    def to_quantity args={}
      rel = args.delete :relative
      ꜧ = simplify.hash
      ç.quantity_table[ args.merge( composition: simplify.to_hash,
                                    relative: rel ? true : false ) ]
    end

    def infer_relationship
      puts "#infer_relationship; hash is #{hash}" if SY::DEBUG
      hash.map do |qnt, exp|
        if qnt.standard? or qnt.colleague.standard? then
          SY::Quantity::Map.identity
        else
          mapping = qnt.mapping_to( qnt.standard )
          puts "mapping ratio is #{mapping.ratio}" if SY::DEBUG
          mapping = mapping ** exp
          puts "with exponent, #{mapping.ratio}" if SY::DEBUG
          mapping
        end
      end.reduce( SY::Quantity::Map.identity, :* )
      # raise SY::QuantityError,
      #       "Unable to infer composed relationship of #{self}!"
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
