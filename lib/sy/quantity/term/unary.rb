# encoding: utf-8

# Unary quantity term -- constisting of only one quantity with its
# exponent.
#
class SY::Quantity::Term::Unary < SY::Quantity::Term
  class << self
    def new
      fail NotImplementedError
    end
  end

  def arity
    1
  end
end
