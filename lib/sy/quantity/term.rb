# coding: utf-8
# coding utf-8

# Represents a product of a certain number of quantities raised to certain
# exponents. It is represented as a hash, whose keys are quantities and
# values are exponents.
#
class SY::Quantity::Term < Hash
  # FIXME: This class is somewhat complicated. I guess it should implement
  # the same rule as SY::Dimension class, ie. just one instance for each
  # combination of exponents. But it doesn't, instead, the multiplication
  # table of quantities sees to the creation of Product instances and ensures
  # there are never two instances for a single combination of
  # exponents. Before I understand after myself how it works again, I do not
  # dare to change the mechanism by which the single instance is ensured. I
  # will just copy what I have written earlier.

  # Simplification rules for quantity combinations.
  # 
  SR = SIMPLIFICATION_RULES = []

  # SY::Amount is disposable:
  # 
  SR << -> hash {
    hash.reject! { |quantity, _| quantity == SY::Amount }
  }
  # Make a way to say it simply, such as by:
  Quantity::Term[ Amount: 1 ] >> Quantity::Term[]

  # Any quantities with exponent zero can be deleted:
  # 
  SR << -> hash {
    hash.reject! { |_, exponent| exponent == 0 }
  }
  # FIXME: Make the code work in such way that the above simplification rule
  # is not needed.

  # This simplification rule simplifies MoleAmount and LitreVolume into Molarity.
  # 
  SR << -> hash {
    begin
      q1, q2, q3 = SY::MoleAmount, SY::LitreVolume, SY::Molarity
    rescue NameError
      return hash
    end
    # transform = -> e1, e2 {
    #   return e1, e2 unless e1 != 0 && e2 != 0 && ( e1 <=> 0 ) != ( e2 <=> 0 )
    #   n = e1 <=> 0
    #   return e1 - n, e2 + n
    # }
    # e1 = ꜧ.delete q1
    # e2 = ꜧ.delete q2
    # ꜧ.merge! q1 => e1, q2 => e2
    # else
    #   ꜧ.update q1 => e1, q2 => e2
    # end
    e1 = hash.delete q1
    e2 = hash.delete q2
    if e1 && e2 && e1 > 0 && e2 < 0 then
      e1 -= 1
      e2 += 1
      e3 = hash.delete q3
      hash.update q3 => ( e3 ? e3 + 1 : 1 )
    end
    hash.update q1 => e1 if e1 && e1 != 0
    hash.update q2 => e2 if e2 && e2 != 0
    return hash

    # # FIXME: This simplification rule looks awful. I'm sure there is a simpler
    # # way of saying what it wants to say. Such as
    # # 
    # SY::Quantity::Term[ MoleAmount: 1, LitreVolume: -1 ] >> 
    #   SY::Quantity::Term[ Molarity: 1 ]
    # # 
    # # or
    # # 
    # SY::Quantity::Term[ MoleAmount: 1, LitreVolume: -1 ] >> SY::Molarity
  }

  # This simplification rule simplifies LitreVolume times Molarity into MoleAmount.
  # 
  SR << -> hash {
    begin
      q1, q2, q3 = SY::MoleAmount, SY::LitreVolume, SY::Molarity
    rescue NameError; return hash end
    e2 = hash.delete q2
    e3 = hash.delete q3
    if e2 && e3 && e2 > 0 && e3 > 0 then
      e2 -= 1
      e3 -= 1
      e1 = hash.delete q1
      hash.update q1 => ( e1 ? e1 + 1 : 1 )
    end
    hash.update q2 => e2 if e2 && e2 != 0
    hash.update q3 => e3 if e3 && e3 != 0

    # FIXME: This simplification rule looks awful. I'm sure there is a simpler
    # way of saying what it wants to say. Such as
    # 
    # SY::Quantity::Term[ LitreVolume: 1, Molarity: 1 ] >> SY::MoleAmount
  }

  class << self
    # FIXME: Figure out what in the heaven did I actually mean
    # by these constructors by reading the code after myself.

    # def singular quantity
    #   self[ SY.Quantity( quantity ) => 1 ]
    # end

    # def empty
    #   self[]
    # end
  end

  # Singular compositions consist of only one quantity.
  #
  def singleton?
    size == 1 && first[1] == 1
  end
  
  # Form #singular? is deprecated.
  # 
  def singular?
    warn "Term#singular? is deprecated. Use #singleton? instead."
    singleton?
  end

  # Atomic compositions are singular terms, whose quantity dimension
  # is a base dimension.
  #
  # FIXME: I don't like calling these kinds of terms atomic. In particular, I
  # don't like the Quantity::Term class caring about dimensions at all.
  # Dimensionality is the business of quantity. Quantity terms are here to
  # basically replace dimensions as their more advanced form capable of
  # capturing the quirks of the user fields.
  # 
  def atomic?
    singular? && first[0].dimension.base?
  end

  # FIXME: I do not understand this coercing of terms at all.

  # # Whether this term coerces another term.
  # # 
  # def coerces? other
  #   # TODO: Think about caching. One way, ie. no way back, once something
  #   # coerces something else, so only false results would have to be re-checked,
  #   # and that only at most once each time after coerces / coerced_by method is
  #   # tampered.
  #   if singular? then
  #     other.singular? && self.first[0].coerces?( other.first[0] )
  #   else
  #     # simplify the compositions a bit
  #     rslt = [].tap do |ary|
  #       find { |qnt, e|
  #         other.find { |qnt2, e2|
  #           ( ( e > 0 && e2 > 0 || e < 0 && e2 < 0 ) && qnt.coerces?( qnt2 ) )
  #             .tap { |rslt| [] << qnt << qnt2 << ( e > 0 ? -1 : 1 ) if rslt }
  #         }
  #       }
  #     end
  #     # and ask recursively
  #     if rslt.empty? then return false else
  #       q, q2, e = rslt
  #       ( self + q.composition * e ).coerces? ( other + q2.composition * e )
  #     end
  #   end
  # end

  # Negates hash exponents.
  # 
  def -@
    self.class[ self.with_values do |v| -v end ]
  end

  # Merges two terms.
  # 
  def + other
    # FIXME: Check how this works out with the idea that
    # each combination of quantities should be represented
    # by only one Term instance.
    self.class[ self.merge( other ) { |_, v1, v2| v1 + v2 } ]
  end

  # Subtracts two terms.
  # 
  def - other
    self + -other
  end

  # Multiplication by a number.
  # 
  def * number
    self.class[ self.with_values do |v| v * number end ]
  end

  # Division by a number.
  # 
  def / number
    self.class[ self.with_values do |val|
                  fail TypeError, "Terms with rational exponents " +
                    "not implemented!" if val % number != 0
                  val / number
                end ]
  end

  # Simplifies the term by applying simplification rules.
  #
  # FIXME: I would like to get rid of these simplification rules.
  # Rather, I would like to call them differently. Compositions,
  # let's say, although there is already Composition class that
  # I defined earlier, which I want to get rid of now...
  # 
  def simplify
    hash = Hash.new.merge self
    SIMPLIFICATION_RULES.each { |rule| rule.( hash ) }
    self.class[ hash ]
  end

  # Reduces the term to the best possible quantity.
  # 
  def to_quantity
    # All the work is delegated to the quantity table:
    SY::Quantity::MULTIPLICATION_TABLE[ self ]
  end

  # Directly (without attempts to simplify) creates a new quantity from self.
  # If self is empty or singular, SY::Amount, resp. the singular quantity
  # in question is returned.
  #
  # FIXME: This method is a little bit too redundant with #to_quantity
  # for my taste. Perhaps it just adds complication to the library.
  # 
  def new_quantity args={}
    SY::Quantity.new args.merge( composition: self )
  end

  # Dimension of the receiver term.
  # 
  def dimension
    map { |quantity, exponent| quantity.dimension * exponent }
      .reduce SY::Dimension.zero, :+
  end

  # Infers the measure of the composition's quantity. ('Measure' means measure
  # of the pertinent standard quantity.)
  # 
  def infer_measure
    map do |qnt, exp|
      if qnt.standardish? then SY::Measure.identity else
        qnt.measure( of: qnt.standard ) ** exp
      end
    end.reduce( SY::Measure.identity, :* )
  end

  # Simple composition is one that is either empty or singular.
  # 
  def simple?
    empty? or singular?
  end

  # Whether it is possible to expand this 
  def irreducible?
    all? { |qnt, exp| qnt.irreducible? }
  end

  # Try to simplify the composition by decomposing its quantities.
  # 
  def expand
    return self if irreducible?
    self.class[ reduce( self.class.empty ) { |cᴍ, pair|
                  qnt, exp = pair
                  ( cᴍ + if qnt.irreducible? then
                         self.class.singular( qnt ) * exp
                       else
                         qnt.composition * exp
                       end )
                } ]
  end
end
