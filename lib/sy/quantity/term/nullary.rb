# encoding: utf-8

# Nullary (empty) quantity term.
#
class SY::Quantity::Term::Nullary < SY::Quantity::Term
  class << self
    undef_method :[]

    def new
      super( {} )
    end
  end

  def arity
    0
  end
end
