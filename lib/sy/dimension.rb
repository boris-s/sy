#encoding: utf-8

module SY
  # This class represents a dimension of a metrological quantity.
  # 
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
end # module SY
