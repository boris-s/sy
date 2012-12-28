#encoding: utf-8

module SY
  # This class represents physical dimension of a metrological quantity.
  # 
  class Dimension
    class << self
      alias __new__ new

      # The #new constructor of SY::Dimension has been changed, so that the
      # same instance is returned, if that dimension has already been created.
      # 
      def new dim_spec={}
        ꜧ = case dim_spec
            when Hash then dim_spec
            when self then return dim_spec # it is a dimension instance
            else # we'll treat dimension_specification as SPS
              _, letters, exponents =
                SPS_PARSER.( dim_spec.to_s, BASE_DIMENSIONS.letters )
              Hash[ letters.map( &:to_sym ).zip( exponents ) ]
            end.with_values { |v| Integer v } # grooming
        ꜧ.default!( L: 0, M: 0, T: 0, Q: 0, Θ: 0 ) # zeros by default
        # Now we can see whether the instance of this dimension already exists
        return instances.find { |inst| inst.to_hash == ꜧ } ||
               __new__( ꜧ ).tap{ |inst| instances << inst }
      end

      # Presents class-owned instances (array).
      # 
      def instances
        return @instances ||= []
      end

      # Presents standard quantities pertaining to the dimensions (hash).
      # 
      def standard_quantities
        @standard_quantities ||= Hash.new { |ꜧ, dim|
          if dim.is_a? Dimension then
            ꜧ[ dim ] = Quantity.of dim
          else
            ꜧ[ Dimension.new dim ]
          end
        }
      end

      # Constructor for basic dimensions. Symbol signifying the basic
      # physical dimension is expected as the argument.
      # 
      def basic base_dimension_letter
        ß = base_dimension_letter.to_sym
        raise AE, "Unknown base dimension: #{ß}" unless
          ( BASE_DIMENSIONS.letters + BASE_DIMENSIONS.values ).include? ß
        return new( ß => 1 )
      end
      alias base basic

      # Constructor for zero dimension ("dimensionless").
      # 
      def zero; new() end
    end

    attr_accessor *BASE_DIMENSIONS.letters

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
      if BASE_DIMENSIONS.letters.include? ß
        send( ß )
      elsif BASE_DIMENSIONS.values.include? ß
        send( BASE_DIMENSIONS.rassoc( ß ).first )
      else
        raise AE, "Unknown basic dimension: #{ß}"
      end
    end

    #Two dimensions are equal, if their exponents are equal.
    # 
    def == other
      other = ç.new other rescue return false
      to_a == other.to_a
    end

    # Dimension arithmetic: addition. (+, -, *, /).
    # 
    def + other
      ç.new Hash[ BASE_DIMENSIONS.letters.map do |l|
                    [ l, self.send( l ) + other.send( l ) ]
                  end ]
    end
    
    # Dimension arithmetic: subtraction.
    # 
    def - other
      ç.new Hash[ BASE_DIMENSIONS.letters.map do |l|
                    [ l, self.send( l ) - other.send( l ) ]
                  end ]
    end

    # Dimension arithmetic: multiplication by a number.
    # 
    def * number
      ç.new Hash[ BASE_DIMENSIONS.letters.map do |l|
                        [ l, self.send( l ) * number ]
                      end ]
    end

    # Dimension arithmetic: division by a number.
    # 
    def / number
      ç.new Hash[ BASE_DIMENSIONS.letters.map do |l|
                        raise AE, "Dimensions with rational exponents " +
                          "not implemented" if ( exp = send l ) % number != 0
                        [ l, exp / number ]
                      end ]
    end

    # Conversion to an array (of exponents of in the order of the
    # basic dimension letters).
    # 
    def to_a
      BASE_DIMENSIONS.letters.map { |l| self.send l }
    end

    # Conversion to a hash (eg. { L: 1, M: 0, T: -2, Q: 0, Θ: 0 } ).
    # 
    def to_hash
      BASE_DIMENSIONS.letters.each_with_object Hash.new do |l, ꜧ|
        ꜧ[ l ] = self.send( l )
      end
    end

    # True if the dimension is zero ("dimensionless"), otherwise false.
    # 
    def zero?
      to_a == [ 0, 0, 0, 0, 0 ]
    end

    # Converts the dimension into its SPS.
    # 
    def to_s
      sps = SPS.( BASE_DIMENSIONS.letters, to_a )
      return sps == "" ? "∅" : sps
    end

    # Produces the inspect string of the dimension.
    # 
    def inspect
      "#<Dimension: #{self} >"
    end

    # Returns dimension's standard quantity.
    # 
    def standard_quantity
      ç.standard_quantities[ self ]
    end

    delegate :standard_unit,
             to: :standard_quantity
  end # class Dimension
end # module SY
