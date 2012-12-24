#encoding: utf-8
#encoding: utf-8

module SY
  # This class represents a unit of measurement – a predefined magnitude
  # of a metrological quantity.
  # 
  class Unit < Magnitude
    include NameMagic

    # Checks the unit name a tiny bit for correctness.
    # 
    naming_hook { |ɴ, new_instance, old_name|
      ɴ = ɴ.to_s
      raise NameError, "Unit name must all be in same case (upper-case " +
        "version is used as unit and constant name, lower-case version " +
        "in magnitude expressions." unless ɴ == ɴ.upcase || ɴ == ɴ.downcase
      ɴ_down = ɴ.downcase
      conflicting_row = ::SY::PREFIX_TABLE.find { |row|
        ɴ_down.to_s.start_with? row[:full] unless row[:full].empty?
      }
      raise NameError, "Unit name may not start with standard prefix! (#{ɴ} " +
          "starts with #{conflicting_row[:full]} prefix)" if conflicting_row
      # This is not completely foolproof, but let's rely on user's common sense
      ɴ_down.upcase.to_sym
    }

    # Standard unit constructor.
    # 
    def self.standard *args, &block
      instance = new *args, &block
      instance.quantity.standard_unit = self
      return instance
    end

    # Eval is used to define all the prefix methods.
    # 
    ::SY::PREFIX_TABLE.full.each{ |full_prefix|
      eval( "def #{full_prefix}\n" +
            "  self * " +
            "#{::SY::PREFIX_TABLE.hash_full[ full_prefix ][:factor]}\n" +
            "end" ) unless full_prefix.empty?
    }

    # Unlike ordinary magnitudes, units can have names and abbreviations.
    # 
    attr_reader :short
    alias :abbreviation :short

    # Unit abbreviation setter.
    # 
    def short= unit_symbol
      @short = unit_symbol.to_sym
    end
    alias :abbreviation= :short=

    # Unit name (units are typically named as constants in all-upper case,
    # but their names are always presented in all-lower case).
    # 
    def name
      ɴ = super
      return ɴ ? ɴ.to_s.downcase.to_sym : nil
    end

    # Apart from the arguments required by Magnitude, Unit constructor allows
    # named argument :short, alias :abbreviation. A unit must be named, if
    # abbreviation is given. In choosing unit names and abbreviation, ambiguity
    # with regard to standard prefixes and their abbreviations must be avoided.
    # 
    def initialize *args
      hash = args.extract_options!
      super
      # abbreviation can be introduced by multiple keywords
      if hash.has? :short, syn!: :abbreviation then
        @short = hash[:short].to_sym
      end
      ( quantity.units << self ).uniq!
    end

    # Unit as string.
    # 
    def to_s
      if name.nil? then
        "[unit %s of %s]" % [ amount, quantity ]
      else
        "%s%s" % [ name, short.nil? ? '' : ' (%s)' % short ]
      end
    end

    # Inspect string for the unit.
    # 
    def inspect
      if name.nil? then "#<#{ç}: #{to_magnitude.to_s} >" else
        "#<#{ç}: #{name}#{short.nil? ? '' : ' (%s)' % short} of #{quantity} >"
      end
    end

    private

    # Converts a unit into a regular magnitude.
    # 
    def to_magnitude
      Magnitude.of quantity, amount: amount
    end
  end # class Unit
end # module SY
