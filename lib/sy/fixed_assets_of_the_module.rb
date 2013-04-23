# -*- coding: utf-8 -*-
# Here, fixed assets of the main module are set up.
# 
module SY
  # Basic physical dimensions.
  # 
  BASE_DIMENSIONS = {
    L: :LENGTH,
    M: :MASS,
    Q: :ELECTRIC_CHARGE,
    Θ: :TEMPERATURE,
    T: :TIME
  }

  class << BASE_DIMENSIONS
    # Letters of base dimensions.
    # 
    def letters
      keys
    end

    # Base dimensions letters with prefixes.
    # 
    def prefixed_letters
      [] # none for now
    end

    # Base dimension symbols – letters and prefixed letters.
    # 
    def base_symbols
      @baseß ||= letters + prefixed_letters
    end
    alias basic_symbols base_symbols

    # Takes an sps representing a dimension, and converts it to a hash of
    # base dimension symbols => exponents.
    # 
    def parse_sps( sps )
      _, letters, exponents = ::SY::SPS_PARSER.( sps, self.letters )
      return Hash[ letters.map( &:to_sym ).zip( exponents.map( &:to_i ) ) ]
    end
  end

  # Table of standard prefixes and their corresponding unit multiples.
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


  class << PREFIX_TABLE
    # List of full prefixes.
    # 
    def full_prefixes
      @full ||= map { |row| row[:full] }
    end

    # List of prefix abbreviations.
    # 
    def prefix_abbreviations
      @short ||= map { |row| row[:short] }
    end
    alias short_prefixes prefix_abbreviations

    # List of full prefixes and short prefixes.
    # 
    def all_prefixes
      @all ||= full_prefixes + prefix_abbreviations
    end

    # Parses an SPS using a list of permitted unit symbols, currying it with
    # own #all_prefixes.
    # 
    def parse_sps sps, unit_symbols
      SY::SPS_PARSER.( sps, unit_symbols, all_prefixes )
    end

    # A hash of clue => corresponding_row pairs.
    # 
    def row clue
      ( @rowꜧ ||= Hash.new do |ꜧ, key|
          case key
          when Symbol then
            rslt = ꜧ[key.to_s]
            ꜧ[key] = rslt if rslt
          else
            r = find { |r|
              r[:full] == key || r[:short] == key || r[:factor] == key
            }
            ꜧ[key] = r if r
          end
        end )[ clue ]
    end

    # Converts a clue to a full prefix.
    # 
    def to_full clue
      ( @fullꜧ ||= Hash.new do |ꜧ, key|
          result = row( key )
          result = result[:full]
          ꜧ[key] = result if result
        end )[ clue ]
    end

    # Converts a clue to a prefix abbreviation.
    # 
    def to_short clue
      ( @shortꜧ ||= Hash.new do |ꜧ, key|
          result = row( key )[:short]
          ꜧ[key] = result if result
        end )[ clue ]
    end

    # Converts a clue to a factor.
    # 
    def to_factor clue
      ( @factorꜧ ||= Hash.new do |ꜧ, key|
          result = row( key )[:factor]
          ꜧ[key] = result if result
        end )[ clue ]
    end
  end

  # Unicode superscript exponents.
  # 
  SUPERSCRIPT = Hash.new { |ꜧ, key|
    if key.is_a? String then
      key.size <= 1 ? nil : key.each_char.map{|c| ꜧ[c] }.join
    else
      ꜧ[key.to_s]
    end
  }.merge! Hash[ '-/0123456789'.each_char.zip( '⁻⎖⁰¹²³⁴⁵⁶⁷⁸⁹'.each_char ) ]

  # Reverse conversion of Unicode superscript exponents (from exponent
  # strings to fixnums).
  # 
  SUPERSCRIPT_DOWN = Hash.new { |ꜧ, key|
    if key.is_a? String then
      key.size == 1 ? nil : key.each_char.map{|c| ꜧ[c] }.join
    else
      ꜧ[key.to_s]
    end
  }.merge!( SUPERSCRIPT.invert ).merge!( '¯' => '-', # other superscript chars
                                         '´' => '/' )

  # SPS stands for "superscripted product string", It is a string of specific
  # symbols with or without Unicode exponents, separated by periods, such as
  # "syma.symb².symc⁻³.symd.syme⁴" etc. This closure takes 2 arguments (array
  # of symbols, and array of exponents) and produces an SPS out of them.
  # 
  SPS = lambda { |ßs, exps|
    raise ArgumentError unless ßs.size == exps.size
    exps = exps.map{|e| Integer e }
    zipped = ßs.zip( exps )
    clean = zipped.reject {|e| e[1] == 0 }
    # omit exponents equal to 1:
    clean.map{|ß, exp| "#{ß}#{exp == 1 ? "" : SUPERSCRIPT[exp]}" }.join "."
  }

  # Singleton #inspect method for SPS-making closure.
  # 
  def SPS.inspect
    "Superscripted product string constructor lambda." +
      "Takes 2 arguments. Example: [:a, :b], [-1, 2] #=> a⁻¹b²."
  end

  # A closure that parses superscripted product strings (SPSs). It takes 3
  # arguments: a string to be parsed, an array of acceptable symbols, and
  # an array of acceptable prefixes. It returns 3 equal-sized arrays: prefixes,
  # symbols and exponents.
  # 
  SPS_PARSER = lambda { |input_ς, ßs, prefixes = []|
    input_ς = input_ς.to_s.strip
    ßs = ßs.map &:to_s
    prefixes = ( prefixes.map( &:to_s ) << '' ).uniq
    # input string splitting
    input_ς_sections = input_ς.split '.'
    if input_ς_sections.empty?
      raise NameError, "Bad input string: '#{input_ς}'!" unless input_ς.empty?
      return [], [], []
    end
    # analysis of input string sections
    input_ς_sections.each_with_object [[], [], []] do |_section_, memo|
      section = _section_.dup
      superscript_chars = SUPERSCRIPT.values
      # chop off the superscript tail, if any
      section.chop! while superscript_chars.any? { |ch| section.end_with? ch }
      # the set of candidate unit symbols
      candidate_ßs = ßs.select { |ß| section.end_with? ß }
      # seek candidate prefixes corresponding to candidate_ßs
      candidate_prefixes = candidate_ßs.map { |ß| section[ 0..((-1) - ß.size) ] }
      # see which possible prefixes can be confirmed
      confirmed_prefixes = candidate_prefixes.select { |x| prefixes.include? x }
      # complain if no symbol matches sec
      raise NameError, "Unknown unit: '#{section}'!" if confirmed_prefixes.empty?
      # pay attention to ambiguity in prefix/symbol pair
      if confirmed_prefixes.size > 1 then
        if confirmed_prefixes.any? { |x| x == '' } then # prefer empty prefixes
          chosen_prefix = ''
        else
          raise NameError, "Ambiguity in interpretation of '#{section}'!"
        end
      else
        chosen_prefix = confirmed_prefixes[0]
      end
      # Based on it, interpret the section parts:
      unit_ς = section[ (chosen_prefix.size)..(-1) ]
      suffix = _section_[ ((-1) - chosen_prefix.size - unit_ς.size)..(-1) ]
      # Make the exponent string suffix into the exponent number:
      exponent_ς = SUPERSCRIPT_DOWN[ suffix ]
      # Complain if bad:
      raise NameError, "Malformed exponent in #{_section_}!" if exponent_ς.nil?
      exponent_ς = "1" if exponent_ς == '' # empty exponent string means 1
      exp = Integer exponent_ς
      raise NameError, "Zero exponents not allowed: #{exponent_ς}" if exp == 0
      # and store the interpretation
      memo[0] << chosen_prefix; memo[1] << unit_ς; memo[2] << exp
      memo
    end
  }

  # Singleton #inspect method for SPS-parsing closure.
  # 
  def SPS_PARSER.inspect
    "Superscripted product string parser lambda. " +
      "Takes 2 compulsory and 1 optional argument. Example: " +
      '"kB.s⁻¹", [:g, :B, :s, :C], [:M, :k, :m, :µ] #=> ["k", ""], ' +
      '["B", "s"], [1, -1]'
  end

  # Mainly for mixing incompatible quantities.
  # 
  class QuantityError < StandardError; end

  # Mainly for mixing incompatible dimensions.
  # 
  class DimensionError < StandardError; end

  # Mainly for negative or otherwise impossible physical amounts.
  # 
  class MagnitudeError < StandardError; end

  # Convenience dimension accessor.
  # 
  def Dimension id=proc{ return ::SY::Dimension }.call
    case id.to_s
    when '', 'nil', 'null', 'zero', '0', '⊘', '∅', 'ø' then SY::Dimension.zero
    else SY::Dimension.new id end
  end

  # Convenience quantity instance accessor.
  # 
  def Quantity id=proc{ return ::SY::Quantity }.call
    SY::Quantity.instance id
  end

  # Convenience unit instance accessor.
  # 
  def Unit id=proc{ return ::SY::Unit }.call
    SY::Unit.instance id
  end

  # Explicit magnitude constructor.
  # 
  def Magnitude args=proc{ return ::SY::Magnitude }.call
    args.must_have :quantity, syn!: :of
    qnt = args.delete :quantity
    SY::Magnitude.of qnt, args
  end

  module_function :Dimension, :Quantity, :Unit, :Magnitude
end
