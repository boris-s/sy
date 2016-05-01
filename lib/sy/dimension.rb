# coding: utf-8

# Metrological dimension
# 
class SY::Dimension < Hash
  require_relative 'dimension/base'
  require_relative 'dimension/sps'

  ★ Literate
  
  represents "physical dimension"

  ★ FlexCoerce
  
  coerces Integer, :* do |a, b| b * a end

  # This error indicates incompatible dimensions.
  # 
  class Error < TypeError; end

  class << self
    # Presents class-owned instances (array).
    # 
    def instances
      return @instances ||= []
    end

    undef_method :new
    
    # A constructor of +SY::Dimension+. Accepts variable input and
    # always returns the same object for the same dimension. The
    # input can look like :L, :LENGTH, "LENGTH", { L: 1, T: -2 } or
    # "L.T⁻²".
    #
    def [] *ordered, **named
      # Validate arguments and enable variable input.
      input = ordered_args ordered do
        case size
        when 0 then named
        when 1 then first
        else
          fail "Constructor Dimension[] takes at most 1 argument!"
        end
      end
      # If input is a Dimension instance, return it unchanged.
      return input if input.is_a? self
      # It is assumed that the input is an Sps.
      triples = SY::Dimension::Sps.new( input ).parse
      # Convert the input to hash and normalize dimension symbols.
      hash = triples.each_with_object Hash.new do
        |(_, ß, exponent), h|
        h[ SY::Dimension::BASE.normalize_symbol( ß ) ] = exponent
      end
      # Set exponents of unmentioned base dimensions to 0.
      hash.default! BASE.values >> BASE.values.map { 0 }
      # See if the registry already contains required instance.
      instance = instances.find { |i| i == hash }
      # If not, construct a new instance.
      unless instance
        instance = super hash
        instances << instance
      end
      # Return the result.
      return instance
    end

    # Constructs zero dimension.
    #
    def zero
      self[]
    end
  end

  undef_method :merge!, :[]=

  # Returns the exponent of the specified base dimension. Accepts
  # variable input specifying the base dimension (:LENGTH, :L,
  # "LENGTH", "L" etc.)
  #
  def [] arg
    super BASE.normalize_symbol( arg )
  end

  # Returns the exponents of the specified base dimensions. Accepts
  # variable input specifying base dimensions (:LENGTH, :L,
  # "LENGTH", "L" etc.)
  # 
  def values_at *keys
    super *keys.map { |sym| BASE.normalize_symbol( sym ) }
  end

  # SY::Dimension#merge method only accepts SY::Dimension instances
  # as arguments.
  # 
  def merge arg, &block
    "argument of Dimension#merge".( arg ).must.be_a self.class
    self.class[ super ]
  end

  # Dimension arithmetic: negation.
  #
  def -@
    self.class.zero - self
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
  def * int
    "argument".( int ).must.be_kind_of Integer
    self.class[ keys >> values.map { |exp| exp * int } ]
  end

  # Dimension arithmetic: division by a number.
  # 
  def / int
    # Validate the argument.
    "divisor".( int ).must.be_kind_of Integer
    # Validate the exponents.
    "dimension #{self}".( self ).try "to divide %s by #{int}" do
      note "When dividing a Dimension instance by an integer, " +
           "all its exponents must be divisible by it."
      note "#{grammatical_subject} has exponents " +
           "[ #{(values-[0]).join ', '} ]"
      values.each do |exp|
        fail "Exponent #{exp} is not divisible by #{int}!" unless
          exp % int == 0
      end
    end
    # Construct the result.
    return self.class[ keys >> values.map { |exp| exp / int } ]
    fail NotImplementedError
  end

  # True if the dimension is zero, otherwise false.
  # 
  def zero?
    values.all? { |exp| exp.zero? }
  end

  # True if the dimension is a base dimension, otherwise false.
  # 
  def base?
    values.count( 1 ) == 1 && values.count( 0 ) == size - 1
  end
  alias basic? base?

  # Converts the receiver to a superscripted product string
  # denoting the dimension.
  # 
  def to_sps option=true
    return Sps.new self if option
    return Sps.new keys.map { |k| BASE.short_symbol k } >> values
  end

  # Converts the dimension into its superscripted product string
  # (SPS).
  # 
  def to_s
    sps = to_sps( false )
    return sps.empty? ? "∅" : sps
  end

  # Produces the inspect string of the dimension.
  # 
  def inspect
    y_inspect :short
  end

  # Returns dimension's standard quantity.
  # 
  def standard_quantity
    @standard_quantity ||= SY::Quantity.of dimension: self
  end

  delegate :standard_unit, to: :standard_quantity
end # class SY::Dimension
