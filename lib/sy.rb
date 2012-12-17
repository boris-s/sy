#encoding: utf-8
require "sy/version"
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/array/extract_options'

module SY
  def self.included( receiver )
    ::Numeric.module_exec do
      include UnitMethodsMixin
    end
  end

  require_relative 'sy/unit_methods_mixin'

  # Basic dimensions of physical quantities.
  # 
  BASIC_DIMENSIONS =
    { L: :LENGTH, M: :MASS, T: :TIME, Q: :ELECTRIC_CHARGE, Θ: :TEMPERATURE }
  
  # Basic dimension symbols (letters).
  # 
  DIMENSION_LETTERS = BASIC_DIMENSIONS.keys
  
  # Dimensions more or less have their standard quantities,
  # which, once defined, will be held in this hash table as pairs
  # of { dimension array => standard quantity }.
  # 
  QUANTITIES = {}

  # Unit table. Defined units { unit_name => unit_instance } and
  # { unit_abbreviation ("symbol") => unit_instance }
  # 
  UNITS_WITHOUT_PREFIX = {}

  # Basic units for metrological quantities.
  # (Hash of { metrological_quantity => basic_unit }.)
  # 
  BASIC_UNITS = Hash.new {|hsh, qnt| Unit.basic of: qnt }

  # Apart from basic units, it commonly happens that other units are favored.
  # They are held in this hash as pairs of
  # { metrological_quantity => [ array of favored units ] }.
  # 
  FAV_UNITS = Hash.new []

  # Table of prefixes and their corresponding unit multiples.
  # 
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
  
  # Valid prefixes as a list (simple array).
  # 
  PREFIXES = PREFIX_TABLE.each_with_object( Hash.new ) {|row, ꜧ| ꜧ[row[:full]] = row
                                                    ꜧ[row[:short]] = row }
  
  # Unicode superscript exponents.
  # 
  SUPERSCRIPT = Hash.new { |ꜧ, key|
    if key.is_a? String then
      key.size <= 1 ? nil : key.each_char.map{|c| ꜧ[c] }.join
    else
      ꜧ[key.to_s]
    end
  }.merge! Hash[ '-/0123456789'.each_char.zip( '⁻⎖⁰¹²³⁴⁵⁶⁷⁸⁹'.each_char ) ]
  
  # Reverse conversion (from exponent strings to fixnums).
  # 
  SUPERSCRIPT_DOWN = Hash.new { |ꜧ, key|
    if key.is_a? String then
      key.size == 1 ? nil : key.each_char.map{|c| ꜧ[c] }.join
    else
      ꜧ[key.to_s]
    end }
    .merge!( SUPERSCRIPT.invert )
    .merge!( '¯' => '-',
             '´' => '/' )
  
  # SPS stands for "superscripted product string".
  # 
  SPS = lambda { |ßs, exps|
    raise ArgumentError unless ßs.size == exps.size
    exps = exps.map{|e| Integer e }
    zipped = ßs.zip( exps )
    clean = zipped.reject {|e| e[1] == 0 }
    # omit exponents equal to 1:
    clean.map{|ß, exp| "#{ß}#{exp == 1 ? "" : SUPERSCRIPT[exp]}" }.join "."
  }

  # Singleton #inspect method for SPS.
  # 
  def SPS.inspect
    "Superscripted product string constructor lambda." +
      "Takes 2 arguments. Example: [:a, :b], [-1, 2] #=> a⁻¹b²."
  end
  
  # This is a closure that takes 3 arguments: a string to be parsed,
  # an array of acceptable symbols, and an array of acceptable prefixes.
  # It returns 3 equal-sized arrays: prefixes, symbols and exponents.
  # 
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

  # Singleton #inspect method for SPS_PARSER.
  # 
  def SPS_PARSER.inspect
    "Superscripted product string parser lambda. " +
      "Takes 2 compulsory and 1 optional argument. Example: " +
      '"kB.s⁻¹", [:g, :B, :s, :C], [:M, :k, :m, :µ] #=> ["k", ""], ' +
      '["B", "s"], [1, -1]'
  end

  require_relative 'sy/dimension'
  require_relative 'sy/quantity'
  require_relative 'sy/magnitude'
  require_relative 'sy/unit'

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
  # monkey patch addition t1 + t2 to call
  # t2.coerce t1 and if t1 is some sort of temperature (of temperature
  # dimension), then return [ t1.( ABSOLUTE_TEMPERATURE ) t2.( TEMPERATURE_DIFFERENCE ) ]
  # and then addition and subtraction should require temperature difference as their
  # second parameter.
  # Coerce should should be able to convert TEMPERATURE into ABSOLUTE as well as
  # RELATIVE TEMPERATURE, also convert TEMPERATURE_DIFFERENCE into ABSOLUTE_TEMPERATURE,
  # but should avoid the opposite, ie. converting ABSOLUTE_TEMPERATURE into TEMPERATURE
  # DIFFERENCE - this should have to be done explicitly by .( TEMPERATURE )
  CELSIUS = Unit.of ABSOLUTE_TEMPERATURE, ɴ: "celsius", abbr: "°C", n: 1
  TEMPERATURE_DIFFERENCE =
    Quantity.of TEMPERATURE.dimension, name: "Relative temperature"

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
