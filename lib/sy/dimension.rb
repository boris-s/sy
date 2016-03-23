#encoding: utf-8

require_relative 'dimension/sps'

# Metrological dimension
# 
class SY::Dimension < Hash
  # Basic physical dimensions.
  #
  # Current SY version intentionally omits amount of substance and
  # luminous intensity. Also, current SY version takes electric charge
  # for a basic dimension instead of classic electric current.
  # 
  BASE = {
    L: :LENGTH,
    M: :MASS,
    T: :TIME,
    Q: :ELECTRIC_CHARGE,        # instead of electric current
    Θ: :TEMPERATURE,
  }

  class << self
    # Presents class-owned instances (array).
    # 
    def instances
      return @instances ||= []
    end

    undef_method :new
    
    # With the #new constructor undefined, #[] is the main constructor for
    # +SY::Dimension+. Accepts variable input and always returns the same
    # object for the same dimension. The input can look like :L, :LENGTH,
    # "LENGTH", { L: 1, T: -2 } or "L.T⁻²".
    #
    def [] *ordered, **named
      # Validate arguments and enabling variable input.
      hint = if ordered.size == 0 then named
             elsif ordered.size == 1 then
               case ordered[0]
               when self then return ordered[0] # a Dimension instance
               else # SPS form is assumed, such as "L.T⁻²"
                 SY::Dimension::Sps.new( ordered[0] ).to_hash
                 # SY::BASE_DIMENSIONS.parse_sps( ordered[0] )
               end
             else
               fail ArgumentError, "The #[] constructor accepts " +
                                   "at most 1 ordered argument!"
             end
      # Convert dimension names (if given) to dimension letters.
      SY::BASE_DIMENSIONS.each do |letter, full_name|
        hint.may_have letter, syn!: full_name
      end
      # Set exponents of unmentioned base dimensions to 0.
      letters = SY::BASE_DIMENSIONS.keys
      hint.default! letters >> letters.map { 0 }
      # Make sure each combination of base dimensions has only one instance.
      instance = instances.find { |i| i == hint }
      unless instance
        instance = super( hint )
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
