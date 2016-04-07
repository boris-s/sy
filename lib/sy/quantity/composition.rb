# encoding: utf-8

# This class represents a quantity composition: A mapping that
# marks some quantity as equivalent to a quantity term consisting
# of different quantities. Quantity compositions are used in
# expansion/simplification of quantity terms. Compositions come
# into life when quantities that arose by multiplication or
# division of other quantities are named.
# 
class SY::Quantity::Composition < Struct.new :quantity, :term
  # FIXME: Write the tests!
end
