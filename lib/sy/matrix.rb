#encoding: utf-8

require 'matrix'

# As a matter of fact, current version of the Matrix class (by Marc-Andre
# Lafortune) does not work with physical magnitudes. It is a feature of the
# physical magnitudes, that they do not allow themselves summed with ordinary
# numbers (Numeric) or incompatible magnitudes. (Compatibility is mostly
# decided by quantity compatibility, but there can be edge cases.) In any case,
# current version of Matrix, upon matrix multiplication, performs needless
# addition of the elements of the matrix to the numeric literal 0.
#
# The quick fix solution is to patch Matrix class so that this needless addition
# of elements to literal 0 is no longer performed.
#
# More systematically, Matrix should quit assuming that its elements are numbers
# (Numeric). Instead, Marc-Andre should require its elements to belong to a
# monoid, group, ring, field, depending on what one wants to do with the matrix,
# and perhaps allow the elements to be completely non-descript objects, if one
# wants only things such as extracting rows, columns, submatrices, diagonals etc.
# Marc-Andre is doing a crucial service for a cutting-edge language, he should
# really start taking his work seriously.
#
class Matrix
  # TODO: Note that the current solution is fairly dumb.
  
  # Matrix multiplication.
  #
  def * arg # arg is matrix or vector or number
    case arg
    when Numeric
      rows = @rows.map { |row| row.map { |e| e * arg } }
      return new_matrix rows, column_size
    when Vector
      arg = Matrix.column_vector arg
      result = self * arg
      return result.column 0
    when Matrix
      Matrix.Raise ErrDimensionMismatch if column_size != arg.row_size
      rows = Array.new row_size do |i|
        Array.new arg.column_size do |j|
          ( 0...column_size ).map { |c| arg[c, j] * self[i, c] }.reduce :+
        end
      end
      return new_matrix( rows, arg.column_size )
    when SY::Magnitude # newly added - multiplication by a magnitude
      rows = Array.new row_size do |i|
        Array.new column_size do |j|
          self[i, j] * arg
        end
      end
      return self.class[ *rows ]
    else
      compat_1, compat_2 = arg.coerce self
      return compat_1 * compat_2
    end
  end

  # Creates a matrix of prescribed dimensions filled with wildcard zeros.
  # 
  def Matrix.wildcard_zero r_count, c_count=r_count
    build r_count, c_count do |r, c| SY::WILDCARD_ZERO end
  end
end

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
