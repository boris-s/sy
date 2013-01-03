#encoding: utf-8

module SY::UnitMixin
  def self.included receiver
    receiver.module_exec do
      include NameMagic
      # Let's set up the naming hook for NameMagic:
      name_set_closure { |name, new_instance, old_name|
        ɴ = name.to_s
        up, down = ɴ.upcase, ɴ.downcase
        raise NameError, "Unit name must be either all-upper or " +
          "all-lower case." unless ɴ == up || ɴ = down
        conflicter = SY::PREFIX_TABLE.find { |row|
          full = row[:full]
          down.starts_with? full unless full.empty?
        }
        raise NameError, "Name #{ɴ} starts with #{conflicter[:full]}- " +
        "prefix." unless down == 'kilogram' if conflicter
        up.to_sym
      }

      # name_get_closure { |name| name.to_s.downcase.to_sym }

      # Eval is used to define all the prefix methods, such as #mili, #micro,
      # #kilo, #mega, etc. These methods are defined only for units, to which
      # they represent multiplication by the factor of the prefix (side effect
      # of such multiplication is conversion to a normal magnitude). However,
      # the Unit class offers the opportunity for these prefix methods to cause
      # <em>reframing</em> into a quantity specified by #quantity_by_prefix
      # instance method. (This instance method normally returns the unit's own
      # quantity unchanged, but can and should be overriden for those unit,
      # which have area-specific prefix use.)
      # 
      SY::PREFIX_TABLE.full.each { |full_prefix|
        unless full_prefix.empty?
          define_method full_prefix do
            SY::Quantity.instance( quantity_by_prefix( full_prefix ) )
              .amount self * SY::PREFIX_TABLE.hash_full[ full_prefix ][:factor]
          end
        end
      }
    end # module_exec

    receiver.extend SY::UnitMixin::UnitMixinModuleMethods
  end # def self.included

  module UnitMixinModuleMethods
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
      return qnt.new_unit *( ꜧ.empty? ? args : args << ꜧ )
    end

    # Standard unit constructor.
    # 
    def standard *args
      ꜧ = args.extract_options!
      qnt = case args.size
            when 0 then
              ꜧ.must_have( :quantity, syn!: :of )
              ꜧ.delete :quantity
            when 1 then args.shift
            else
              raise AErr, "Too many ordered arguments!"
            end
      args = ( ꜧ.empty? ? args : args << ꜧ )
      if args.empty? then
        qnt.standard_unit
      else
        instance = qnt.new_unit *args
        qnt.standard_unit = instance
      end
    end
    
    # Unit abbreviations as a hash of abbreviation => name pairs.
    # 
    def abbreviations
      ii = instances
      Hash[ ii.map( &:short ).zip( ii.map &:name )
              .select { |short, full| ! short.nil? } ]
    end
  end
  
  # Unlike ordinary magnitudes, units can have names and abbreviations.
  # 
  attr_reader :abbreviation
  alias :short :abbreviation
  
  # Unit abbreviation setter.
  # 
  def abbreviation= unit_abbreviation
    @abbreviation = unit_abbreviation.to_sym
  end

  # Unit abbreviation setter (#abbreviation= alias)
  def short= unit_abbreviation
    @abbreviation = unit_abbreviation.to_sym
  end
    
  # Unit name (units are typically named as constants in all-upper case,
  # but their names are always presented in all-lower case).
  # 
  def name
    ɴ = super
    return ɴ ? ɴ.to_s.downcase.to_sym : nil
  end

  # Apart from the arguments required by Magnitude, Unit constructor allows
  # named argument :abbreviation, alias :short. A unit must be named, if
  # abbreviation is given. In choosing unit names and abbreviation, ambiguity
  # with regard to standard prefixes and their abbreviations must be avoided.
  # 
  def initialize *args
    ꜧ = args.extract_options!
    ꜧ.may_have :abbreviation, syn!: :short
    @abbreviation = ꜧ[:abbreviation].to_sym if ꜧ.has? :abbreviation
    super
  end

  # Adding a unit to a magnitude results in a magnitude, not unit.
  # 
  def + other
    to_magnitude + other
  end

  # Subtracting a magnitude from a unit results in a magnitude, not unit.
  # 
  def - other
    to_magnitude - other
  end

  # Multiplication of a unit results in a magnitude, not unit.
  # 
  def * other
    to_magnitude * other
  end

  # Division of a unit results in a magnitude, not unit.
  # 
  def / other
    to_magnitude / other
  end

  # Exponentiation of a unit results in a magnitude, not unit.
  # 
  def ** exponent
    to_magnitude ** exponent
  end

  # Coercion sent to a unit converts the unit to a magnitude before coercion
  # being actually performed.
  # 
  def coerce other
    to_magnitude.coerce( other )
  end

  # Reframing of a unit results in a magnitude, not unit.
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

  # Converts the unit into a regular magnitude.
  # 
  def to_magnitude
    quantity.amount amount
  end

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
end # module SY::UnitMixin
