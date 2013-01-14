#encoding: utf-8

# Quantity.
# 
class SY::Quantity
  include NameMagic

  # name_set_closure do |name, new_instance, old_name|
  #   new_instance.protect!; name
  # end

  RELATIVE_QUANTITY_NAME_SUFFIX = "±"

  attr_reader :MagnitudeModule, :Magnitude, :Unit
  attr_reader :dimension, :composition, :mapping

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
      return new( *args ).protect!
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
      new( *( args << ꜧ.merge!( dimension: SY::Dimension.zero ) ) ).protect!
    end
  end

  # Standard constructor of a metrological quantity. A quantity may have
  # a name and a dimension.
  # 
  def initialize args
    puts "Quantity init #{args}" if SY::DEBUG
    @relative = args[:relative]
    comp = args[:composition]
    if comp.nil? then # composition not given
      puts "Composition not received, dimension expected." if SY::DEBUG
      dim = args[:dimension] || args[:of]
      @dimension = SY.Dimension( dim )
    else
      puts "Composition received (#{comp})." if SY::DEBUG
      @composition = SY::Composition[ comp ]
      @dimension = @composition.dimension
    end
    rel = args[:mapping] || args[:ratio]
    @mapping = SY::Mapping.new( rel ) if rel
    puts "Composition of the initialized instance is #{composition}." if SY::DEBUG
  end

  # Simple quantity is one with simple composition. If nontrivial composition
  # is known for the colleague, it is assumed that the same composition would
  # apply for this quantity, so it is not simple.
  # 
  def simple?
    cᴍ = composition
    cᴍ.empty? || cᴍ.singular? && cᴍ.first[0] == self
  end

  # Protected quantity is not allowed to be decomposed in the process of quantity
  # simplification.
  # 
  def protected?
    @protected
  end

  # Protects quantity from decomposition.
  # 
  def protect!
    @protected = true
    @composition ||= SY::Composition.singular self
    return self
  end

  # Unprotects quantity from decomposition.
  # 
  def unprotect!
    @protected = false
    @composition = nil if @composition == SY::Composition.singular( self )
    return self
  end

  # Irreducible quantity is one which cannot or <em>should not</em> be reduced
  # to its components in the process of quantity simplification.
  # 
  def irreducible?
    simple? or protected?
  end

  # Creates a composition from a dimension, or acts as composition getter
  # if this has already been specified.
  # 
  def composition
    @composition || dimension.to_composition
  end

  # Acts as composition setter (dimension must match).
  # 
  def set_composition comp
    @composition = SY::Composition[ comp ]
      .aT "composition, when redefined after initialization,",
          "match the dimension" do |comp| comp.dimension == dimension end
  end

  # Acts as mapping setter.
  # 
  def set_mapping mapping
    @mapping = SY::Mapping.new( mapping )
  end

  def import magnitude2
    quantity2, amount2 = magnitude2.quantity, magnitude2.amount
    magnitude mapping_to( quantity2 ).im.( amount2 )
  end

  def export amount1, quantity2
    mapping_to( quantity2 ).export( magnitude( amount1 ), quantity2 )
  end

  # Asks for a mapping of this quantity to another quantity.
  # 
  def mapping_to( q2 )
    puts "#{self.inspect} asked about mapping to #{q2}" if SY::DEBUG
    return SY::Mapping.identity if q2 == self or q2 == colleague
    puts "this mapping is not an identity" if SY::DEBUG
    raise SY::DimensionError, "#{self} vs. #{q2}!" unless same_dimension? q2
    if standardish? then
      puts "#{self} is a standardish quantity, will invert the #{q2} mapping" if SY::DEBUG
      return q2.mapping_to( self ).inverse
    end
    puts "#{self} is not a standardish quantity" if SY::DEBUG
    m1 = begin
           if @mapping then
             puts "#{self} has @mapping defined" if SY::DEBUG
             @mapping
           elsif colleague.mapping then
             puts "#{colleague} has @mapping defined" if SY::DEBUG
             colleague.mapping
           else
             puts "Neither #{self} nor its colleague has @mapping defined" if SY::DEBUG
             puts "Will ask #{self}.composition to infer the mapping" if SY::DEBUG
             composition.infer_mapping
           end
         rescue NoMethodError
           raise SY::QuantityError,"Mapping from #{self} to #{q2} cannot be inferred!"
         end
    if q2.standardish? then
      puts "#{q2} is standardish, obtained mapping can be returned directly." if SY::DEBUG
      return m1
    else
      puts "#{q2} not standardish, obtained mapping maps only to #{standard}, and " +
        "therefrom, composition with mapping from #{standard} to #{q2} will be needed" if SY::DEBUG
      return m1 * standard.mapping_to( q2 )
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
    @colleague ||= construct_colleague
  end

  # Acts as colleague setter.
  # 
  def set_colleague q2
    raise SY::DimensionError, "Mismatch: #{self}, #{q2}!" unless
      same_dimension? q2
    raise SY::QuantityError, "#{self} an #{q2} are both " +
      "{relative? ? 'relative' : 'absolute'}!" if relative? == q2.relative?
    if mapping && q2.mapping then
      raise SY::QuantityError, "Mapping mismatch: #{self}, #{q2}!" unless
        mapping == q2.mapping
    end
    @colleague = q2
    q2.instance_variable_set :@colleague, self
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
  # supplied, has a different meaning – sets the mapping of its quantity.
  # 
  def new_standard_unit args={}
    explain_amount_of_standard_units if args[:amount].is_a? Numeric # n00b help
    # For standard units, amount has special meaning of setting up mapping.
    args.may_have( :mapping, syn!: :amount )
    ᴍ = args.delete( :mapping )
    set_mapping( ᴍ.amount ) if ᴍ
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
    rel = [ self, q2 ].any? &:relative
    SY::Composition[ self => 1, q2 => 1 ].to_quantity relative: rel
  end

  # Quantity division.
  # 
  def / q2
    puts "#{self.name} / #{q2.name}" if SY::DEBUG
    rel = [ self, q2 ].any? &:relative?
    SY::Composition[ self => 1, q2 => -1 ].to_quantity relative: rel
  end

  # Quantity raising to a number.
  # 
  def ** num
    puts "#{self.name} ** #{num}" if SY::DEBUG
    SY::Composition[ self => num ].to_quantity relative: relative?
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

  # Is the dimension or its colleague standard?
  # 
  def standardish?
    standard? || colleague.standard?
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

  protected

  # Main parametrized (ie. quantity-specific) module for magnitudes.
  # 
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

  private

  def construct_colleague
    puts "#{self}#construct_colleague" if SY::DEBUG
    ɴ = name
    ʀsuffix = SY::Quantity::RELATIVE_QUANTITY_NAME_SUFFIX
    rel = relative?
    puts "#{self} is #{rel ? 'relative' : 'absolute'}" if SY::DEBUG
    # Here, it is impossible to rely on Composition::QUANTITY_TABLE –
    # on the contrary, the table relies on Quantity#colleague.
    constr_ɴ = ->( ɴ, ʀ ) { ç.new composition: composition, ɴ: ɴ, relative: ʀ }
    constr_anon = ->( ʀ ) { ç.new composition: composition, relative: ʀ }
    # enough of preliminaries
    if not rel then
      inst = ɴ ? constr_ɴ.( "#{ɴ}#{ʀsuffix}", true ) : constr_anon.( true )
      inst.aT { relative? }
    elsif ɴ.to_s.ends_with?( ʀsuffix ) && ɴ.size > ʀsuffix.size
      inst = constr_ɴ.( ɴ.to_s[0..ɴ.size-ʀsuffix.size-1], false )
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
end # class SY::Quantity
