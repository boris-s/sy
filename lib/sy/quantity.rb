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
  attr_reader :dimension, :composition, :units

  class << self
    # Dimension-based quantity constructor. Examples:
    # <tt>Quantity.of Dimension.new( "L.T⁻²" )</tt>
    # <tt>Quantity.of "L.T⁻²"</tt>
    # 
    def of *args
      ꜧ = args.extract_options!
      dim = case args.size
            when 0 then
              ꜧ.must_have :dimension
              ꜧ.delete :dimension
            else args.shift end
      args << ꜧ.merge!( of: SY::Dimension.new( dim ) )
      return new( *args ).protect!
    end
    
    # Standard quantity. Example:
    # <tt>Quantity.standard of: Dimension.new( "L.T⁻²" )</tt>
    # or
    # <tt>Quantity.standard of: "L.T⁻²"
    # (Both should give Acceleration as their result.)
    # 
    def standard( of: nil )
      fail ArgumentError, "Dimension (:of argument) must be given!" if of.nil?
      puts "Constructing standard quantity of #{of} dimension" if SY::DEBUG
      return SY.Dimension( of ).standard_quantity
    end

    # Dimensionless quantity constructor alias.
    # 
    def dimensionless *args
      ꜧ = args.extract_options!
      raise TErr, "Dimension not zero!" unless ꜧ[:dimension].zero? if
        ꜧ.has? :dimension, syn!: :of
      new( *( args << ꜧ.merge!( of: SY::Dimension.zero ) ) ).protect!
    end
    alias :zero :dimensionless
  end

  # Standard constructor of a metrological quantity. A quantity may have
  # a name and a dimension.
  # 
  def initialize( relative: nil,
                  composition: nil,
                  of: nil,
                  measure: nil,
                  amount: nil,
                  coerces: [],
                  coerces_to: [],
                  **nn )
    puts "Quantity init relative: #{relative}, composition: #{composition}, measure: #{measure}, #{nn}" if SY::DEBUG
    @units = [] # array of units as favored by this quantity
    @relative = relative
    if composition.nil? then
      puts "Composition not given, dimension expected." if SY::DEBUG
      @dimension = SY.Dimension( of )
    else
      puts "Composition received (#{composition})." if SY::DEBUG
      @composition = SY::Composition[ composition ]
      @dimension = @composition.dimension
    end
    @measure = measure.is_a?( SY::Measure ) ? measure :
      if measure.nil? then
        if amount.nil? then nil else
          SY::Measure.simple_scale( amount )
        end
      else
        fail ArgumentError, ":amount and :measure shouldn't be both supplied" unless amount.nil?
        SY::Measure.simple_scale( measure )
      end
    coerces( *Array( coerces ) )
    Array( coerces_to ).each { |qnt| qnt.coerces self }
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

  # Quantities explicitly coerced by this quantity.
  # 
  def coerces *other_quantities
    if other_quantities.empty? then @coerces ||= [] else
      other_quantities.each { |qnt| coerces << qnt }
    end
  end

  # Is the quantity supplied as the argument coerced by this quantity?
  # 
  def coerces? other
    other == self || coerces.include?( other ) ||
      colleague.coerces.include?( other.colleague ) ||
      if simple? then false else
        composition.coerces? other.composition
      end
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

  # Acts as setter of measure (of the pertinent standard quantity).
  # 
  def set_measure measure
    @measure = if measure.is_a?( SY::Measure ) then
                 measure
               else
                 SY::Measure.simple_scale( measure )
               end
  end

  # Converts magnitude of another quantity to a magnitude of this quantity.
  # 
  def read magnitude_of_other_quantity
    other_quantity = magnitude_of_other_quantity.quantity
    other_amount = magnitude_of_other_quantity.amount
    magnitude measure( of: other_quantity ).r.( other_amount )
  end

  # Converts an amount of this quantity to a magnitude of other quantity.
  # 
  def write amount_of_this_quantity, other_quantity
    measure( of: other_quantity )
      .write( magnitude( amount_of_this_quantity ), other_quantity )
  end

  # Creates a measure of a specified other quantity. If no :of is specified,
  # simply acts as a getter of @measure attribute.
  # 
  def measure( of: nil )
    return @measure if of.nil? # act as simple getter if :of not specified
    puts "#{self.inspect} asked about measure of #{of}" if SY::DEBUG
    return SY::Measure.identity if of == self or of == colleague
    raise SY::DimensionError, "#{self} vs. #{of}!" unless same_dimension? of
    return of.measure( of: of.standard ).inverse if standardish?
    m = begin
          puts "composition is #{composition}, class #{composition.class}" if SY::DEBUG
          measure ||
            colleague.measure ||
            composition.infer_measure
        rescue NoMethodError
          fail SY::QuantityError, "Measure of #{of} by #{self} impossible!"
        end
    return m if of.standardish?
    puts "#{of} not standardish, obtained measure relates to #{standard}, and " +
      "it will have to be extended to #{of}." if SY::DEBUG
    return m * standard.measure( of: of )
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
    if measure && q2.measure then
      raise SY::QuantityError, "Measure mismatch: #{self}, #{q2}!" unless
        measure == q2.measure
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

  # Constructs a absolute magnitude of this quantity.
  # 
  def magnitude amount
    puts "Constructing #{self}#magnitude with amount #{amount}." if SY::DEBUG
    Magnitude().new( of: self, amount: amount )
      .tap { puts "#{self}#magnitude constructed!" if SY::DEBUG }
  end

  # Constructs a new unit of this quantity.
  # 
  def unit **nn
    Unit().new( nn.update( of: self ) )
      .tap { |u| ( units << u ).uniq! } # add it to the @units array
  end

  # Constructor of a new standard unit (replacing current @standard_unit).
  # For standard units, amount is implicitly 1. So :amount argument here has
  # different meaning – it sets the measure of the quantity. Measure can also
  # be specified more explicitly by :measure named argument.
  # 
  def new_standard_unit( amount: nil, measure: nil, **nn )
    explain_amount_of_standard_units if amount.is_a? Numeric # n00b help
    # For standard units, amount has special meaning of setting up mapping.
    if measure then
      raise ArgumentError, "When :measure is specified, :amount must not be " +
        "expliticly specified." unless amount.nil?
      raise TypeError, ":measure argument must be a SY::Measure!" unless
        measure.is_a? SY::Measure
      set_measure( measure )
    else
      set_measure( SY::Measure.simple_scale( amount.nil? ? 1 : amount.amount ) )
    end
    # Replace @standard_unit with the newly constructed unit.
    Unit().instance_variable_set( :@standard,
                                  unit( **nn ).tap do |u|
                                    ( units.unshift u ).uniq!
                                  end )
  end

  # Quantity multiplication.
  # 
  def * q2
    puts "#{self.name} * #{q2.name}" if SY::DEBUG
    rel = [ self, q2 ].any? &:relative
    ( SY::Composition[ self => 1 ] + SY::Composition[ q2 => 1 ] )
      .to_quantity relative: rel
  end

  # Quantity division.
  # 
  def / q2
    puts "#{self.name} / #{q2.name}" if SY::DEBUG
    rel = [ self, q2 ].any? &:relative?
    ( SY::Composition[ self => 1 ] - SY::Composition[ q2 => 1 ] )
      .to_quantity relative: rel
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
    puts "Dimension of this quantity is #{dimension}" if SY::DEBUG
    puts "Its standard quantity is #{dimension.standard_quantity}" if SY::DEBUG
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
    "#<Quantity:#{to_s}>"
  end

  def coerce other
    case other
    when Numeric then
      return SY::Amount.relative, self
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
    puts "#{self}#MagnitudeModule called" if SY::DEBUG
    @MagnitudeModule ||= if absolute? then
                           Module.new { include SY::Magnitude }
                         else
                           absolute.MagnitudeModule
                         end
  end

  # Parametrized magnitude class.
  # 
  def Magnitude
    puts "#{self}#Magnitude called" if SY::DEBUG
    @Magnitude or
      ( puts "Constructing #{self}@Magnitude parametrized class" if SY::DEBUG
        mmod = MagnitudeModule()
        mixin = relative? ? SY::SignedMagnitude : SY::AbsoluteMagnitude
        qnt_ɴ_λ = -> { name ? "#{name}@%s" : "#<Quantity:#{object_id}@%s>" }

        @Magnitude = Class.new do
          include mmod
          include mixin

          singleton_class.class_exec do
            define_method :zero do       # Costructor of zero magnitudes
              new amount: 0
            end

            define_method :to_s do       # Customized #to_s. It must be a proc,
              qnt_ɴ_λ.call % "Magnitude" # since the quantity owning @Magnitude
            end                          # might not be named yet as of now.
          end
        end )
  end

  # Parametrized unit class.
  # 
  def Unit
    puts "#{self}#Unit called" if SY::DEBUG
    @Unit ||= ( puts "Constructing #{self}@Unit parametrized class" if SY::DEBUG
                if relative? then absolute.Unit else
                  qnt = self
                  ɴλ = -> { name ? "#{name}@%s" : "#<Quantity:#{object_id}@%s>" }
                  
                  Class.new Magnitude() do puts "Creating @Unit class!" if SY::DEBUG
                    include SY::Unit; puts "Included SY::Unit" if SY::DEBUG
                    
                    singleton_class.class_exec do
                      define_method :standard do |**nn|      # Customized #standard.
                        puts "parametrized #{qnt}@Unit#standard called" if SY::DEBUG
                        @standard ||= new **nn.update( of: qnt )
                      end
                      
                      define_method :to_s do       # Customized #to_s. (Same consideration
                        ɴλ.call % "Unit"           # as for @Magnitude applies.)
                      end
                    end
                  end.namespace! SY::Unit
                end ).tap do |u|
      puts "@Unit constructed, its namespace is #{u.namespace}" if SY::DEBUG
      puts "its instances are #{u.namespace.instances}" if SY::DEBUG
      puts "its instance names are #{u.namespace.instance_names}" if SY::DEBUG
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
    raise TypeError, "For standard units, :amount is 1, by definition. When" +
      ":amount parameter is supplied to a standard unit constructor, its" +
      "meaning is different: Using a magnitude of the same dimension, but" +
      "different quantity, it establishes conversion relationship between" +
      "the two quantities."
  end
end # class SY::Quantity
