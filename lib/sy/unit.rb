#encoding: utf-8

# This class represents a unit of measurement – a predefined magnitude
# of a metrological quantity.
# 
module SY::Unit
  def self.pre_included target
    class << target
      # Overriding this method from NameMagic mixin makes sure that all Unit
      # subclasses have the same namespace in Unit class, rather then each
      # parametrized subclass its own.
      # 
      def namespace
        SY::Unit
      end

      # Tweaking instance accessor from NameMagic, to make it accept unit
      # abbreviations, and unit names regardless of capitalization
      # 
      def instance arg
        begin
          super # let's first try the original method
        rescue NameError               # if we fail...
          begin # second in order, let's try whether it's an abbreviation
            super instances.find { |inst|
              inst.abbreviation.to_s == arg.to_s if inst.abbreviation
            }
          rescue NameError, TypeError
            begin # finally, let's try upcase if we have all-downcase arg
              super arg.to_s.upcase
            rescue NameError # if not, tough luck
              raise NameError, "Unknown unit symbol: #{which}"
            end
          end
        end
      end
    end # class << target
  end # def self.pre_included

  def self.included target
    target.class_exec do
      # Let's set up the naming hook for NameMagic:
      name_set_closure do |name, new_instance, old_name|
        ɴ = name.to_s
        up, down = ɴ.upcase, ɴ.downcase
        unless ɴ == up || ɴ = down
          raise NameError, "Unit must be either all-upper or all-lower case!"
        end
        conflicter = SY::PREFIX_TABLE.full_prefixes
          .find { |prefix| down.starts_with? prefix unless prefix.empty? }
        raise NameError, "Name #{ɴ} starts with #{conflicter}- prefix" unless
          down == 'kilogram' if conflicter
        up.to_sym
      end

      # name_get_closure { |name| name.to_s.downcase.to_sym }

      # Using eval, we'll now define all the prefix methods on the target, such
      # as #mili, #micro, #kilo, #mega, etc. These are defined only for units, to which
      # they represent multiplication by the factor of the prefix (side effect
      # of such multiplication is conversion to a normal magnitude). However,
      # the Unit class offers the opportunity for these prefix methods to cause
      # <em>reframing</em> into a quantity specified by #quantity_by_prefix
      # instance method. (This instance method normally returns the unit's own
      # quantity unchanged, but can and should be overriden for those unit,
      # which have area-specific prefix use.)
      # 
      SY::PREFIX_TABLE.full_prefixes.each do |prefix|
        unless prefix.empty?
          define_method prefix do
            SY::Quantity.instance( quantity_by_prefix( prefix ) )
              .magnitude( self * SY::PREFIX_TABLE.to_factor( prefix ) )
          end
        end
      end
    end # module_exec
  end # def self.included

  include NameMagic

  class << self
    # Constructor of units of a given quantity.
    # 
    def of *args
      ꜧ = args.extract_options!
      qnt = case args.size
            when 0 then
              ꜧ.must_have( :quantity, syn!: :of )
              ꜧ.delete :quantity
            when 1 then args.shift
            else
              raise AErr, "Too many ordered arguments!"
            end
      return qnt.unit *( ꜧ.empty? ? args : args << ꜧ )
    end
    
    # Standard unit constructor. In absence of other named arguments, standard
    # unit of the specified quantity is merely retrieved. If other named
    # arguments than :quantity (alias :of) are supplied, they are forwarded to
    # Quantity#new_standard_unit method, that resets the standard unit of the
    # specified quantity. Note that :amount for standard units, if supplied, has
    # special meaning of setting the relationship of that quantity.
    # 
    def standard args={}
      args.must_have :quantity, syn!: :of
      qnt = SY::Quantity.instance( args.delete :quantity )
      if args.empty? then
        qnt.standard_unit 
      else
        qnt.new_standard_unit( args )
      end
    end
    
    # Unit abbreviations as a hash of abbreviation => unit pairs.
    # 
    def abbreviations
      ii = instances
      Hash[ ii.map( &:short ).zip( ii ).select { |short, _| ! short.nil? } ]
    end

    # Full list of known unit names and unit abbreviations.
    # 
    def known_symbols
      instance_names + abbreviations.keys
    end

    # Parses an SPS, curring it with known unit names and abbreviations,
    # and all known full and short prefixes.
    # 
    def parse_sps_using_all_prefixes sps
      puts "Unit about to sps parse (#{sps})" if SY::DEBUG
      SY::PREFIX_TABLE.parse_sps( sps, known_symbols )
    end
  end # class << self

  # Unlike ordinary magnitudes, units can have names and abbreviations.
  # 
  attr_reader :abbreviation
  alias :short :abbreviation
  
  # Unit abbreviation setter.
  # 
  def abbreviation= unit_abbreviation
    @abbreviation = unit_abbreviation.to_sym
  end

  # Unit abbreviation setter (alias for #abbreviation=).
  # 
  def short= unit_abbreviation
    @abbreviation = unit_abbreviation.to_sym
  end
    
  # Unit name. While named units are typically introduced as constants in
  # all-upper case, their names are then presented in all-lower case.
  # 
  def name
    ɴ = super
    return ɴ ? ɴ.to_s.downcase.to_sym : nil
  end

  # Constructor of units provides support for one additional named argument:
  # :abbreviation, alias :short. (This is in addition to :name, alias :ɴ named
  # argument provided by NameMagic.) As a general rule, only named units unit
  # should be given abbreviations. In choosing unit names and abbreviations,
  # ambiguity with regard to standard prefixes and abbreviations thereof should
  # also be avoided.
  # 
  def initialize args={}
    if args.has? :abbreviation, syn!: :short then
      @abbreviation = args.delete( :abbreviation ).to_sym
    end
      
    # FIXME: Here, we would have to watch out for :amount being set
    # if it is a number, amount is in standard units
    # however, if it is a magnitude, especially one of another equidimensional quantity,
    # it estableshes a relationship between this and that quantity. It means that
    # the unit amount automatically becomes ... one ... and such relationship can
    # only be established for standard quantity
    super args
  end

  # Addition: Unit is converted to a magnitude before the operation.
  # 
  def + other
    to_magnitude + other
  end

  # Subtraction: Unit is converted to a magnitude before the operation.
  # 
  def - other
    to_magnitude - other
  end

  # Multiplication: Unit is converted to a magnitude before the operation.
  # 
  def * other
    to_magnitude * other
  end

  # Division: Unit is converted to a magnitude before the operation.
  # 
  def / other
    to_magnitude / other
  end

  # Exponentiation: Unit is converted to a magnitude before the operation.
  # 
  def ** exponent
    to_magnitude ** exponent
  end

  # Coercion: Unit is converted to a magnitude before coercion is actually
  # performed.
  # 
  def coerce other
    to_magnitude.coerce( other )
  end

  # Reframing: Unit is converted to a magnitude before reframing.
  # 
  def reframe other_quantity
    to_magnitude.reframe( other_quantity )
  end

  # Unit as string.
  # 
  def to_s
    name.nil? ? to_s_when_anonymous : to_s_when_named
  end

  # Inspect string for the unit.
  # 
  def inspect
    name.nil? ? inspect_when_anonymous : inspect_when_named
  end

  # Converts a unit into ordinary magnitude.
  # 
  def to_magnitude factor=nil
    factor.nil? ? magnitude( amount ) : magnitude( amount ) * factor
  end

 # factor=1
 #  end

  # Some prefixes of some units are almost exclusively used in certain areas
  # of science or engineering, and their appearance would indicate such
  # specific quantity. By default, this method simply returns unit's own
  # quantity unchanged. But it is expected that the method will be overriden
  # by a singleton method in those units, which have area-specific prefixes.
  # For example, centimetre, typical for civil engineering, could cause
  # reframing into its own CentimetreLength quantity. Assuming METRE unit,
  # this could be specified for example by:
  # <tt>
  # METRE.define_singleton_method :quantity_by_prefix do |full_prefix|
  #   case full_prefix
  #   when :centi then CentimetreLength
  #   else self.quantity end
  # end
  # </tt>
  # 
  def quantity_by_prefix prefix
    quantity
  end

  private

  # Constructs #to_s string when the unit is anonymous.
  # 
  def to_s_when_anonymous
    "[#{çς}: #{amount} of #{quantity}]"
  end

  # Constructs #to_s string when the unit is named.
  # 
  def to_s_when_named
    name
  end

  # Constructs inspect string when the unit is anonymous.
  # 
  def inspect_when_anonymous
    "#<#{çς}: #{to_magnitude} >"
  end

  # Constructs inspect string when the unit is named.
  # 
  def inspect_when_named
    "#<#{çς}: #{name} of #{quantity} >"
  end

  # String describing this class.
  # 
  def çς
    "Unit"
  end
end # class SY::Unit
