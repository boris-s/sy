#encoding: utf-8
require "sy/version"
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/reverse_merge'

module SY
  def self.included( receiver )
    ::Numeric.module_exec do
      include UnitMethodsMixin
    end
  end
  
  module UnitMethodsMixin
    def method_missing( mτ_id, *args, &block )
      # Check whether mτ_id is registered in the table of units:
      begin
        pfxs, units, exps =
          ::SY::SPS_PARSER.( mτ_id.to_s, ::SY::UNITS_WITHOUT_PREFIX.keys,
                             ::SY::PREFIXES.keys )
      rescue ArgumentError # SPS_PARSER fails with AE if mτ_id not registered,
        super         # in which case, #method_missing is forwarded higher
      end
      # mτ_id is a unit method; gonna define it. Definition skeleton:
      dϝ = "def #{mτ_id}\n" +         # def line
        "%s\n" +                   # method body
        "end"                      # end
      # Parser output >> elements to be multiplied together:
      elementj = pfxs.zip(units).zip(exps).map{|ab, c| ab + [c] }.map{|row|
        pfx, u, exp = row          # prefix, basic unit, exponent
        pfx = PREFIXES[pfx][:full]
        str = pfx == "" ? "::SY::UNITS_WITHOUT_PREFIX['#{u}']" :
        "::SY::UNITS_WITHOUT_PREFIX['#{u}'].#{pfx}"
        str += ( exp == 1 ? "" : " ** #{exp}" )
      }
      # Method body is constructed as a product of the elements:
      mτ_bodyς = elementj.reduce "self" do |acc, ς| "%s * \n" % ς + acc end
      # Finally, method is defined for the class on which it was called...
      self.class.module_eval dϝ % mτ_bodyς
      # ...and invoked
      send mτ_id, *args, &block
    end # def method_missing
    
    def respond_to_missing?( mτ_id, include_private = false )
      # Check whether mτ_id is registered in the table of units:
      begin
        pfxs, units, exps =
          ::SY::SPS_PARSER.( mτ_id.to_s, ::SY::UNITS_WITHOUT_PREFIX.keys,
                             ::SY::PREFIXES.keys )
      rescue ArgumentError # SPS_PARSER fails with AE if mτ_id not registered,
        super         # in which case, #respond_to_missing is sent higher
      end
    end

    def °C; Magnitude.of ABSOLUTE_TEMPERATURE, n: self + 273.15 end
  end # UnitMethodsMixin

  # Basic dimensions of physical quantities
  BASIC_DIMENSIONS =
    { L: :LENGTH, M: :MASS, T: :TIME, Q: :ELECTRIC_CHARGE, Θ: :TEMPERATURE }
  
  # Basic dimension symbols (letters)
  DIM_L = BASIC_DIMENSIONS.keys
  
  # Dimensions more or less have their standard quantities,
  # which, once defined, will be held in this hash table as pairs
  # of { dimension array => standard quantity }
  QUANTITIES = {}

  # Defined units { unit_name => unit_instance } and
  # { unit_abbreviation ("symbol") => unit_instance }
  UNITS_WITHOUT_PREFIX = {}

  # Basic units of quantities
  # (hash of { quantity => basic_unit })
  BASIC_UNITS = Hash.new {|hsh, qnt| Unit.basic of: qnt }

  # Apart from basic units, other units are commonly favored
  # (hash of { quantity => [ array of favored units ] })
  FAV_UNITS = Hash.new []

  # Table of prefixes and their corresponding unit multiples
  PREFIX_TABLE = [ { full: "exa", short: "E", factor: 1e18 },
                   { full: "peta", short: "P", factor: 1e15 },
                   { full: "tera", short: "T", factor: 1e12 },
                   { full: "giga", short: "G", factor: 1e9 },
                   { full: "mega", short: "M", factor: 1e6 },
                   { full: "kilo", short: "k", factor: 1e3 },
                   { full: "hecto", short: "h", factor: 1e2 },
                   { full: "deka", short: "dk", factor: 1e1 },
                   { full: "", short: "", factor: 1 },
                   { full: "deci", short: "d", factor: 1e-1 },
                   { full: "centi", short: "c", factor: 1e-2 },
                   { full: "mili", short: "m", factor: 1e-3 },
                   { full: "micro", short: "µ", factor: 1e-6 },
                   { full: "nano", short: "n", factor: 1e-9 },
                   { full: "pico", short: "p", factor: 1e-12 },
                   { full: "femto", short: "f", factor: 1e-15 },
                   { full: "atto", short: "a", factor: 1e-18 } ]
  
  # Valid prefixes as a list (simple array)
  PREFIXES = PREFIX_TABLE.each_with_object( Hash.new ) {|row, ꜧ| ꜧ[row[:full]] = row
                                                    ꜧ[row[:short]] = row }
  
  # Unicode superscript exponents 
  SUPERSCRIPT = Hash.new { |ꜧ, key|
    if key.is_a? String then
      key.size <= 1 ? nil : key.each_char.map{|c| ꜧ[c] }.join
    else
      ꜧ[key.to_s]
    end
  }.merge! Hash[ '-/0123456789'.each_char.zip( '⁻⎖⁰¹²³⁴⁵⁶⁷⁸⁹'.each_char ) ]
  
  # Reverse conversion (from exponent strings to fixnums)
  SUPERSCRIPT_DOWN = Hash.new { |ꜧ, key|
    if key.is_a? String then
      key.size == 1 ? nil : key.each_char.map{|c| ꜧ[c] }.join
    else
      ꜧ[key.to_s]
    end
  }.merge! SUPERSCRIPT.invert
  
  # SPS stands for "superscripted product string"    
  SPS = lambda { |ßs, exps|
    raise ArgumentError unless ßs.size == exps.size
    exps = exps.map{|e| Integer e }
    zipped = ßs.zip( exps )
    clean = zipped.reject {|e| e[1] == 0 }
    # omit exponents equal to 1:
    clean.map{|ß, exp| "#{ß}#{exp == 1 ? "" : SUPERSCRIPT[exp]}" }.join "."
  }
  def SPS.inspect
    "Superscripted product string constructor lambda." +
      "Takes 2 arguments. Example: [:a, :b], [-1, 2] #=> a⁻¹b²."
  end
  
  # SPS parser takes 3 parameters: a string, an array of acceptable symbols,
  # and an array of acceptable prefixes. It returns 3 arrays: prefixes,
  # symbols and exponents.
  SPS_PARSER = lambda { |input_string, ßs, prefixj = []|
    complaint = "unacceptable string: #{input_string}"
    # argument grooming
    input_string = input_string.to_s.strip
    ßs = ßs.map &:to_s
    prefixj = prefixj.map( &:to_s ) << ""
    # input string splitting
    input_string_sections = input_string.split '.'
    if input_string_sections.empty?
      raise ArgumentError, complaint unless input_string.empty?
      return [], [], []
    end
    # analysis of input string sections
    input_string_sections.each_with_object( [[], [], []] ) {|section, memo|
      sec = section.dup
      superscript_chars = SUPERSCRIPT.values
      # strip superscript tail
      sec.chop! while superscript_chars.any? {|char| sec.end_with? char }
      # create new complaint for those ArgumentErrors w're gonna raise
      complaint = "unacceptable symbol: #{sec}"
      # the set of possible matching unit symbols
      possible_ßs = ßs.select{|ß| sec.end_with? ß }
      # complain if no symbol matches sec
      raise ArgumentError, complaint if possible_ßs.empty?
      # seek possible prefixj corresponding to possible_ßs
      possible_prefixj = possible_ßs.map{|ß| sec[0..-1 - ß.size] }
      # see which possible prefixj can be confirmed
      confirmed_prefixj = possible_prefixj.select{|pfx| prefixj.include? pfx }
      # warn if sec factors into more than one prefix/symbol pair
      warn "ambiguity in symbol #{sec} in #{input_string}" if
        confirmed_prefixj.size > 1
      # make sure that exactly one interpretation of sec exists
      raise ArgumentError, complaint unless confirmed_prefixj.size == 1
      # based on it, interpret the section parts
      prefix = confirmed_prefixj[0]
      ß = sec[prefix.size..-1]
      suffix = section[-1 - prefix.size - ß.size..-1]
      # make suffix string into the exponent number
      exponent_string = SUPERSCRIPT_DOWN[suffix]
      raise ArgumentError, complaint if exponent_string.nil? # complain if bad
      exponent_string = "1" if exponent_string == '' # no exp. means 1
      exp = Integer exponent_string
      raise ArgumentError, "Zero exponents not allowed: #{exponent_string}" if exp == 0
      # and store the interpretation
      memo[0] << prefix; memo[1] << ß; memo[2] << exp
    }
  }
  def SPS_PARSER.inspect; "Superscripted product string parser lambda. " +
      "Takes 2 compulsory and 1 optional argument. Example: " +
      '"kB.s⁻¹", [:g, :B, :s, :C], [:M, :k, :m, :µ] #=> ["k", ""], ' +
      '["B", "s"], [1, -1]'
  end
  
  # Metrological dimension
  class Dimension
    # Constructor for basic dimensions (given basic dim. symbol)
    def self.basic ß
      raise ArgumentError, "Unknown basic dimension symbol: #{ß}" unless
        ( DIM_L + BASIC_DIMENSIONS.values ).include? ß.to_sym
      return new ß.to_sym => 1
    end

    # Constructors for zero dimension
    def self.zero; new end
    def self.null; new end
    
    attr_accessor *DIM_L
    
    # Dimension can be initialized either by a hash
    # (such as Dimension.new L: 1, T: -2) or by SPS (superscripted
    # product string), such as Dimension.new( "L.T⁻²" )
    def initialize arg = {}
      # Make sure that in any case, arg is converted to ꜧ
      ꜧ = if arg.respond_to? :keys then arg
          elsif arg.is_a? self.class then arg.to_hash
          else
             pfxs, dims, exps = SPS_PARSER.( arg, DIM_L )
             Hash[ dims.map(&:to_sym).zip( exps ) ]
          end
      # and use that hash to initialize the instance
      ꜧ = ꜧ.reverse_merge!( L: 0, M: 0, T: 0, Q: 0, Θ: 0 ).
        each_with_object( Hash.new ) {|pp, ꜧ| ꜧ[pp[0]] = Integer( pp[1] ) }
      @L, @M, @T, @Q, @Θ = ꜧ[:L], ꜧ[:M], ꜧ[:T], ꜧ[:Q], ꜧ[:Θ]
    end

    # #[] method provides access to the dimension components, such as
    # d = Dimension.new( L: 1, T: -2 ), d[:T] #=> -2
    def [] arg
      ß = arg.to_s.strip.to_sym
      if DIM_L.include? ß then send ß else
        raise ArgumentError, "Unknown basic dimension symbol: #{ß}" unless
          BASIC_DIMENSIONS.values.include? ß
        send BASIC_DIMENSIONS.rassoc(ß)[0]
      end
    end

    # #== method - two dimensions are equal if their componets are equal
    def == other
      raise ArgumentError unless other.is_a? self.class # other must be a dimension
      DIM_L.map{|l| self[l] == other[l] }.reduce(:&)
    end

    # Dimension arithmetics (+, -, *, /)
    def + other; self.class.new Hash[ DIM_L.map{|l| [l, self[l] + other[l]] } ] end
    def * num; self.class.new Hash[ DIM_L.map{|l| [l, self[l] * num] } ] end
    def - other; self.class.new Hash[ DIM_L.map{|l| [l, self[l] - other[l]] } ] end
    def / num     # (division only works if all the exponents are divisible)
      ( exps = to_a ).each{ |e|
        raise ArgumentError, "division only works if all the exponents are divisible" unless
          e % num == 0
      }
      Dimension.new Hash[ DIM_L.zip( exps.map{|e| e / num } ) ]
    end

    # Inspectors and convertors. Eg for d = Dimension.new( L: 1, T: -2 )
    # d.to_a #=> [ 1, 0, -2, 0, 0 ]
    def to_a; DIM_L.map {|l| self[l] } end
    # d.to_hash #=> { L: 1, M: 0, T: -2, Q: 0, Θ: 0 }
    def to_hash; DIM_L.each_with_object({}) {|l, h| h[l] = self[l] } end
    # d.to_s #=> "L.T⁻²"
    def to_s
      sps = SPS.( DIM_L, DIM_L.map{|l| self[l] } )
      sps == "" ? "∅" : sps
    end
    # d.zero? #=> false
    def zero?; [@L, @M, @T, @Q, @Θ] == [0, 0, 0, 0, 0] end
    # d.inspect #=> "dimension L.T⁻²"
    def inspect; zero? ? "zero dimension" : "dimension #{self}" end
    
    # Returns dimension's standard quantity from the table
    def standard_quantity; QUANTITIES[to_a] end

    delegate :fav_units, to: :standard_quantity
  end # class Dimension
    
  # Metrological quantity
  class Quantity
    # #of constructor. Example:
    # q = Quantity.of Dimension.new( "L.T⁻²" )
    def self.of( dim, oj = {} ); new oj.merge( dimension: dim ) end

    # #standard constructor. Example:
    # q = Quantity.standard of: Dimension.new( "L.T⁻²" )
    def self.standard( oo ); new( oo ).set_as_standard end

    # Dimensionless quantity constructors:
    def self.zero( oj = {} ); new oj.merge( dimension: Dimension.zero ) end
    def self.null oj = {}; zero oj end
    def self.dimensionless oj = {}; zero oj end

    attr_reader :name, :dimension
    def name=( ɴ ); @name = ɴ.blank? ? nil : ɴ.to_s.capitalize end
    
    # Quantity is little more then a combination of a name and a
    # metrological dimension.
    def initialize oj
      @dimension = Dimension.new oj[:dimension] || oj[:of]
      ɴ = oj[:name] || oj[:ɴ]
      @name = ɴ.blank? ? nil : ɴ.to_s.capitalize
    end

    # Convenience shortcut to register a name of the basic unit of
    # self in the UNITS table. Admits either syntax:
    # quantity.name_basic_unit "name", symbol: "s"
    # or
    # quantity.name_basic_unit "name", "s"
    def name_basic_unit( ɴ, oj = nil )
      u = Unit.basic( oj.respond_to?(:keys) ? oj.merge( of: self, ɴ: ɴ ) :
                      { of: self, ɴ: ɴ, abbr: oj } )
      BASIC_UNITS[self] = u
    end
    alias :ɴ_basic_unit :name_basic_unit

    # #basic_unit convenience reader of the BASIC_UNITS table
    def basic_unit; BASIC_UNITS[self] end

    # #fav_units convenience reader of the FAV_UNITS table
    def fav_units; FAV_UNITS[self] end

    # #to_s convertor
    def to_s; "#{name.nil? ? "quantity" : name} (#{dimension})" end
    
    # Inspector
    def inspect
      "#{name.nil? ? 'unnamed quantity' : 'quantity "%s"' % name} (#{dimension})"
    end

    # Arithmetics
    # #*
    def * other
      msg = "Quantities only multiply with Quantities, Dimensions and " +
        "Numerics (which leaves them unchanged)"
      case other
      when Numeric then self
      when Quantity then self.class.of dimension + other.dimension
      when Dimension then self.class.of dimension + other
      else raise ArgumentError, msg end
    end

    # #/
    def / other
      msg = "Quantities only divide with Quantities, Dimensions and " +
        "Numerics (which leaves them unchanged)"
      case other
      when Numeric then self
      when Quantity then self.class.of dimension - other.dimension
      when Dimension then self.class.of dimension - other
      else raise ArgumentError, msg end
    end

    # #**
    def ** num; self.class.of self.dimension * Integer( num ) end

    # Make this quantity the standard quantity for its dimension
    def set_as_standard; QUANTITIES[dimension.to_a] = self end
  end # class Quantity

  # Magnitude of a metrological quantity
  class Magnitude
    include UnitMethodsMixin
    include Comparable

    def self.of qnt, oo
      oo = { n: oo } unless oo.is_a? Hash
      n = oo[:number] || oo[:n] or raise AE, "Magnitude number not given!"
      named_args = { quantity: qnt }.merge! case n
                                            when Numeric then { n: n }
                                            else { n: n.to_f } end
      if n < 0 then
        SignedMagnitude.new oo.merge( named_args ).merge!( sign: :- )
      else new oo.merge( named_args ) end
    end
    
    attr_reader :quantity, :number
    alias :n :number
    delegate :dimension, :basic_unit, :fav_units, to: :quantity

    # A magnitude is basically a pair [quantity, number].
    def initialize oj
      @quantity = oj[:quantity] || oj[:of]
      raise ArgumentError unless @quantity.kind_of? Quantity
      @number = oj[:number] || oj[:n]
      raise ArgumentError, "Negative number of the magnitude: #@number" unless
        @number >= 0
    end
    # idea: for more complicated units (offsetted, logarithmic etc.),
    # conversion closures from_basic_unit, to_basic_unit

    # SAME QUANTITY magnitudes compare by their numbers
    def <=> other
      aE_same_quantity( other )
      self.n <=> other.n
    end

    # #abs absolute value - Magnitude with number.abs
    def abs; self.class.of quantity, number: n.abs end
      
    # addition
    def + other
      aE_same_quantity( other )
      self.class.of( quantity, n: self.n + other.n )
    end

    # subtraction
    def - other
      aE_same_quantity( other )
      self.class.of( quantity, n: self.n - other.n )
    end

    # multiplication
    def * other
      case other
      when Magnitude
        self.class.of( quantity * other.quantity, n: self.n * other.n )
      when Numeric then [1, other]
        self.class.of( quantity, n: self.n * other )
      else
        raise ArgumentError, "magnitudes only multiply with magnitudes and numbers"
      end
    end

    # division
    def / other
      case other
      when Magnitude
        self.class.of( quantity / other.quantity, n: self.n / other.n )
      when Numeric then [1, other]
        self.class.of( quantity, n: self.n / other )
      else
        raise ArgumentError, "magnitudes only divide by magnitudes and numbers"
      end
    end

    # power
    def ** arg
      return case arg
             when Magnitude then self.n ** arg.n
             else
               raise ArgumentError unless arg.is_a? Numeric
               self.class.of( quantity ** arg, n: self.n ** arg )
             end
    end

    # Gives the magnitude as a numeric value in a given unit. Of course,
    # the unit must be of the same quantity and dimension.
    def numeric_value_in other
      case other
      when Symbol, String then
        other = other.to_s.split( '.' ).reduce 1 do |pipe, sym| pipe.send sym end
      end
      aE_same_quantity( other )
      self.n / other.number
    end
    alias :in :numeric_value_in

    def numeric_value_in_basic_unit
      numeric_value_in BASIC_UNITS[self.quantity]
    end
    alias :to_f :numeric_value_in_basic_unit

    # Changes the quantity of the magnitude, provided that the dimensions
    # match.
    def is_actually! qnt
      raise ArgumentError, "supplied quantity dimension must match!" unless
        qnt.dimension == self.dimension
      @quantity = qnt
      return self
    end
    alias call is_actually!

    #Gives a string expressing the magnitude in given units.
    def string_in_unit unit
      if unit.nil? then
        number.to_s
      else
        str = ( unit.symbol || unit.name ).to_s
        ( str == "" ? "%.2g" : "%.2g.#{str}" ) % numeric_value_in( unit )
      end
    end

    # #to_s converter gives the magnitude in its most favored units
    def to_s
      unit = fav_units[0]
      str = if unit then string_in_unit( unit )
            else # use fav_units of basic dimensions
              hsh = dimension.to_hash
              symbols, exponents = hsh.each_with_object Hash.new do |pair, memo|
                sym, val = pair
                u = Dimension.basic( sym ).fav_units[0]
                memo[u.symbol || u.name] = val
              end.to_a.transpose
              sps = SPS.( symbols, exponents )
              "%.2g#{sps == '' ? '' : '.' + sps}" % number
            end
    end

    # #inspect
    def inspect; "magnitude #{to_s} of #{quantity}" end

    private

    def aE_same_quantity other
      raise ArgumentError unless other.kind_of? Magnitude
      unless self.dimension == other.dimension
        raise ArgumentError, "magnitudes not of the same dimension " +
          "(#{dimension} vs. #{other.dimension})"
      end
      unless self.quantity == other.quantity
        warn "Warning: Mixing different quantities with same dimension!\n" +
          "(#{quantity.inspect} vs. #{other.quantity.inspect})"
      end
    end
    alias :aE_same_quantity :aE_same_quantity
  end # class Magnitude
  
  # SignedMagnitude allows its number to be negative
  class SignedMagnitude < Magnitude
    def initialize oo
      @quantity = oo[:quantity] || oo[:of]
      raise ArgumentError unless @quantity.kind_of? Quantity
      @number = oo[:number] || oo[:n]
    end
  end

  # Unit of measurement
  class Unit < Magnitude
    # Basic unit constructor. Either as
    # u = Unit.basic of: quantity
    # or
    # u = Unit.basic quantity
    def self.basic opts
      new opts.merge( number: 1 )
    end

    PREFIX_TABLE.map{|e| e[:full] }.each{ |full_pfx|
      eval( "def #{full_pfx}\n" +
            "self * #{PREFIXES[full_pfx][:factor]}\n" +
            "end" ) unless full_pfx.empty?
    }

    # Unlike ordinary magnitudes, units can have names and abbreviations.
    attr_reader :name, :abbr
    alias :short :abbr
    alias :symbol :abbr

    def initialize oj
      super
      @name = oj[:name] || oj[:ɴ]
      # abbreviation can be introduced by multiple keywords
      @abbr = oj[:short] || oj[:abbreviation] || oj[:abbr] || oj[:symbol]
      if @name then
        # no prefixed names, otherwise there will be multiple prefixes!
        @name = @name.to_s              # convert to string
        # the unit name is entered into the UNITS_WITHOUT_PREFIX table:
        UNITS_WITHOUT_PREFIX[@name] = self
        # and FAV_UNITS table keys are updated:
        FAV_UNITS[quantity] = FAV_UNITS[quantity] + [ self ]
      end
      if @abbr then
        raise ArgumentError unless @name.present? # name must be given if abbreviation is given
        # no prefixed abbrevs, otherwise there will be multiple prefixes!
        @abbr = @abbr.to_s           # convert to string
        # the unit abbrev is entered into the UNITS_WITHOUT_PREFIX table
        UNITS_WITHOUT_PREFIX[abbr] = self
      end
    end

    # #abs absolute value - Magnitude with number.abs
    def abs; Magnitude.of quantity, number: n.abs end
      
    # addition
    def + other
      aE_same_quantity( other )
      Magnitude.of( quantity, n: self.n + other.n )
    end

    # subtraction
    def - other
      aE_same_quantity( other )
      Magnitude.of( quantity, n: self.n - other.n )
    end

    # multiplication
    def * other
      case other
      when Magnitude
        Magnitude.of( quantity * other.quantity, n: self.n * other.n )
      when Numeric then [1, other]
        Magnitude.of( quantity, n: self.n * other )
      else
        raise ArgumentError, "magnitudes only multiply with magnitudes and numbers"
      end
    end

    # division
    def / other
      case other
      when Magnitude
        Magnitude.of( quantity / other.quantity, n: self.n / other.n )
      when Numeric then [1, other]
        Magnitude.of( quantity, n: self.n / other )
      else
        raise ArgumentError, "magnitudes only divide by magnitudes and numbers"
      end
    end

    # power
    def ** arg
      return case arg
             when Magnitude then self.n ** arg.n
             else
               raise ArgumentError unless arg.is_a? Numeric
               Magnitude.of( quantity ** arg, n: self.n ** arg )
             end
    end

    # #basic? inquirer
    def basic?; @number == 1 end
  end # class Unit

  # Constants
  Nᴀ = AVOGADRO_CONSTANT = 6.02214e23
  
  # Basic quantities
  LENGTH = Quantity.standard of: "L", ɴ: "LENGTH"
  MASS = Quantity.standard of: "M", ɴ: "MASS"
  TIME = Quantity.standard of: "T", ɴ: "TIME"
  ELECTRIC_CHARGE = Quantity.standard of: "Q", ɴ: "ELECTRIC CHARGE"
  TEMPERATURE = Quantity.standard of: "Θ", ɴ: "TEMPERATURE"
  
  # Basic units of basic quantities
  METRE = LENGTH.name_basic_unit "metre", symbol: "m"
  SECOND = TIME.name_basic_unit "second", symbol: "s"
  KELVIN = TEMPERATURE.name_basic_unit "kelvin", symbol: "K"
  GRAM = MASS.name_basic_unit "gram", symbol: "g"
  COULOMB = ELECTRIC_CHARGE.name_basic_unit "coulomb", symbol: "C"

  # Derived units of basic quantities
  DALTON = Unit.of MASS, name: "dalton", symbol: "Da", number: 1.66053892173e-24
  MINUTE = Unit.of TIME, ɴ: "minute", abbr: "min", n: 60
  HOUR = Unit.of TIME, ɴ: "hour", abbr: "h", n: 60
  
  # Derived quantities
  SPEED = LENGTH / TIME
  SPEED.name = "Speed"

  ACCELERATION = SPEED / TIME
  ACCELERATION.name = "Acceleration"

  FORCE = ACCELERATION * MASS
  FORCE.name = "Force"
  NEWTON = Unit.of FORCE, name: "newton", symbol: "N", number: 1000

  ENERGY = FORCE * LENGTH
  ENERGY.name = "Energy"
  JOULE = Unit.of ENERGY, name: "joule", symbol: "J", number: 1000
  CALORIE = Unit.of ENERGY, name: "calorie", symbol: "cal", number: 1000 / 4.2

  POWER = ENERGY / TIME
  POWER.name = "Power"
  WATT = Unit.of POWER, name: "watt", symbol: "W", number: 1000

  AREA = LENGTH ** 2
  AREA.name = "Area"

  VOLUME = LENGTH ** 3
  VOLUME.name = "Volume"
  LITRE = Unit.of VOLUME, name: "litre", symbol: "l", number: 1e-3

  PRESSURE = FORCE / AREA
  PRESSURE.name = "Pressure"
  PASCAL = Unit.of PRESSURE, name: "pascal", symbol: "Pa", number: 1000

  # instead of amount of substance:
  AMOUNT = Quantity.dimensionless name: "Amount"
  UNIT = AMOUNT.name_basic_unit "unit" # simply so, "one unit"
  MOLE = Unit.of AMOUNT, ɴ: "mole", symbol: "mol", number: Nᴀ

  MOLARITY = AMOUNT / VOLUME
  MOLARITY.name = "Molarity"
  MOLAR = Unit.of MOLARITY, ɴ: "molar", symbol: "M", n: (MOLE / LITRE).n

  ELECTRIC_CURRENT = ELECTRIC_CHARGE / TIME
  ELECTRIC_CURRENT.name = "Electric current"
  AMPERE = ELECTRIC_CURRENT.name_basic_unit "ampere", symbol: "A"

  ELECTRIC_POTENTIAL = ENERGY / ELECTRIC_CHARGE
  ELECTRIC_POTENTIAL.name = "Electric potential"
  VOLT = Unit.of ELECTRIC_POTENTIAL, name: "volt", symbol: "V", number: 1000

  ABSOLUTE_TEMPERATURE =
    Quantity.of TEMPERATURE.dimension, ɴ: "Absolute temperature"
  CELSIUS = Unit.of ABSOLUTE_TEMPERATURE, ɴ: "celsius", abbr: "°C", n: 1

  FREQUENCY = Quantity.of "T⁻¹", name: "Frequency" 
  HERTZ = FREQUENCY.name_basic_unit "hertz", short: "Hz"
 
  # LATER: it would be cool if this worked:
  # AMPERE = Unit.of ELECTRIC_CURRENT, ɴ: "ampere", symbol: "A", as: "C.s⁻¹"
  
  # LATER:
  # alias :Celsius :celsius
  # alias :degree_celsius :celsius
  # alias :degree_Celsius :celsius
  # alias :°C :celsius                 # with U+00B0 DEGREE SIGN
  # alias :˚C :celsius                 # with U+02DA RING ABOVE
  # alias :℃ :celsius                  # U+2103 DEGREE CELSIUS

  # alias :Fahrenheit :fahrenheit
  # alias :degree_fahrenheit :fahrenheit
  # alias :degree_Fahrenheit :fahrenheit
  # alias :°F :fahrenheit              # with U+00B0 DEGREE SIGN
  # alias :˚F :fahrenheit              # with U+02DA RING ABOVE
  # alias :℉ :fahrenheit               # U+2109 DEGREE FAHRENHEIT


  # LATER:
  
  # it would be cool if this worked
  # MOLAR = Unit.of MOLARITY, ɴ: "molar", symbol: "M", as: MOLE / LITRE
  # or even this
  # MOLAR = MOLE / LITRE
  # MOLAR.name = "molar"
  # MOLAR.symbol = "M"
  # ( MOLARITY = MOLAR.quantity ).name = "Molarity"
  
  #   def degree; "%s degrees" % self end
  #   alias :deg :degree
  #   alias :° :degree
  #   def arcminute; "%s arcminutes" % self end
  #   alias :arcmin :arcminute
  #   alias :amin :arcminute
  #   alias :am :arcminute
  #   alias :MOA :arcminute
  #   alias :ʹ :arcminute
  #   alias :′ :arcminute
  #   def arcsecond; "%s arcseconds" % self end
  #   alias :ʹʹ :arcsecond
  #   alias :′′ :arcsecond
  #   alias :″ :arcsecond
end
