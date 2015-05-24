# -*- coding: utf-8 -*-
# This class represents physical dimension of a metrological quantity.
# 
class SY::Dimension
  # Let's set up an instance variable (of the class) that will hold standard
  # quantities of selected dimensions:
  # 
  @standard_quantities ||= Hash.new { |ꜧ, missing_key|
    if missing_key.is_a? SY::Dimension then
      # Create a new quantity of that dimension:
      ꜧ[missing_key] = SY::Quantity.of missing_key
    else
      # Otherwise, let SY.Dimension constructor judge:
      ꜧ[ SY.Dimension missing_key ]
    end
  }

  class << self
    alias __new__ new
    attr_reader :standard_quantities
    
    # The #new constructor of SY::Dimension has been changed, so that the
    # same instance is returned, if that dimension has already been created.
    # 
    def new dim={}
      ꜧ = case dim
          when Hash then dim
          when self then return dim # it is a dimension instance
          else # we'll treat dimension_specification as SPS
            SY::BASE_DIMENSIONS.parse_sps( dim )
          end
      # Zeros by default:
      ꜧ.default! Hash[ SY::BASE_DIMENSIONS.base_symbols.map { |ß| [ß, 0] } ]
      # Now we can see whether the instance of this dimension already exists.
      return instances.find { |inst| inst.to_hash == ꜧ } ||
        __new__( ꜧ ).tap { |inst| instances << inst }
    end

    # Presents class-owned instances (array).
    # 
    def instances
      return @instances ||= []
    end

    # Base dimension constructor. Base dimension symbol is expeced as argument.
    # 
    def base symbol
      raise ArgumentError, "Unknown base dimension: #{symbol}" unless
        SY::BASE_DIMENSIONS.base_symbols.include? symbol
      return new( symbol => 1 )
    end
    alias basic base
    
    # Constructor for zero dimension ("dimensionless").
    # 
    def zero; new end
  end

  attr_accessor *SY::BASE_DIMENSIONS.base_symbols

  # Dimension can be initialized either by supplying a hash
  # (such as Dimension.new L: 1, T: -2) or by supplying a SPS
  # (superscripted product string), such as Dimension.new( "L.T⁻²" ).
  # It is also possible to supply a Dimension instance, which will
  # result in a new Dimension instance equal to the supplied one.
  # 
  def initialize hash
    SY::BASE_DIMENSIONS.base_symbols.each { |ß|
      instance_variable_set "@#{ß}", hash[ß]
    }
  end

  # #[] method provides access to the dimension components, such as
  # d = Dimension.new( L: 1, T: -2 ), d[:T] #=> -2
  # 
  def [] ß
    return send ß if SY::BASE_DIMENSIONS.letters.include? ß
    raise ArgumentError, "Unknown basic dimension: #{ß}"
  end

  #Two dimensions are equal, if their exponents are equal.
  # 
  def == other
    to_a == other.to_a
  end

  # Dimension arithmetic: addition. (+, -, *, /).
  # 
  def + other
    ç.new Hash[ SY::BASE_DIMENSIONS.base_symbols.map do |l|
                  [ l, self.send( l ) + other.send( l ) ]
                end ]
  end

  # Dimension arithmetic: subtraction.
  # 
  def - other
    ç.new Hash[ SY::BASE_DIMENSIONS.base_symbols.map do |l|
                  [ l, self.send( l ) - other.send( l ) ]
                end ]
  end

  # Dimension arithmetic: multiplication by a number.
  # 
  def * number
    ç.new Hash[ SY::BASE_DIMENSIONS.base_symbols.map do |l|
                  [ l, self.send( l ) * number ]
                end ]
  end

  # Dimension arithmetic: division by a number.
  # 
  def / number
    ç.new Hash[ SY::BASE_DIMENSIONS.base_symbols.map do |l|
                  exp = send l
                  raise TErr, "Dimensions with rational exponents " +
                    "not implemented!" if exp % number != 0
                  [ l, exp / number ]
                end ]
  end

  # Conversion to an array (of exponents of in the order of the
  # basic dimension letters).
  # 
  def to_a
    SY::BASE_DIMENSIONS.base_symbols.map { |l| self.send l }
  end

  # Conversion to a hash (eg. { L: 1, M: 0, T: -2, Q: 0, Θ: 0 } ).⁻³
  # 
  def to_hash
    SY::BASE_DIMENSIONS.base_symbols.each_with_object Hash.new do |l, ꜧ|
      ꜧ[ l ] = self.send( l )
    end
  end

  # True if the dimension is zero ("dimensionless"), otherwise false.
  # 
  def zero?
    to_a.all? { |e| e.zero? }
  end

  # True if the dimension is basic, otherwise false.
  # 
  def base?
    to_a.count( 1 ) == 1 &&
      to_a.count( 0 ) == SY::BASE_DIMENSIONS.base_symbols.size - 1
  end
  alias basic? base?

  # Converts the dimension into its SPS.
  # 
  def to_s
    sps = SY::SPS.( SY::BASE_DIMENSIONS.base_symbols, to_a )
    return sps == "" ? "∅" : sps
  end

  # Produces the inspect string of the dimension.
  # 
  def inspect
    "#<SY::Dimension: #{self} >"
  end

  # Returns dimension's standard quantity.
  # 
  def standard_quantity
    self.class.standard_quantities[ self ]
  end

  # Returns default quantity composition for this dimension.
  # 
  def to_composition
    SY::Composition[ SY::BASE_DIMENSIONS.base_symbols
                       .map { |l| self.class.base l }
                       .map { |dim| self.class.standard_quantities[ dim ] }
                       .map { |qnt| qnt.absolute }
                       .zip( to_a ).delete_if { |qnt, exp| exp.zero? } ]
  end

  delegate :standard_unit, to: :standard_quantity
end # class SY::Dimension
