# coding: utf-8

require 'matrix'

# As a matter of fact, current version of the Matrix class (by Marc-Andre
# Lafortune) does not work with physical magnitudes. It is a feature of the
# physical magnitudes, that they do not allow themselves summed with plain
# numbers or incompatible magnitudes. But current version of Matrix class,
# upon matrix multiplication, performs needless addition of the matrix elements
# to literal numeric 0.
#
# The obvious solution is to patch Matrix class so that the needless addition
# to literal 0 is no longer performed.
#
# More systematically, abstract algebra is to be added to Ruby, and Matrix is
# to require that its elements comply with monoid, group, ring, field, depending
# on the operation one wants to do with such matrices.
#
class Matrix
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
      if empty? then # if empty?, then reduce uses WILDCARD_ZERO
        rows = Array.new row_size do |i|
          Array.new arg.column_size do |j|
            ( 0...column_size ).reduce WILDCARD_ZERO do |sum, c|
              sum + arg[c, j] * self[i, c]
            end
          end
        end
      else             # if non-empty, reduce proceeds without WILDCARD_ZERO
        rows = Array.new row_size do |i|
          Array.new arg.column_size do |j|
            ( 0...column_size ).map { |c| arg[c, j] * self[i, c] }.reduce :+
          end
        end
      end
      return new_matrix( rows, arg.column_size )
    when SY::Magnitude # newly added - multiplication by a magnitude
      # I am not happy with this explicit switch on SY::Magnitude type here.
      # Perhaps coerce should handle this?
      return map { |e| e * arg }
    else
      compat_1, compat_2 = arg.coerce self
      return compat_1 * compat_2
    end
  end

  #
  # Matrix division (multiplication by the inverse).
  #   Matrix[[7,6], [3,9]] / Matrix[[2,9], [3,1]]
  #     => -7  1
  #        -3 -6
  #
  def /(other)
    case other
    when Numeric
      rows = @rows.collect do |row| row.collect {|e| e / other } end
      return new_matrix rows, column_count
    when Matrix
      return self * other.inverse
    when SY::Magnitude # newly added - multiplication by a magnitude
      return self * ( 1 / other )
    else
      return apply_through_coercion(other, __method__)
    end
  end


  # Creates a matrix of prescribed dimensions filled with wildcard zeros.
  # 
  def Matrix.wildcard_zero r_count, c_count=r_count
    build r_count, c_count do |r, c| WILDCARD_ZERO end
  end
end
