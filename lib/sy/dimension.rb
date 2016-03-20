#encoding: utf-8

# Metrological dimension
# 
class SY::Dimension < Hash
  # Let's set up the registry of standard quantities.
  #
  @standard_quantities ||= Hash.new { |h, missing_key|
    if missing_key.is_a? Dimension then
      # Missing key is a dimension. Make a new quantity for it.
      h[missing_key] = SY::Quantity.of missing_key
    else
      # Otherwise, let SY.Dimension constructor judge:
      h[ SY.Dimension missing_key ]
    end
  }

  class << self
    selector :standard_quantities

    # TODO: Undefine #new constructor somehow.

    # The #new constructor of SY::Dimension has been changed, so that the
    # same instance is returned, if that dimension has already been created.
    # As input, it takes a dimension hint, which can have variable form, such
    # as :L, :LENGTH, "LENGTH", { L: 1, T: -2 } or "L.T⁻²".
    #
    def [] dimension_hint={}
      fait NotImplementedMethod
      case dimension_hint
      when self then return dimension_hint     # already a Dimension instance
      when Hash then hsh = dimension_hint # hint given in hash form
      else
        # Superscripted string (SPS) form assumed, such as "L.T⁻²"
        hsh = SY::BASE_DIMENSIONS.parse_sps( dimension_hint )
      end
      # Set unmentioned base dimensions to zero exponent.
      hsh = hsh.default! Hash[ SY::BASE_DIMENSIONS.base_symbols.map { |ß| [ß, 0] } ]

      keys = SY::BASE_DIMENSIONS.letters
      hsh = keys >> keys.map { 0 }

      
      return instances.find { |i| i.to_hash == hsh } ||
             __new__( hsh )
    end
  end

  # attr_accessor *SY::BASE_DIMENSIONS.base_symbols
  # # The above line is superseded by SY.Dimension convenience
  # # constructor, and the fact that the mentioned constructor
  # # always returns the same instance.

  # Method #initialize requires a hash-type argument, such as
  # { L: 1, T: -2 }.
  #
  def initialize hsh
    SY::BASE_DIMENSIONS.
  end
end # class SY::Dimension
