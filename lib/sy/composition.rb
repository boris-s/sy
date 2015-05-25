# coding: utf-8

# Composition of quantities.
# 
class SY::Composition < Hash
  # # Simplification rules for quantity combinations.
  # # 
  # SR = SIMPLIFICATION_RULES = []

  # # SY::Amount and SY::Amount.relative are disposable:
  # # 
  # SR << -> ꜧ {
  #   ꜧ.reject! { |qnt, _| qnt == SY::Amount || qnt == SY::Amount.relative }
  # }

  # # Relative quantities of the composition are absolutized:
  # # 
  # SR << -> ꜧ {
  #   ꜧ.select { |qnt, _| qnt.relative? }.each { |qnt, exp|
  #     ꜧ.delete qnt
  #     ꜧ.update qnt.absolute => exp
  #   }
  # }

  # # Any quantities with exponent zero can be deleted:
  # # 
  # SR << -> ꜧ {
  #   ꜧ.reject! { |_, exp| exp == 0 }
  # }

  # # FIXME: This quick fix simplification rule simplifies MoleAmount and
  # # LitreVolume into Molarity. This solution is insufficiently systematic.
  # # 
  # SR << -> ꜧ {
  #   begin
  #     q1, q2, q3 = SY::MoleAmount, SY::LitreVolume, SY::Molarity
  #   rescue NameError
  #     return ꜧ
  #   end
  #   # transform = -> e1, e2 {
  #   #   return e1, e2 unless e1 != 0 && e2 != 0 && ( e1 <=> 0 ) != ( e2 <=> 0 )
  #   #   n = e1 <=> 0
  #   #   return e1 - n, e2 + n
  #   # }
  #   # e1 = ꜧ.delete q1
  #   # e2 = ꜧ.delete q2
  #   # ꜧ.merge! q1 => e1, q2 => e2
  #   # else
  #   #   ꜧ.update q1 => e1, q2 => e2
  #   # end
  #   e1 = ꜧ.delete q1
  #   e2 = ꜧ.delete q2
  #   if e1 && e2 && e1 > 0 && e2 < 0 then
  #     e1 -= 1
  #     e2 += 1
  #     e3 = ꜧ.delete q3
  #     ꜧ.update q3 => ( e3 ? e3 + 1 : 1 )
  #   end
  #   ꜧ.update q1 => e1 if e1 && e1 != 0
  #   ꜧ.update q2 => e2 if e2 && e2 != 0
  #   return ꜧ
  # }

  # # FIXME: This quick fix simplification rule simplifies LitreVolume times
  # # Molarity into MoleAmount. This solution is insufficiently systematic.
  # # 
  # SR << -> ꜧ {
  #   begin
  #     q1, q2, q3 = SY::MoleAmount, SY::LitreVolume, SY::Molarity
  #   rescue NameError; return ꜧ end
  #   e2 = ꜧ.delete q2
  #   e3 = ꜧ.delete q3
  #   if e2 && e3 && e2 > 0 && e3 > 0 then
  #     e2 -= 1
  #     e3 -= 1
  #     e1 = ꜧ.delete q1
  #     ꜧ.update q1 => ( e1 ? e1 + 1 : 1 )
  #   end
  #   ꜧ.update q2 => e2 if e2 && e2 != 0
  #   ꜧ.update q3 => e3 if e3 && e3 != 0
  # }

  # class << self
  #   def singular quantity
  #     self[ SY.Quantity( quantity ) => 1 ]
  #   end

  #   def empty
  #     self[]
  #   end
  # end

  # # Cache for quantity construction.
  # # 
  # QUANTITY_TABLE = Hash.new { |ꜧ, args|
  #   if args.keys.include? [:name] || args.keys.include?( :ɴ ) then
  #     ɴ = args.delete( :name ) || args.delete( :ɴ ) # won't cache name
  #     ꜧ[args].tap { |ɪ| ɪ.name = ɴ }                # recursion
  #   elsif args.keys.include? :mapping then
  #     ᴍ = args.delete( :mapping )                   # won't cache mapping
  #     ꜧ[args].tap { |ɪ| ɪ.set_mapping ᴍ }           # recursion
  #   elsif args.keys.include? :relative then
  #     ʀ = args.delete( :relative ) ? true : false   # won't cache :relative
  #     ꜧ[args].send ʀ ? :relative : :absolute        # recursion
  #   else
  #     cᴍ = SY::Composition[ args ].simplify
  #     ꜧ[args] = if cᴍ != args then ꜧ[ cᴍ ]          # recursion while #simplify
  #               else x = cᴍ.expand # we'll try to #expand now
  #                 if x != cᴍ then ꜧ[ x ]            # recursion while #expand
  #                 else
  #                   if x.empty? then                # use std. ∅ quantity
  #                     SY.Dimension( :∅ ).standard_quantity
  #                   elsif x.singular? then
  #                     x.first[0]                    # unwrap the quantity
  #                   else # create new quantity
  #                     SY::Quantity.new composition: x
  #                   end
  #                 end
  #               end
  #   end
  # }

  # # Singular compositions consist of only one quantity.
  # # 
  # def singular?
  #   size == 1 && first[1] == 1
  # end

  # # Atomic compositions are singular compositions, whose quantity dimension
  # # is a base dimension.
  # # 
  # def atomic?
  #   puts "composition is #{self}" if SY::DEBUG
  #   puts "first[0].dimension is #{first[0].dimension}" if SY::DEBUG
  #   singular? && first[0].dimension.base?
  # end

  # # Whether this composition coerces another compotision.
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

  # # Returns a new instance with same hash.
  # # 
  # def +@
  #   self.class[ self ]
  # end

  # # Negates hash exponents.
  # # 
  # def -@
  #   self.class[ self.with_values do |v| -v end ]
  # end

  # # Merges two compositions.
  # # 
  # def + other
  #   self.class[ self.merge( other ) { |_, v1, v2| v1 + v2 } ]
  # end

  # # Subtracts two compositions.
  # # 
  # def - other
  #   self + -other
  # end

  # # Multiplication by a number.
  # # 
  # def * number
  #   self.class[ self.with_values do |v| v * number end ]
  # end

  # # Division by a number.
  # # 
  # def / number
  #   self.class[ self.with_values do |val|
  #                     raise TErr, "Compositions with rational exponents " +
  #                       "not implemented!" if val % number != 0
  #                     val / number
  #                   end ]
  # end

  # # Simplifies a quantity hash by applying simplification rules.
  # # 
  # def simplify
  #   ꜧ = self.to_hash
  #   puts "simplifying #{ꜧ}" if SY::DEBUG
  #   SIMPLIFICATION_RULES.each { |rule| rule.( ꜧ ) }
  #   self.class[ ꜧ ].tap { |_| puts "result is #{_}" if SY::DEBUG }
  # end

  # # Returns the quantity appropriate to this composition.
  # # 
  # def to_quantity args={}
  #   # All the work is delegated to the quantity table:
  #   QUANTITY_TABLE[ args.merge( self ) ]
  # end

  # # Directly (without attempts to simplify) creates a new quantity from self.
  # # If self is empty or singular, SY::Amount, resp. the singular quantity
  # # in question is returned.
  # # 
  # def new_quantity args={}
  #   SY::Quantity.new args.merge( composition: self )
  # end

  # # Dimension of a composition is the sum of its member quantities' dimensions.
  # # 
  # def dimension
  #   map { |qnt, exp| qnt.dimension * exp }.reduce SY::Dimension.zero, :+
  # end

  # # Infers the measure of the composition's quantity. ('Measure' means measure
  # # of the pertinent standard quantity.)
  # # 
  # def infer_measure
  #   puts "#infer_measure; hash is #{self}" if SY::DEBUG
  #   map do |qnt, exp|
  #     puts "#infer_measure: doing quantity #{qnt} with exponent #{exp}!" if SY::DEBUG
  #     if qnt.standardish? then
  #       puts "#{qnt} standardish" if SY::DEBUG
  #       SY::Measure.identity
  #     else
  #       puts "#{qnt} not standardish" if SY::DEBUG
  #       puts "its measure is #{qnt.measure}, class #{qnt.measure.class}" if SY::DEBUG
  #       qnt.measure( of: qnt.standard ) ** exp
  #     end
  #   end.reduce( SY::Measure.identity, :* )
  # end

  # # Simple composition is one that is either empty or singular.
  # # 
  # def simple?
  #   empty? or singular?
  # end

  # # Whether it is possible to expand this 
  # def irreducible?
  #   all? { |qnt, exp| qnt.irreducible? }
  # end

  # # Try to simplify the composition by decomposing its quantities.
  # # 
  # def expand
  #   return self if irreducible?
  #   puts "#expand: #{self} not irreducible" if SY::DEBUG
  #   self.class[ reduce( self.class.empty ) { |cᴍ, pair|
  #                 qnt, exp = pair
  #                 puts "#expand: qnt: #{qnt}, exp: #{exp}" if SY::DEBUG
  #                 puts "cᴍ is #{cᴍ}" if SY::DEBUG
  #                 ( cᴍ + if qnt.irreducible? then
  #                        self.class.singular( qnt ) * exp
  #                      else
  #                        qnt.composition * exp
  #                      end.tap { |x| puts "Adding #{x}." if SY::DEBUG }
  #                   ).tap { |x| puts "Result is #{x}." if SY::DEBUG }
  #               } ]
  #     .tap{ |rslt| puts "#expand: result is #{rslt}" if SY::DEBUG }
  # end
end # class SY::Composition
