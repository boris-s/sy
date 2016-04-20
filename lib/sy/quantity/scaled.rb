# coding: utf-8

# SY Quantity subclass represented composed quantities.
# 
class SY::Quantity::Scaled < SY::Quantity
  def initialize parent, ratio: 1
    @parent = parent
    @function = SY::Quantity::Ratio.new( ratio )
    @dimension = parent.dimension
  end
end # class SY::Quantity::Scaled
