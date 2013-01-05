#encoding: utf-8

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

  # #letters singleton method is an alias for #keys
  # 
  BASE_DIMENSIONS.define_singleton_method :letters do keys end

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

  # Valid full prefixes rendered as a list (simple array).
  # 
  def PREFIX_TABLE.full
    map { |row| row[:full] }
  end

  # Valid shortened prefixes rendered as a list (simple array).
  # 
  def PREFIX_TABLE.short
    map { |row| row[:short] }
  end

  # A hash of full prefixes => corresponding rows.
  # 
  def PREFIX_TABLE.hash_full
    each_with_object Hash.new do |row, memo_hash|
      memo_hash[ row[:full] ] = row
    end
  end

  # A hash of short prefixes => corresponding rows.
  # 
  def PREFIX_TABLE.hash_short
    each_with_object Hash.new do |row, memo_hash|
      memo_hash[ row[:short] ] = row
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
      puts "Parser: #{chosen_prefix} + #{unit_ς} + #{exp}" if SY::DEBUG
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

  # Custom error class for attempts to create negative magnitudes.
  # 
  class NegativeAmountError < StandardError; end

  # Custom error class for attempts to mix incompatible quantities.
  # 
  class IncompatibleQuantityError < StandardError; end


  # Convenience dimension accessor.
  # 
  def Dimension dim_spec=proc{ return SY::Dimension }.call
    case dim_spec.to_s
    when '', 'nil', 'null', 'zero', '0', '⊘', 'ø' then ::SY::Dimension.zero
    else ::SY::Dimension.new dim_spec end
  end

  # Convenience quantity instance accessor.
  # 
  def Quantity quantity_spec=proc{ return ::SY::Quantity }.call
    ::SY::Quantity.instance quantity_spec
  end

  # Convenience unit instance accessor.
  # 
  def Unit unit_spec
    ::SY::Unit.instance unit_spec
  end

  # Explicit magnitude constructor.
  # 
  def Magnitude *args
    if args.empty? then ::SY::Magnitude else
      ::SY::Magnitude.new *args
    end
  end

  module_function :Dimension, :Quantity, :Unit, :Magnitude
end
