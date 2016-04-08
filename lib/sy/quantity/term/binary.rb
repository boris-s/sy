# encoding: utf-8

# Binary quantity term -- constisting of two quantities with their
# exponents.
#
class SY::Quantity::Term::Binary < SY::Quantity::Term
  class << self
    def new
      fail NotImplementedError
    end
  end

  def arity
    2
  end
end
