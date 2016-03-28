#encoding: utf-8

# require 'y_support/core_ext/class'

# This class represents a product (multiplication) of some symbols (such as
# "meter", "joule", "second") with some prefixes (such as "kilo", "mega",
# "giga") expressed as a string. The factors may be raised to exponents
# expressed as superscript digits.  Examples: "kg.m.s⁻²", "L.θ⁻¹",
# "LENGTH.TIME⁻¹", "a⁻¹b²"...
# 
class SY::Sps < String
  class << self
    # The argument can be constructed either from an array of tuples
    # representing the Sps factors, or an array of pairs representing the
    # same, or a hash, or, alternatively, a valid string form can be given.
    #
    # Examples:
    # [[ :k, :m, 1 ], [ '', 'h', -1 ]] #=> "km.h⁻¹"
    # { km: 1, h: -1 } #=> "km.h⁻¹"
    # "km.h⁻¹" #=> "km.h⁻¹"
    # 
    def new( arg,
             symbols: fail( ArgumentError, "Symbols not given!" ),
             prefixes: [] )
      fail ArgumentError, "Nil argument not acceptable!" if arg.nil?
      # Construct the superscripted string from the input.
      str = case arg
            when Array, Hash then # It is a collection of tuples.
              to_sps( arg )     # Convert to string.
            else String arg end # It is assumed to be a string.
      # Normalize the input and construct the instance from it.
      triples = parse( str, symbols: symbols, prefixes: prefixes )
      validate_triples( triples, symbols: symbols, prefixes: prefixes )
      instance = super to_sps triples
      # Customize, validate and return the instance.
      customize( instance, symbols: symbols, prefixes: prefixes )
      return instance.validate
    end
    
    private

    # Takes one string as an argument and parses it using a given set of
    # acceptable symbols and prefixes. It returns an array of factors
    # represented as triples [ prefix, symbol, exponent ], where prefix
    # and symbol are strings, and exponent is an integer.
    #
    def parse( string,
               symbols: fail( ArgumentError, "Symbols not given!" ),
               prefixes: [] )
      symbols = symbols.map &:to_s
      prefixes = ( prefixes.map( &:to_s ) << '' ).uniq
      sections = string.split '.' # Split the string into factors.
      if sections.empty?          # Handle the empty string case.
        fail TypeError, "Unable to parse: '#{string}'!" unless string.empty?
        return []
      end
      # Parse the string sections.
      sections.each_with_object [] do |section, a|
        s = section.dup
        superscript_chars = SY::Se::TABLE.values
        # Chop off the superscript tail of the section.
        s.chop! while superscript_chars.any? { |c| s.end_with? c }
        # Construct the set of possible unit symbols.
        possible_ßs = symbols.select { |ß| s.end_with? ß }
        # Find candidate prefixes corresponding to possible symbols.
        possible_prefixes = possible_ßs.map { |ß| s[ 0..((-1) - ß.size) ] }
        # See which possible prefixes can be confirmed.
        confirmed_prefixes = possible_prefixes.select { |x| prefixes.include? x }
        # Complain if no symbol matches the section.
        fail TypeError, "Unknown symbol: '#{s}'!" if confirmed_prefixes.empty?
        # Note if ambiguity is present in prefix/symbol pair.
        if confirmed_prefixes.size > 1 then
          if confirmed_prefixes.any? { |x| x == '' } then # prefer empty prefixes
            prefix = ''
          else
            fail TypeError, "Ambiguity in interpretation of '#{s}'!"
          end
        else
          prefix = confirmed_prefixes[0]
        end
        # Based on the chosen prefix, find the chosen symbol.
        symbol = s[ (prefix.size)..(-1) ]
        # Single out the exponent suffix.
        begin
          suffix_size = section.size - prefix.size - symbol.size
          se = SY::Se.new section[ -suffix_size, suffix_size ]
        rescue ArgumentError, TypeError
          fail TypeError, "Malformed exponent in #{section}!"
        end
        exp = se.to_int
        fail TypeError, "Zero exponents not allowed: #{section}" if exp.zero?
        a << [ prefix, symbol, exp ] # store the parsed triple
      end
    end

    # Constructs a string from the supplied collection of tuples representing
    # the factors of an Sps.
    #
    def to_sps( tuples )
      tuples.to_a                   # convert to array (if hash was given)
        .map { |*h, exp| [ h.join, SY::Se.new( exp ) ] } # convert to pairs
        .reject { |_, se| se.to_int.zero? } # reject zero exponents
        .map { |h, se| [h, (se.to_int == 1 ? '' : se)] } # disregard exponents 1
        .map( &:join ).join '.' # join the resulting string with dots
    end

    # Normalizes an array of triples representing the factors of an Sps. Each
    # triple must be of form [ prefix, symbol, exponent ], where prefix and
    # symbol are strings, and exponent is an integer.
    #
    def validate_triples triples,
                         symbols: fail( ArgumentError, "Symbols not given!" ),
                         prefixes: fail( ArgumentError, "Prefixes not given!" )
      hash = triples.each_with_object Hash.new do |(pfx, sym, exp), o|
        ß = normalize_symbol( sym )
        o.merge!( { ß => [ pfx, exp ] } ) { |ß, _, _|
          fail TypeError, "Double occurence of symbol '#{sym}'!"
        }
      end
      return triples
    end

    # Normalizes a symbol.
    #
    def normalize_symbol( sym )
      return sym
    end
    
    # Customizes the supplied instance with symbols and prefixes.
    # 
    def customize( instance,
                   symbols: fail( ArgumentError, "Symbols not given!" ),
                   prefixes: fail( ArgumentError, "Prefixes not given!" ) )
      instance.instance_exec do
        @symbols = symbols.map( &:to_s )
        @prefixes = ( prefixes.map( &:to_s ) << '' ).uniq
      end
    end
  end

  selector :symbols, :prefixes

  # Converts the receiver into an array of factors represented as triples
  # [ prefix, symbol, exponent ]. Relies on the class method of the same name.
  #
  def parse
    self.class.send :parse, self, symbols: self.symbols, prefixes: self.prefixes
  end

  # Converts the receiver into a hash of pairs { symbol: exponent } or
  # { prefix + symbol => exponent } if there is a prefix.
  # 
  def to_hash
    Hash[ parse.map { |*head, exp| [ head.join, exp ] } ]
  end

  # Validates whether the receiver is a valid Sps under the given set of
  # symbols and prefixes. Raises TypeError if not. Returns self.
  # 
  def validate( symbols: self.symbols, prefixes: self.prefixes )
    self.class.send :parse, self, symbols: symbols, prefixes: prefixes
    return self
  end
end # class SY::Sps
