# coding: utf-8
class SY::Quantity
  # Simplification rules for quantity combinations.
  # 
  SR = SIMPLIFICATION_RULES = []

  # SY::Amount is disposable:
  # 
  SR << -> hash {
    hash.reject! { |quantity, _| quantity == SY::Amount }
  }
  # # Make a way to say it simply, such as by:
  # Quantity::Term[ Amount: 1 ] >> Quantity::Term[]

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
end
