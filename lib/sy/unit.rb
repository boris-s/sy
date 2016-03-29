# coding: utf-8

# This class represents a unit of measurement – a predefined magnitude
# of a metrological quantity.
# 
module SY::Unit
  PROTECTED_NAMES = [ "kilogram" ]

  class << self
    # Make Unit#instance ignore capitalization, accept abbreviations.
    # 
    def instance arg
      begin
        super # let's first try the original method
      rescue NameError # if we fail...
        begin # ... let's try the abbreviation
          super instances.find { |unit_inst|
            unit_inst.short.to_s == arg.to_s if unit_inst.short
          }.tap { |rslt| fail NameError if rslt.nil? } # fail if nothing found
        rescue NameError, TypeError
          begin # Let's to try upcase if we have all-downcase arg
            super arg.to_s.upcase
          rescue NameError # if not, tough luck
            raise NameError, "Unknown unit symbol: #{arg}"
          end
        end
      end
    end

    def included target
      target.namespace = self

      name_set_hook do |name, new_instance, old_name|
        ɴ = name.to_s
        up, down = ɴ.upcase, ɴ.downcase
        msg = "Unit must be either all-upper or all-lower case (#{ɴ} given)!"
        fail NameError, msg unless ɴ == up || ɴ = down
        # Reject the names starting with a full prefix.
        pref = SY::PREFIX_TABLE.full_prefixes.find do |pref|
          down.starts_with? pref unless pref.empty?
        end
        fail NameError, "Name #{ɴ} starts with #{pref}- prefix!" unless
          SY::Unit::PROTECTED_NAMES.include? down if pref
        # Warn about the method name conflicts in the #include target module
        if new_instance.warns? then
          w = SY::ExpressibleInUnits::COLLISION_WARNING
          SY::ExpressibleInUnits.included_in.each do |modul|
            im = modul.instance_methods
            warn w % [down, modul] if im.include? down
            abbrev = new_instance.abbreviation
            warn w % [abbrev, modul] if im.include? abbrev
          end
        end
        up.to_sym
      end

      # We'll now define all the prefix methods on the target (#mili, #mega...),
      # representing multiplication by the aprropriate factor (side effect being
      # returning a non-unit magnitude). However, Unit offers the opportunity to
      # _reframe_ into another quantity, specified by #quantity_by_prefix method.
      # (This method normally returns the unit's own quantity, but can and should
      # be overriden for prefixes indicating special domain (eg. +cm+)...
      # 
      SY::PREFIX_TABLE.full_prefixes.each do |pref|
        unless pref.empty?
          define_method pref do
            SY::Quantity
              .instance( quantity_by_prefix( pref ) )
              .magnitude( self * SY::PREFIX_TABLE.to_factor( pref ) )
          end
        end
      end
    end # def included
  end # class << self

  include NameMagic # it respects prefiously defined self.included

  class << self
    # Constructor of units of a given quantity.
    # 
    def of quantity, **nn
      quantity.unit **nn
    end
    
    # Standard unit constructor. In absence of other named arguments, standard
    # unit of the specified quantity is merely retrieved. If other named
    # arguments than :quantity (alias :of) are supplied, they are forwarded to
    # Quantity#new_standard_unit method, that resets the standard unit of the
    # specified quantity. Note that :amount for standard units, if supplied, has
    # special meaning of setting the relationship of that quantity.
    # 
    def standard( of: nil, **nn )
      fail ArgumentError, ":of argument missing!" if of.nil?
      qnt = SY::Quantity.instance( of )
      nn.empty? ? qnt.standard_unit : qnt.new_standard_unit( **nn )
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
      instances.names( false ).map( &:downcase ) + abbreviations.keys
    end

    # Parses an SPS, curring it with known unit names and abbreviations,
    # and all known full and short prefixes.
    # 
    def parse_sps_using_all_prefixes sps
      SY::PREFIX_TABLE.parse_sps( sps, known_symbols )
    end
  end # class << self

  # Unlike ordinary magnitudes, units can have names and abbreviations.
  # 
  attr_reader :abbreviation
  alias short abbreviation

  # Whether the unit warns when the module in which unit method mixin is
  # included contains blatant name collisions with this unit name/abbreviation.
  # 
  attr_accessor :warns
  alias warns? warns
  
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

  # Constructor of units provides support for one additional named argument:
  # :abbreviation, alias :short. (This is in addition to :name, alias :ɴ named
  # argument provided by NameMagic.) As a general rule, only named units unit
  # should be given abbreviations. In choosing unit names and abbreviations,
  # ambiguity with regard to standard prefixes and abbreviations thereof should
  # also be avoided. Another argument, :warns, Boolean, <em>true</em> by
  # default, determines whether the method warns about name collisions with
  # other methods defined where the SY::ExpressibleInUnits mixin is included.
  # 
  def initialize( short: nil, warns: true, **nn )
    @abbreviation = short.to_sym if short
    @warns = warns # does this unit care about blatant name collisions?
    super nn
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
    to_magnnitude.reframe( other_quantity )
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
  def çς; "Unit" end
end # class SY::Unit
