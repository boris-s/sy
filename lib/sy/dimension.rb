#encoding: utf-8

module SY
  # This class represents physical dimension of a metrological quantity.
  # 
  class Dimension
    class << self
      alias original_method_new new

      # Make return same instance if already present in instances
      def new *args
        hash = args.extract_options!
        if not args.empty? then
          # we got a superscripted product string or a Dimension instance
          # therefore, only one ordered argument is allowed:
          raise ArgumentError, "Too many ordered arguments!" unless
            args.size == 1
          # and no hash garbage is allowed:
          raise ArgumentError, "When an ordered argument is supplied, " +
            "no named arguments are allowed!" unless hash.empty?
          # now we can safely extract the single ordered argument:
          case arg = args[0]
          when self then # it is a dimension instance
            return arg   # return it straight
          when String, Symbol then # it is a superscripted product string
            # so let's unleash SPS_PARSER on it (of course, no prefixes)
            prefixes, dimension_symbols, exponents =
              ::SY::SPS_PARSER.( arg.to_s, ::SY::BASIC_DIMENSIONS.letters )
            hash = Hash[ dimension_symbols.map( &:to_sym ).zip( exponents ) ]
          else
            raise ArgumentError, "Wrong ordered argument type! (#{arg.class})"
          end
        end
        # now that the args have been conformed into hash, let's standardize it
        hash = hash.default!( L: 0, M: 0, T: 0, Q: 0, Θ: 0 )
          .each_with_object Hash.new do |pair, memo_hash|
            memo_hash[ pair[0] ] = Integer pair[1]
          end
        # in this form, it is measurable whether there are already any
        # instances of this dimension:
        instance = instances.find { |instance| instance.to_hash == hash }
        if instance then return instance else
          instance = original_method_new( hash )
          instances << instance
          return instance
        end
      end

      # Presents class-owned instances array.
      # 
      def instances
        return @instances ||= []
      end

      # Presents class-owned standard quantities array.
      # 
      def standard_quantities
        return @standard_quantities ||=
          Hash.new { |hash, instance| Quantity.of instance }
      end
    end

    # Constructor for basic dimensions. Symbol signifying the basic
    # physical dimension is expected as the argument.
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

    attr_accessor *BASIC_DIMENSIONS.letters

    # Dimension can be initialized either by supplying a hash
    # (such as Dimension.new L: 1, T: -2) or by supplying a SPS
    # (superscripted product string), such as Dimension.new( "L.T⁻²" ).
    # It is also possible to supply a Dimension instance, which will
    # result in a new Dimension instance equal to the supplied one.
    # 
    def initialize hash
      @L, @M, @T, @Q, @Θ = hash[:L], hash[:M], hash[:T], hash[:Q], hash[:Θ]
    end

    # #[] method provides access to the dimension components, such as
    # d = Dimension.new( L: 1, T: -2 ), d[:T] #=> -2
    # 
    def [] arg
      ß = arg.to_s.strip.to_sym
      if BASIC_DIMENSIONS.letters.include? ß then send ß else
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
      BASIC_DIMENSIONS.letters.map { |letter|
        self[letter] == other[letter]
      }.reduce( :& )
    end

    # Dimension arithmetic: addition. (+, -, *, /).
    # 
    def + other
      self.class.new Hash[ BASIC_DIMENSIONS.letters.map { |letter|
                             [ letter, self[letter] + other[letter] ]
                           } ]
    end

    # Dimension arithmetic: multiplication by a number.
    # 
    def * num
      self.class.new Hash[ BASIC_DIMENSIONS.letters.map { |letter|
                             [ letter, self[letter] * num ]
                           } ]
    end

    # Dimension arithmetic: subtraction.
    # 
    def - other
      self.class.new Hash[ BASIC_DIMENSIONS.letters.map { |letter|
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
      Dimension.new Hash[ BASIC_DIMENSIONS.letters
                            .zip( exponents.map { |exp| exp / num } ) ]
    end

    # Conversion to an array (of exponents of in the order of the
    # basic dimension letters).
    # 
    def to_a
      BASIC_DIMENSIONS.letters.map { |letter| self[ letter ] }
    end

    # Conversion to a hash (eg. { L: 1, M: 0, T: -2, Q: 0, Θ: 0 } ).
    # 
    def to_hash
      BASIC_DIMENSIONS.letters.each_with_object Hash.new do |letter, memo_hash|
        memo_hash[ letter ] = self[ letter ]
      end
    end

    # Returns true if the dimension is zero ("dimensionless"), otherwise false.
    # 
    def zero?
      [ @L, @M, @T, @Q, @Θ ] == [ 0, 0, 0, 0, 0 ]
    end

    # Converts the dimension into a superscripted product string.
    # 
    def to_s
      sps = SPS.( BASIC_DIMENSIONS.letters,
                  BASIC_DIMENSIONS.letters.map { |letter|
                    self[ letter ]
                  } )
      if sps == "" then "∅" else sps end
    end

    # Produces the inspect string of the dimension.
    # 
    def inspect
      "#<Dimension: #{self} >"
    end

    # Returns dimension's standard quantity.
    # 
    def standard_quantity
      self.class.standard_quantities[ self ]
    end

    delegate :fav_units, to: :standard_quantity
  end # class Dimension

  # Convenience constructor Dimension() (acts as alias for Dimension.new).
  # 
  def Dimension( *args, &block )
    Dimension.new *args, &block
  end

  module_function :Dimension
end # module SY
