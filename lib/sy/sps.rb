#encoding: utf-8

require 'y_support/literate'

# Sps string expresses a product of a certain number of symbols
# raised to certain exponents. Multiplication is expressed by the
# '.' (period) character, exponentiation is expressed by digits in
# Unicode superscript (⁰, ¹, ⁻¹, ², ⁻², ...). Symbols can be any
# strings, but since this class is an ancestor of SY::Unit::Sps,
# SY::Quantity::Sps and SY::Dimension::Sps, the symbols will
# typically be units ("metre", "kilojoule", "milisecond", ...),
# quantities ("Length", "Area", "Mass") or dimensions ("L.T⁻¹",
# ...). Omitting the superscript exponent means that exponent == 1.
# Apart from the set of admissible symbols, the constructor also
# accepts the set of admissible prefixes ("kilo", "mili", ...).
# 
class SY::Sps < String
  class << self
    # The instance can be constructed either from an array of
    # triples [ prefix, symbol, exponent ], or from an array of
    # pairs [ symbol, exponent ], or from a hash of pairs
    # { symbol => exponent }, or from a string which is a valid
    # Sps.
    # 
    def new( arg, symbols:, prefixes: [] )
      arg = argument( arg ).must.not_be_nil
      str = "collection".( arg ).try "to convert to an sps" do
        case self
        when Array, Hash then
          tuples_to_sps( self )
        else
          « "was assumed to indicate a valid Sps"
          String( self )
        end
      end
      # At this point, arg is a valid sps -- it was either supplied
      # by the caller, or implied from the triples/pairs. We
      # proceed by parsing this sps back into triples.
      triples = parse( str, symbols: symbols, prefixes: prefixes )
      # Make sure the triples are OK.
      validate_triples triples,
                       symbols: symbols,
                       prefixes: prefixes
      # Triples are now standardized and validated. We proceed by
      # converting them once again into an sps, which is now
      # guaranteed to be OK.
      instance = super tuples_to_sps triples
      # Customize, validate and return the instance.
      customize( instance,
                 symbols: symbols,
                 prefixes: prefixes )
      return instance.validate
    end
    
    private

    # Takes one string as an argument and parses it using a given
    # set of acceptable symbols and prefixes. It returns an array
    # of factors represented as triples [ prefix, symbol, exponent
    # ], where prefix and symbol are strings, and exponent is an
    # integer.
    #
    def parse( string, symbols:, prefixes: [] )
      symbols = symbols.map &:to_s
      prefixes = ( prefixes.map( &:to_s ) << '' ).uniq
      sections = string.split '.' # Split the string into factors.
      if sections.empty?          # Handle the empty string case.
        fail TypeError, "Unable to parse: '#{string}'!" unless
          string.empty?
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
        # Find candidate prefixes corresp. to possible symbols.
        possible_prefixes =
          possible_ßs.map { |ß| s[ 0..((-1) - ß.size) ] }
        # See which possible prefixes can be confirmed.
        confirmed_prefixes =
          possible_prefixes.select { |x| prefixes.include? x }
        # Complain if no symbol matches the section.
        fail TypeError, "Unknown symbol: '#{s}'!" if
          confirmed_prefixes.empty?
        # Note if ambiguity is present in prefix/symbol pair.
        if confirmed_prefixes.size > 1 then
          if confirmed_prefixes.any? { |x| x == '' } then
            prefix = '' # prefer empty prefixes
          else
            fail TypeError, "Ambiguity present in '#{s}'!"
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
        fail TypeError, "Zero exponents not allowed: #{section}" if
          exp.zero?
        a << [ prefix, symbol, exp ] # store the parsed triple
      end
    end

    # Constructs a string from the supplied collection of tuples
    # representing the factors of an Sps.
    #
    def tuples_to_sps( tuples )
      tuples.to_a            # convert to array (if hash was given)
        .map { |*h, exp|     # convert to pairs
          [ h.join, SY::Se.new( exp ) ]
        }.reject { |_, se|      # reject zero exponents
          se.to_int.zero?
        }.map { |h, se|         # disregard exponents == 1
          [h, (se.to_int == 1 ? '' : se)]
        }.map( &:join ).join '.' # join the resulting string with .
    end

    # Normalizes an array of triples denoting the sps factors. Each
    # triple must be of form [ prefix, symbol, exponent ], where
    # prefix and symbol are strings and exponent an integer.
    #
    def validate_triples( triples, symbols:, prefixes: )
      hash = triples.each_with_object Hash.new do
        |(pfx, sym, exp), o|
        ß = normalize_symbol( sym )
        o.merge!( { ß => [ pfx, exp ] } ) { |ß, _, _|
          fail TypeError, "Double occurence of symbol '#{sym}'!"
        }
      end
      return triples
    end

    # Normalizes a symbol. It means that if there are multiple
    # versions of the same symbol (such as :L/:LENGTH, or
    # :metre/:m), it returns the standard version of the symbol.
    #
    def normalize_symbol( sym )
      return sym
    end
    
    # Customizes the supplied instance with symbols and prefixes.
    # In other words, an Sps instance can be customized so as to
    # have its own private set of symbols and prefixes. I forgot
    # why did I need this, but I knew what I was doing when I
    # committed this method.
    # 
    def customize( instance, symbols:, prefixes: )
      instance.instance_exec do
        @symbols = symbols.map( &:to_s )
        @prefixes = ( prefixes.map( &:to_s ) << '' ).uniq
      end
    end
  end

  selector :symbols, :prefixes

  # Converts the receiver into an array of factors represented as
  # triples [ prefix, symbol, exponent ]. Relies on the class
  # method of the same name.
  #
  def parse
    self.class.send :parse, self,
                    symbols: self.symbols,
                    prefixes: self.prefixes
  end

  # Converts the receiver into a hash of pairs { symbol: exponent }
  # or { prefix + symbol => exponent } if there is a prefix.
  # 
  def to_hash
    Hash[ parse.map { |*head, exp| [ head.join, exp ] } ]
  end

  # Validates whether the receiver is a valid Sps under the given
  # set of symbols and prefixes. Raises TypeError if not. Returns
  # self.
  # 
  def validate( symbols: self.symbols, prefixes: self.prefixes )
    self.class.send :parse, self,
                    symbols: symbols,
                    prefixes: prefixes
    return self
  end
end # class SY::Sps
