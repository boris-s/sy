#encoding: utf-8
#encoding: utf-8

module SY
  # This class represents a unit of measurement – a predefined magnitude
  # of a metrological quantity.
  # 
  class Unit < Magnitude
    include NameMagic

    # Checks the unit name a little bit for correctness.
    # 
    naming_hook { |ɴ, new_instance, old_name|
      conflicting_row = ::SY::PREFIX_TABLE.find { |row|
        ɴ.start_with? row[:full] unless row[:full].empty?
      }
      raise NameError, "Unit name may not start with standard prefix! (#{ɴ} " +
          "starts with #{conflicting_row[:full]} prefix)" if conflicting_row
      # This is not completely foolproof, but let's rely on user's common sense
      ɴ
    }

    # Standard unit constructor.
    # 
    def self.standard *args, &block
      puts args
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

    # Unit name (in lower case).
    # 
    def name
      super.downcase
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
      @short = hash.may_have( :short, syn!: :abbreviation ).to_sym
      ( quantity.units << self ).uniq!
    end
  end # class Unit
end # module SY
