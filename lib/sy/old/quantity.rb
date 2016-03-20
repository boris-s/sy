#encoding: utf-8

require_relative 'quantity/composition'
require_relative 'quantity/measure'

# Metrological quantity. A quantity object consists of a dimension and its
# physical meaning and usage context. Dimensions have their standard quantities
# (eg. dimension +L+ has +SY::Length+, dimension +L.T⁻¹+ has +SY::Speed+), but
# there can be many quantities of the same dimension.
#
# Metrological quantities are best introduced by examples: Consider +SY::Amount+
# and +SY::MoleAmount+, which both are dimensionless quantities, but
# +SY::MoleAmount+ is measured in moles. We can use +SY+ to define a quantity
# +DozenAmount+, which is also dimensionless, but mesures things in dozens.
# All of these have the same dimension (∅), but they differ in scale.
# 
# Even if the quantities do not differ in scale, they can differ in meaning and
# usage context. For example, entropy has the same dimension and scale as thermal
# capacity, but its meaning is different. For a daily life example, we can define
# a custom quantity +RoadDistance+ with dimension and scale same as +SY::Length+,
# but having meaning of road distance travelled by a vehicle. If we then define
# +FuelConsumption+ as <tt>SY::Volume / RoadDistance</tt>, +SY+ will know that
# eg. dividing volume by a magnitude of +FuelConsumption+ returns a magnitude of
# +RoadDistance+ rather than just +SY::Length+. One more example, litre volume
# (+SY::Volume+) has specific usage (in chemistry etc.) different from the
# "ordinary" volume used in physics (<tt>SY::Length ** 3</tt>) and measured in
# +m³+. One more example, +SY::CelsiusTemperature+ measured in +°C+ has differs
# from +SY::Temperature+ measured in +K+ by an offset of +273.15.K+, and has
# entirely different usage habits.
#
# In sum, formalizing the concept of quantity is no simple task. +SY::Quantity+
# is no more complex, than necessitated by this task. Its understanding is the
# key to mastering +SY+.
#
# Formally, the main attributes of a quantity instance are its dimension
# (SY::Dimension), and a group of other attributes that govern its behavior:
# 
# * relative -- Absolute / relative quantity. (Absolute quantities can't have
#               negative magnitudes.) Absolute and relative version of the same
#               quantity are called <em>counterparts</em>.
# * composition -- Quantity defined as a composition of other quanitities.
# * measure -- Conversion rules w.r. to the standard quantity of the dimension.
# 
#              
# 
class SY::Quantity
  include NameMagic # NameMagic from YSupport

  # name_set_hook do |name, new_instance, old_name|
  #   new_instance.protect!; name
  # end

  RELATIVE_SUFFIX = "±"

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

    # Convenience constructor for dimensionless quantities.
    # 
    def dimensionless *args
      hsh = args.extract_options!
      fail TypeError, "Dimension not zero!" unless hsh[:dimension].zero? if
        hsh.has? :dimension, syn!: :of
      args << hsh.merge!( of: SY::Dimension.zero )
      new( *args ).protect!
    end
    alias :zero :dimensionless
  end

  # Standard constructor of a quantity.
  # 
  def initialize( of: nil,           # dimension
                  relative: nil,     # absolute / relative quantity
                  composition: nil,  # quantity may be given as a composition
                  measure: nil,      # optional measure vs. standard quantity
                  amount: nil,       # measure may be given as amount
                  coerces: [],       # quantities coerced into this quantity
                  coerces_to: [],    # quantities to which this quantity coerces
                  **nn )
    puts "Constructing a quantity." if SY::DEBUG
    # Setting up @Magnitude parametrized subclass:
    param_class!( { Magnitude: SY::Magnitude }, with: { quantity: self } )
    @relative = relative
    # Extending Magnitude() class with appropriate mixin and Unit() class setup:
    if relative? then
      Magnitude().extend SY::Magnitude::Relative
      def Unit; absolute.Unit end # take it from the absolute counterpart
    else
      Magnitude().extend SY::Magnitude::Absolute
      set_up_Unit_class
    end
    if composition.nil? then
      puts "Composition not given, dimension expected." if SY::DEBUG
      @dimension = SY.Dimension( of )
    else
      puts "Composition received (#{composition})." if SY::DEBUG
      @composition = SY::Composition[ composition ]
      @dimension = @composition.dimension
      fail ArgumentError, "Supplied dimension (#{of}) does not match the " +
        "supplied composition (#{composition})!" unless
        @dimension == SY.Dimension( of ) unless of.nil?
    end
    @measure = if measure.is_a? Measure then measure else
                 if measure.nil? then
                   amount.nil? ? nil : Measure.simple_scaling( amount )
                 else # measure argument will be treated as a scale factor
                   fail ArgumentError, ":amount and :measure shouldn't be " +
                     "both supplied at the same time!" unless amount.nil?
                   Measure.simple_scale( measure )
                 end
               end
    coerces( *Array( coerces ) ) # self coerces the coercees
    Array( coerces_to ).each { |qnt| qnt.coerces self } # coercers coerce self
    puts "Compos. of the initialized qnt. is #{composition}." if SY::DEBUG
    puts "Initialized qnt. is #{relative? ? :relative : :absolute}" if SY::DEBUG
    puts "Initialized qnt. object_id is #{object_id}" if SY::DEBUG
  end

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


        mixin = relative? ? SY::SignedMagnitude : SY::AbsoluteMagnitude
        qnt_ɴ_λ = -> { name ? "#{name}@%s" : "#<Quantity:#{object_id}@%s>" }

        qnt = self
        @Magnitude = Class.new do
          include mmod
          include mixin

          singleton_class.class_exec do
            define_method :zero do       # Costructor of zero magnitudes
              new amount: 0, of: qnt
            end

            define_method :one do        # Constructor of unitary magnitudes
              new amount: 1, of: qnt
            end

            define_method :to_s do       # Customized #to_s. It must be a proc,
              qnt_ɴ_λ.call % "Magnitude" # since the quantity owning @Magnitude
            end                          # might not be named yet as of now.
          end
        end )
  end



  # Simple quantity is one with simple composition. If nontrivial composition
  # is known for the counterpart, it is assumed that the same composition holds
  # for this quantity (meaning it is not a simple quantity).
  # 
  def simple?
    cmps = composition
    cmps.empty? || cmps.singular? && cmps.first[0] == self
  end

  # Quantities explicitly coerced by this quantity.
  # 
  def coerces *quantities
    if quantities.empty? then @coerces ||= [] else
      quantities.each { |q| coerces << q }
    end
  end

  # Does this quantity coerce the supplied other quantity?
  # 
  def coerces? other
    other == self || coerces.include?( other ) ||
      counterpart.coerces.include?( other.counterpart ) ||
      if simple? then false else
        composition.coerces? other.composition
      end
  end

  # Protected quantity is not factorized during quantity simplification.
  # 
  def protected?
    @protected
  end

  # Protects the quantity from factorization in quantity simplification.
  # 
  def protect!
    @protected = true
    @composition ||= SY::Composition.singular self
    return self
  end

  # Unprotects the quantity from factorization in quantity simplification.
  # 
  def unprotect!
    @protected = false
    @composition = nil if @composition == SY::Composition.singular( self )
    return self
  end

  # Irreducible quantity is one that either cannot, or should not be factorized
  # during quantity simplification.
  # 
  def irreducible?
    simple? or protected?
  end

  # Constructs a composition from the dimension, or acts as composition getter
  # if the composition has already been specified.
  # 
  def composition
    @composition || dimension.to_composition
  end

  # Acts as the composition setter (dimension must match).
  # 
  def set_composition comp
    @composition = SY::Composition[ comp ]
      .aT "composition, when redefined after initialization,",
          "match the dimension" do |comp| comp.dimension == dimension end
  end

  # Acts as a setter of measure (w.r. to the pertinent standard quantity).
  # 
  def set_measure measure
    @measure = if measure.is_a? Measure then measure else
                 Measure.simple_scaling( measure )
               end
  end

  # Converts magnitude of another quantity to a magnitude of this quantity.
  # 
  def import magnitude
    magnitude measure( from: magnitude.quantity ).r2t.( magnitude.amount )
  end

  # Converts an amount of this quantity to a magnitude of another quantity.
  # 
  def export amount, quantity
    measure( from: quantity ).tr magnitude( amount ), quantity
  end

  # Creates a measure. If no :from is specified, simply acts as a getter of
  # @measure attribute.
  # 
  def measure( from: nil, to: nil )
    fail NotImplementedError, ":to not usable yet!" unless to.nil?
    return @measure if from.nil? # act as simple getter if :from not specified
    puts "#{self.inspect} asked about measure from #{from}" if SY::DEBUG
    return SY::Measure.identity if from == self or from == counterpart
    raise SY::DimensionError, "#{self} vs. #{from}!" unless same_dimension? from
    return from.measure( from: from.standard ).inverse if standardish?
    m = begin
          puts "composition is #{composition}, class #{composition.class}" if SY::DEBUG
          measure ||
            counterpart.measure ||
            composition.infer_measure
        rescue NoMethodError
          fail SY::QuantityError, "Measure from #{from} to #{self} impossible!"
        end
    return m if from.standardish?
    puts "#{from} not standardish, obtained measure relates to #{standard}, and " +
      "it will have to be extended from #{from}." if SY::DEBUG
    return m * standard.measure( from: from )
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
    relative? ? self : counterpart
  end

  # For an absolute quantity, counterpart is the corresponding relative quantity.
  # Vice-versa, for a relative quantity, counterpart is its absolute quantity.
  # 
  def counterpart
    @counterpart ||= construct_counterpart
  end

  # Acts as a counterpart setter.
  # 
  def set_counterpart q2
    raise SY::DimensionError, "Mismatch: #{self}, #{q2}!" unless
      same_dimension? q2
    raise SY::QuantityError, "#{self} an #{q2} are both " +
      "{relative? ? 'relative' : 'absolute'}!" if relative? == q2.relative?
    if measure && q2.measure then
      raise SY::QuantityError, "Measure mismatch: #{self}, #{q2}!" unless
        measure == q2.measure
    end
    @counterpart = q2
    q2.instance_variable_set :@counterpart, self
  end

  # Absolute quantity related to this quantity.
  # 
  def absolute
    absolute? ? self : counterpart
  end

  # Reader of standard unit.
  # 
  def standard_unit
    Unit().standard
  end

  # Constructs an absolute magnitude of this quantity.
  # 
  def magnitude amount
    puts "self.object_id is #{object_id}" if SY::DEBUG
    puts "composition is #{composition}" if SY::DEBUG
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
      set_measure( SY::Measure.simple_scaling( amount.nil? ? 1 : amount.amount ) )
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

  # Is the dimension or its counterpart standard?
  # 
  def standardish?
    standard? || counterpart.standard?
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

  private

  # Setup of Unit parametrized class.
  # 
  def set_up_Unit_class
    param_class!( { Unit: Magnitude() } )
    Unit().class_exec do include SY::Unit end
    Unit().namespace = SY::Unit
    qnt = self
    ɴλ = -> { name ? "#{name}@%s" : "#<Quantity:#{object_id}@%s>" }
    Unit().define_singleton_method :standard do |**nn|
      puts "parametrized #{qnt}@Unit#standard called" if SY::DEBUG
      @standard ||= new **nn.update( of: qnt )
    end
    Unit().define_singleton_method :to_s do ɴλ.call % "Unit" end
  end

  def construct_counterpart
    puts "#{self}#construct_counterpart" if SY::DEBUG
    ɴ = name
    ʀsuffix = RELATIVE_SUFFIX
    rel = relative?
    puts "#{self} is #{rel ? 'relative' : 'absolute'}" if SY::DEBUG
    # Here, it is impossible to rely on Composition::QUANTITY_TABLE –
    # on the contrary, the table relies on Quantity#counterpart.
    constr_ɴ = ->( ɴ, ʀ ) { ç.new composition: composition, ɴ: ɴ, relative: ʀ }
    constr_anon = ->( ʀ ) { ç.new composition: composition, relative: ʀ }
    # enough of preliminaries
    if not rel then
      inst = ɴ ? constr_ɴ.( "#{ɴ}#{ʀsuffix}", true ) : constr_anon.( true )
      inst.aT &:relative?
    elsif ɴ.to_s.ends_with?( ʀsuffix ) && ɴ.size > ʀsuffix.size
      inst = constr_ɴ.( ɴ.to_s[0..ɴ.size-ʀsuffix.size-1], false )
      inst.aT &:absolute?
    else inst = constr_anon.( false ).aT &:absolute? end
    inst.instance_variable_set :@counterpart, self
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
