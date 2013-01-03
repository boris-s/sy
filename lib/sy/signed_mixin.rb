#encoding: utf-8

# This class represents a magnitude of a metrological quantity. A magnitude
# is basically a pair [quantity, amount].
# 
# Magnitude, when it represents an amount of something real, generally
# cannot be negative. To represent negative numbers expressed in units, a
# signed magnitude class can be prepared by inclusion of SignedMixin.
# 
module SY::SignedMixin
  # SignedMixin overrides #initialize method to allow negative amounts.
  # 
  def initialize *args
    ꜧ = args.extract_options!
    @quantity = ꜧ.must_have :quantity, syn!: :of
    n = ꜧ[:amount] || 1
    @amount = case n
              when SY::Magnitude then
                raise TErr, dim_complaint( n ) unless same_dimension? n
                n.numeric_value_in_standard_unit
              else n end
    # it's O.K. for a SignedMagnitude to have negative @amount
  end

  private

  # String describing this class.
  # 
  def çς
    "±Magnitude"
  end
end # module SY::SignedMixin
