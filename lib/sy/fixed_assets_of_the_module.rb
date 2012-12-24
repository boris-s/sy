#encoding: utf-8

# Here, fixed assets of the main module are set up.
# 
module SY
  # Basic physical dimensions.
  # 
  BASIC_DIMENSIONS = {
    L: :LENGTH,
    M: :MASS,
    Q: :ELECTRIC_CHARGE,
    Θ: :TEMPERATURE,
    T: :TIME
  }

  # #letters singleton method is an alias for #keys
  # 
  BASIC_DIMENSIONS.define_singleton_method :letters do keys end

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
  SPS_PARSER = lambda { |input_string, ßs, prefixj = []|
    complaint = "unacceptable string: #{input_string}"
    # argument grooming
    input_string = input_string.to_s.strip
    ßs = ßs.map &:to_s
    prefixj = prefixj.map( &:to_s ) << ""
    # input string splitting
    input_string_sections = input_string.split '.'
    if input_string_sections.empty?
      raise NameError, complaint unless input_string.empty?
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
      raise NameError, complaint if possible_ßs.empty?
      # seek possible prefixes corresponding to possible_ßs
      possible_prefixes = possible_ßs.map{|ß| sec[0..-1 - ß.size] }
      # see which possible prefixj can be confirmed
      confirmed_prefixes = possible_prefixes.select{|pfx| prefixj.include? pfx }
      # warn if sec factors into more than one prefix/symbol pair
      warn "ambiguity in symbol #{sec} in #{input_string}" if
        confirmed_prefixes.size > 1
      # make sure that exactly one interpretation of sec exists
      raise NameError, complaint unless confirmed_prefixes.size == 1
      # based on it, interpret the section parts
      prefix = confirmed_prefixes[0]
      ß = sec[prefix.size..-1]
      suffix = section[-1 - prefix.size - ß.size..-1]
      # make suffix string into the exponent number
      exponent_string = SUPERSCRIPT_DOWN[suffix]
      raise NameError, complaint if exponent_string.nil? # complain if bad
      exponent_string = "1" if exponent_string == '' # no exp. means 1
      exp = Integer exponent_string
      raise NameError, "Zero exponents not allowed: #{exponent_string}" if exp == 0
      # and store the interpretation
      memo[0] << prefix; memo[1] << ß; memo[2] << exp
    }
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
end
