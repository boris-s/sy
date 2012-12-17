#encoding: utf-8

module SY
  # This class represents a dimension of a metrological quantity.
  # 
  class Dimension
    # Constructor for basic dimensions. Symbol signifying the basic
    # dimension is expected as the argument.
    # 
    def self.basic ß
      raise ArgumentError, "Unknown basic dimension symbol: #{ß}" unless
        ( DIMENSION_LETTERS + BASIC_DIMENSIONS.values ).include? ß.to_sym
      return new ß.to_sym => 1
    end

    # Constructor for zero dimension (as in "dimensionless").
    # 
    def self.zero
      new
    end

    # Constructor for zero dimension (as in "dimensionless").
    # 
    def self.null
      new
    end

    attr_accessor *DIMENSION_LETTERS

    # Dimension can be initialized either by supplying a hash
    # (such as Dimension.new L: 1, T: -2) or by supplying a SPS
    # (superscripted product string), such as Dimension.new( "L.T⁻²" ).
    # 
    def initialize arg = {}
      # Make sure that in any case, arg is converted to ꜧ
      ꜧ = if arg.respond_to? :keys then arg
          elsif arg.is_a? self.class then arg.to_hash
          else
            # assuming that we got a superscripted product string,
            # we will call SPS_PARSER on it (of course, no prefixes)
            prefixes, dimension_symbols, exponents =
              SPS_PARSER.( arg, DIMENSION_LETTERS )
            Hash[ dimension_symbols.map( &:to_sym ).zip( exponents ) ]
          end
      # Use the hash to initialize the instance:
      ꜧ = ꜧ.reverse_merge!( L: 0, M: 0, T: 0, Q: 0, Θ: 0 ).
        each_with_object Hash.new do |pair, ꜧ|
          ꜧ[pair[0]] = Integer( pair[1] )
        end
      @L, @M, @T, @Q, @Θ = ꜧ[:L], ꜧ[:M], ꜧ[:T], ꜧ[:Q], ꜧ[:Θ]
    end

    # #[] method provides access to the dimension components, such as
    # d = Dimension.new( L: 1, T: -2 ), d[:T] #=> -2
    # 
    def [] arg
      ß = arg.to_s.strip.to_sym
      if DIMENSION_LETTERS.include? ß then send ß else
        raise ArgumentError, "Unknown basic dimension symbol: #{ß}" unless
          BASIC_DIMENSIONS.values.include? ß
        send BASIC_DIMENSIONS.rassoc(ß)[0]
      end
    end

    # #== method – two dimensions are equal if their componets are equal.
    # 
    def == other
      # other must be a dimension
      raise ArgumentError unless
        other.is_a? self.class
      DIMENSION_LETTERS.map { |letter|
        self[letter] == other[letter]
      }.reduce( :& )
    end

    # Dimension arithmetic: addition. (+, -, *, /).
    # 
    def + other
      self.class.new Hash[ DIMENSION_LETTERS.map { |letter|
                             [ letter, self[letter] + other[letter] ]
                           } ]
    end

    # Dimension arithmetic: multiplication by a number.
    # 
    def * num
      self.class.new Hash[ DIMENSION_LETTERS.map { |letter|
                             [ letter, self[letter] * num ]
                           } ]
    end

    # Dimension arithmetic: subtraction.
    # 
    def - other
      self.class.new Hash[ DIMENSION_LETTERS.map { |letter|
                             [ letter, self[letter] - other[letter] ]
                           } ]
    end

    # Dimension arithmetic: division by a number. (Division only works
    # if all the exponents are divisible.)
    # 
    def / num
      ( exponents = to_a ).each{ |exponent|
        raise ArgumentError, "Dimension division by a number only requires " +
          "that all the dimension exponents be divisible by the number" unless
          exponent % num == 0
      }
      Dimension.new Hash[ DIMENSION_LETTERS
                            .zip( exponents.map { |exp| exp / num } ) ]
    end

    # Conversion to an array (of exponents of in the order of the
    # basic dimension letters).
    # 
    def to_a
      DIMENSION_LETTERS.map { |letter|
        self[letter]
      }
    end

    # Conversion to a hash (eg. { L: 1, M: 0, T: -2, Q: 0, Θ: 0 } ).
    # 
    def to_hash
      DIMENSION_LETTERS.each_with_object( {} ) { |letter, ꜧ|
        ꜧ[letter] = self[letter]
      }
    end

    # Returns true if the dimension is zero ("dimensionless"), otherwise false.
    # 
    def zero?
      [ @L, @M, @T, @Q, @Θ ] == [ 0, 0, 0, 0, 0 ]
    end

    def to_s                         # :nodoc:
      sps = SPS.( DIMENSION_LETTERS,
                  DIMENSION_LETTERS.map { |letter|
                    self[letter]
                  } )
      if sps == "" then "∅" else sps end
    end

    def inspect                      # :nodoc:
      if zero? then "Zero Dimension" else
        "Dimension[ #{self} ]"
      end
    end

    # Returns dimension's standard quantity from the table.
    # 
    def standard_quantity
      QUANTITIES[to_a]
    end

    delegate :fav_units, to: :standard_quantity
  end # class Dimension
end # module SY
