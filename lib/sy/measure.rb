# -*- coding: utf-8 -*-
# Represents a certain way, that a quantity <em>measures</em> another quantity
# (reference quantity). Instance has two attributes:
#
# * @r - read closure, for converting from the measured reference quantity.
# * @w - write closure, for converting back to the reference quantity.
#
# Convenience methods #read and #write facilitate their use.
# 
class SY::Measure
  class << self
    # Identity measure.
    # 
    def identity
      simple_scale 1
    end

    # Simple scaling measure. (Eg. pounds vs kilograms)
    # 
    def simple_scale scale
      new( ratio: scale )
    end

    # Simple offset measure. (Such as °C)
    # 
    def simple_offset offset
      new( r: lambda { |ref_amnt| ref_amnt - offset },
           w: lambda { |amnt| amnt + offset } )
    end

    # Linear (scaled offset) measure. Expects a hash with 2 points demonstrating
    # the relationship: { ref_amount_1 => amount_1, ref_amount_2 => amount_2 }.
    # (Example: Fahrenheit degrees vs. Kelvins.)
    # 
    def linear hsh
      ref_amnt_1, amnt_1, ref_amnt_2, amnt_2 = hsh.to_a.flatten
      scale = ( ref_amnt_2 - ref_amnt_1 ) / ( amnt_2 - amnt_1 )
      new( r: lambda { |ref_amnt| amnt_1 + ( ref_amnt - ref_amnt_1 ) / scale },
           w: lambda { |amnt| ref_amnt_1 + ( amnt - amnt_1 ) * scale } )
    end

    # Logarithmic.
    # 
    def logarithmic base=Math::E
      new( r: lambda { |ref_amnt| Math.log ref_amnt, base },
           w: lambda { |amnt| base ** amnt } )
    end

    # Negative logarithmic.
    # 
    def negative_logarithmic base=Math::E
      new( r: lambda { |ref_amnt| -Math.log( ref_amnt, base ) },
           w: lambda { |amnt| base ** ( -amnt ) } )
    end
  end

  attr_reader :r, :w, :ratio

  # The constructor expects :r and :w arguments for read and write closure.
  # 
  def initialize( ratio: nil, r: nil, w: nil )
    if ratio.nil?
      fail TypeError, ":r and :w arguments must both be closures if ratio " +
        "not given!" unless r.is_a?( Proc ) && w.is_a?( Proc )
      @ratio, @r, @w = nil, r, w
    else
      fail ArgumentError, ":r or :w must not be given if :ratio given!" if r || w
      @ratio = ratio
      @r = lambda { |ref_amnt| ref_amnt / ratio }
      @w = lambda { |amnt| amnt * ratio }
    end
  end

  # Convenience method to read a magnitude of a reference quantity.
  # 
  def read magnitude_of_reference_quantity, quantity
    quantity.magnitude r.( magnitude_of_reference_quantity.amount )
  end

  # Convenience method to convert a magnitude back to the reference quantity.
  # 
  def write magnitude, reference_quantity
    reference_quantity.magnitude w.( magnitude.amount )
  end

  # Inverse measure.
  # 
  def inverse
    if ratio.nil? then
      self.class.new( r: w, w: r ) # swap closures
    else
      self.class.new( ratio: 1 / ratio )
    end
  end

  # Measure composition (like f * g function composition).
  # 
  def * other
    if ratio.nil? then
      r1, r2, w1, w2 = r, other.r, w, other.w
      self.class.new( r: lambda { |ref_amnt| r1.( r2.( ref_amnt ) ) },
                      w: lambda { |amnt| w2.( w1.( amnt ) ) } )
    else
      self.class.new( ratio: ratio * other.ratio )
    end
  end

  # Measure composition with inverse of another measure.
  # 
  def / other
    self * other.inverse
  end

  # Measure power.
  # 
  def ** n
    if ratio.nil? then
      r_closure, w_closure = r, w
      self.class.new( r: lambda { |ref_amnt|
                        n.times.inject ref_amnt do |m, _| r_closure.( m ) end
                      },
                      w: lambda { |amnt|
                        n.times.inject amnt do |m, _| w_closure.( m ) end
                      } )
    else
      self.class.new( ratio: ratio ** n )
    end
  end

  protected

  def []( *args )
    send *args
  end
end # class SY::Measure
