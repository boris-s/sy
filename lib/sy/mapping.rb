# -*- coding: utf-8 -*-
# Represents relationship of two quantities. Provides import and export
# conversion closures. Instances are immutable and have 2 attributes:
#
# * im - import closure, converting amount of quantity 1 into quantity 2
# * ex - export closure, converting amount of quantity 2 into quantity 1
#
# Convenience methods for mapping magnitudes are:
# 
# * import - like im, but operates on magnitudes
# * export - like ex, but operates on magnitudes
# 
class SY::Mapping
  class << self
    def identity
      new 1
    end
  end

  attr_reader :ex, :im, :ratio

  # Takes either a magnitude (1 argument), or 2 named arguments :im, :ex
  # specifying the amount import and amount export closure. If a ratio is given,
  # these closures are constructed automatically, assuming simple ratio rule. If
  # a ratio is not given, both :ex and :im closures must be given.
  # 
  def initialize( ratio=nil,
                  ex: lambda { |amnt1| amnt1 * ratio },
                  im: lambda { |amnt2| amnt2 / ratio } )
    @ratio, @ex, @im = ratio, ex, im
  end

  def import magnitude, from_quantity
    from_quantity.magnitude @im.( magnitude.amount )
  end

  def export magnitude, to_quantity
    to_quantity.magnitude @ex.( magnitude.amount )
  end

  def inverse
    self.class.new begin
                     1 / @ratio
                   rescue NoMethodError, TypeError
                     i, e = im, ex
                     { im: e, ex: i } # swap closures
                   end
  end

  def * r2 # mapping composition
    ç.new begin
            @ratio * r2.ratio
          rescue NoMethodError, TypeError
            i1, i2, e1, e2 = im, r2.im, ex, r2.ex
            { ex: lambda { |a1| e2.( e1.( a1 ) ) }, # export compose
        im: lambda { |a2| i1.( i2.( a2 ) ) } } # import compose
          end
  end

  def / r2
    self * r2.inverse
  end

  def ** n
    ç.new begin
            n == 1 ? @ratio * 1 : @ratio ** n
          rescue NoMethodError, TypeError
            i, e = im, ex
            { ex: lambda { |a1| n.times.reduce a1 do |m, _| e.( m ) end },
        im: lambda { |a2| n.times.reduce a2 do |m, _| i.( m ) end } }
          end
  end

  protected

  def []( *args )
    send *args
  end
end # class SY::Mapping
