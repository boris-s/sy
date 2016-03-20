# encoding: utf-8

# Defines how a certain quantity (target quantity) is converted to another
# quantity (reference quantity). Has two attributes:
#
# * @r2t - Closure for converting from the reference quantity.
# * @t2r - closure for converting back to the reference quantity.
#
# Convenience methods #rt and #tr expose these closures for easy magnitude
# conversion.
# 
class SY::Measure
  class << self
    # Identity measure.
    # 
    def identity
      simple_scaling 1
    end

    # Linear scaling measure with no offset (such as pounds vs kilograms).
    # 
    def simple_scaling factor
      new factor: factor
    end

    # Offset measure with no scaling (such as +°C+ vs +K+).
    # 
    def simple_offset offset
      new r2t: -> r { r - offset }, t2r: -> t { t + offset }
    end

    # Linear (scaling & offset) measure. Expects a hash with 2 points that
    # demonstrate the measure:
    # 
    # { reference_amount_1 => target_amount_1,
    #   reference_amount_2 => target_amount_2 }
    # 
    # Everyday example: Degrees Fahrenheit vs. Kelvins.
    # 
    def linear hsh
      r1, t1, r2, t2 = hsh.to_a.flatten
      f = ( r2 - r1 ) / ( t2 - t1 ) # scaling factor
      new r2t: -> r { t1 + ( r - r1 ) / f }, t2r: -> t { r1 + ( t - t1 ) * f }
    end

    # Logarithmic measure with given base.
    # 
    def logarithmic base=Math::E
      new r2t: -> r { Math.log r, base }, t2r: -> t { base ** t }
    end

    # Minus logarithmic measure with given.
    # 
    def negative_logarithmic base=Math::E
      new r2t: -> r { -Math.log( r, base ) }, t2r: -> t { base ** ( -t ) }
    end
  end

  attr_reader :r2t, :t2r, :factor

  # The constructor expects :r2t and :t2r arguments (reference-to-target and
  # target-to-reference closures). If these are not given, :factor argument can
  # be used to construct simple scaling measures (factor = reference amount /
  # target amount ).
  # 
  def initialize( factor: nil, r2t: nil, t2r: nil )
    if factor.nil?
      fail TypeError, ":r2t and :t2r must both be given as closures unless " +
        ":factor is given!" unless r2t.is_a?( Proc ) && t2r.is_a?( Proc )
      @r2t, @t2r = r2t, t2r
    else
      fail ArgumentError, ":r2t and :t2r must not be given if :factor " +
        "is given!" if r2t || t2r
      @factor = factor
      @r2t = -> r { r / factor }
      @t2r = -> t { t * factor }
    end
  end

  # Convenience converter of a reference magnitude into the target quantity.
  # Since measure instances are not associated with particular quantities,
  # not only the reference magnitude, but also the target quantity must be
  # supplied. It is the responsibility of the caller to make sure that
  # the measure object is the correct one to use between these two quantities.
  # 
  def rt reference_magnitude, target_quantity
    target_quantity.magnitude r2t.( reference_magnitude.amount )
  end

  # Convenience converter of a target magnitude into the reference quantity.
  # Since measure instances are not associated with particular quantities,
  # not only the target magnitude, but also the reference quantity to which
  # the conversion will be performed needs to be supplied. It is the
  # responsibility of the caller to make sure that the measure object is the
  # correct one to use between these two quantities.
  # 
  def tr target_magnitude, reference_quantity
    reference_quantity.magnitude t2r.( target_magnitude.amount )
  end

  # Inverse measure.
  # 
  def inverse
    if factor.nil? then
      self.class.new r2t: t2r, t2r: r2t # swap closures
    else
      self.class.new factor: 1 / factor # invert factor
    end
  end

  # Composition of two measures (like f * g function composition).
  # 
  def * other
    if factor.nil? then
      r2t1, r2t2, t2r1, t2r2 = r2t, other.r2t, t2r, other.t2r
      self.class.new r2t: -> r { r2t1.( r2t2.( r ) ) },
                     t2r: -> t { t2r2.( t2r1.( t ) ) }
    else
      self.class.new factor: factor * other.factor
    end
  end

  # Composition of this measure with the inverse of another measure.
  # 
  def / other
    self * other.inverse
  end

  # Measure power.
  # 
  def ** n
    if factor.nil? then
      r2t_closure, t2r_closure = r2t, t2r
      self.class.new r2t: -> r { n.times.inject r { |m, _| r2t_closure.( m ) } },
                     t2r: -> t { n.times.inject t { |m, _| t2r_closure.( m ) } }
    else
      self.class.new factor: factor ** n
    end
  end

  protected

  def [] *args
    send *args
  end
end # class SY::Measure
