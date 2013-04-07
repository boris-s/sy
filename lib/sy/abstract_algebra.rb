#encoding: utf-8

# Adds abstract algebra concepts to Ruby.
#
module Algebra
  # A Monoid requires:
  #
  # Closed and associative addition: #add method
  # Additive identity element: #additive_identity
  # 
  module Monoid
    def + summand; add summand end
    def zero; additive_identity end
  end

  # A group is a monoid with additive inverse.
  #
  # additive inversion: #additive_inverse
  # 
  module Group
    include Monoid
    def -@; additive_inverse end
    def - subtrahend; add subtrahend.additive_inverse end
  end

  # A group that fulfills the condition of commutativity
  #
  # ( a.add b == b.add a ).
  # 
  module AbelianGroup
    include Group
  end

  # A ring is a commutative group with multiplication.
  # 
  # multiplication: #multiply (associative, distributive)
  # multiplicative identity element: #multiplicative_identity
  # 
  module Ring
    include AbelianGroup
    def * multiplicand; multiply multiplicand end
    def one; multiplicative_identity end
  end

  # A field is a ring that can do division.
  # 
  module Field
    include Ring
    def inverse; multiplicative_inverse end
    def / divisor; multiply divisor.multiplicative_inverse end
  end
end

# Patching Integer with Algebra::Ring compliance methods.
# 
class << Integer
  def additive_identity; 0 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; 1 end
end

# Patching Float with Algebra::Field compliance methods.
# 
class << Float
  def additive_identity; 0.0 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; 1.0 end
  alias one multiplicative_identity
  def multiplicative_inverse; 1.0 / self end
end

# Patching Rational with Algebra::Field compliance methods.
# 
class << Rational
  def additive_identity; Rational 0, 1 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; Rational 1, 1 end
  alias one multiplicative_identity
  def multiplicative_inverse; Rational( 1, 1 ) / self end
end

# Patching Complex with #zero method.
# 
class << Complex
  def additive_identity; Complex 0.0, 0.0 end
  alias zero additive_identity
  def add( other ); self + other end
  def additive_inverse; -self end
  def multiply( other ); self * other end
  def multiplicative_identity; Complex 1, 0 end
  alias one multiplicative_identity
  def multiplicative_inverse; Complex( 1, 0 ) / self end
end
