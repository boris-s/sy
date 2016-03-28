#encoding: utf-8

# require 'y_support/core_ext/array'
# require 'y_support/core_ext/hash'
# require 'active_support/core_ext/module/delegation'

# Metrological dimension
# 
class SY::Dimension < Hash
  require_relative 'dimension/base'
  require_relative 'dimension/sps'

  class << self
    # Presents class-owned instances (array).
    # 
    def instances
      return @instances ||= []
    end

    undef_method :new
    
    # A constructor of +SY::Dimension+. Accepts variable input and always
    # returns the same object for the same dimension. The input can look like
    # :L, :LENGTH, "LENGTH", { L: 1, T: -2 } or "L.T⁻²".
    #
    def [] *ordered, **named
      # Validate arguments and enable variable input.
      input = if ordered.size == 0 then named
              elsif ordered.size > 1 then
                fail ArgumentError, "SY::Dimension[] constructor admits at " +
                                    "most 1 ordered argument!"
              else ordered[0] end
      # If input is a Dimension instance, return it unchanged.
      return input if input.is_a? self
      # It is assumed that the input implies an Sps.
      triples = SY::Dimension::Sps.new( input ).parse
      # Convert the input to hash and normalize dimension symbols.
      hash = triples.each_with_object Hash.new do |(_, ß, exponent), h|
        h[ SY::Dimension::BASE.normalize_symbol( ß ) ] = exponent
      end
      # Set exponents of unmentioned base dimensions to 0.
      hash.default! BASE.values >> BASE.values.map { 0 }
      # Make sure each combination of base dimensions has only one instance.
      instance = instances.find { |i| i == hash }
      unless instance
        instance = super hash
        instances << instance
      end
      return instance
    end

    # Constructs zero dimension.
    #
    def zero
      self[]
    end
  end

  # Dimension arithmetic: addition.
  # 
  def + other
    merge other do |_, exp1, exp2| exp1 + exp2 end
  end

  # Dimension arithmetic: subtraction.
  # 
  def - other
    merge other do |_, exp1, exp2| exp1 - exp2 end
  end

  # Dimension arithmetic: multiplication by a number.
  # 
  def * integer
    integer.aT_is_a Integer
    self.class[ keys >> values.map { |exp| exp * integer } ]
  end

  # Dimension arithmetic: division by a number.
  # 
  def / integer
    integer.aT_is_a Integer
    self.class[ keys >> values.map do |exp|
                  fail TypeError, "Dimensions with rational exponents " +
                                  "not implemented!" if exp % integer != 0
                  exp / integer
                end ]
  end

  # True if the dimension is zero ("dimensionless"), otherwise false.
  # 
  def zero?
    values.all? { |exp| exp.zero? }
  end

  # True if the dimension is basic, otherwise false.
  # 
  def base?
    values.count( 1 ) == 1 && values.count( 0 ) == size - 1
  end
  alias basic? base?

  # Converts the dimension into its superscripted product string (SPS).
  # 
  def to_s
    sps = SY::SPS.new self
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
    @standard_quantity ||= SY::Quantity.of( self )
  end

  # Returns default quantity composition for this dimension.
  # 
  def to_composition
    SY::Composition[ ( keys.map do |letter|
                         self.class[ letter ].standard_quantity.absolute
                       end >> values ).reject { |k, v| v.zero? } ]
  end

  delegate :standard_unit, to: :standard_quantity
end # class SY::Dimension
