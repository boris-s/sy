#encoding: utf-8

# Composition of quantities.
# 
class SY::Composition < Hash
  # Simplification rules for quantity combinations.
  # 
  SR = SIMPLIFICATION_RULES = []

  # SY::Amount and SY::Amount.relative are disposable:
  SR << -> ꜧ {
    ꜧ.reject! { |qnt, _| qnt == SY::Amount || qnt == SY::Amount.relative }
  }
  # Relative quantities of the composition are absolutized:
  SR << -> ꜧ {
    ꜧ.select { |qnt, _| qnt.relative? }.each { |qnt, exp|
      ꜧ.delete qnt
      ꜧ.update qnt.absolute => exp
    }
  }
  # Any quantities with exponent zero can be deleted:
  SR << -> ꜧ {
    ꜧ.reject! { |_, exp| exp == 0 }
  }
  # 
  SR << -> ꜧ {
    begin
      q1, q2, q3 = SY::MoleAmount, SY::LitreVolume, SY::Molarity
    rescue NameError
      return ꜧ
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
    e1 = ꜧ.delete q1
    e2 = ꜧ.delete q2
    if e1 && e2 && e1 > 0 && e2 < 0 then
      e1 -= 1
      e2 += 1
      e3 = ꜧ.delete q3
      ꜧ.update q3 => ( e3 ? e3 + 1 : 1 )
    end
    ꜧ.update q1 => e1 if e1 && e1 != 0
    ꜧ.update q2 => e2 if e2 && e2 != 0
    return ꜧ
  }

  class << self
    def singular quantity
      self[ SY.Quantity( quantity ) => 1 ]
    end

    def empty
      self[]
    end
  end

  # Cache for quantity construction.
  # 
  QUANTITY_TABLE = Hash.new { |ꜧ, args|
    if args[:name] || args[:ɴ] then
      ɴ = args.delete( :name ) || args.delete( :ɴ ) # won't cache name
      ꜧ[args]                                       # recursion
        .tap { |ɪ| ɪ.name = ɴ }                     # and set name afterwards
    elsif args[:mapping] then
      ᴍ = args.delete( :mapping )                   # won't cache mapping
      ꜧ[args]                                       # recursion
        .tap { |ɪ| ɪ.set_mapping ᴍ }                # and set mapping afterwards
    else
      ʀ = args.delete( :relative ) ? true : false   # will cache :relative, but
      # has to remove it temporarily, while simplification is being done
      cᴍ = SY::Composition[ args ].simplify
      ɪ = if cᴍ != args then                        # #simplify did bring change
            ꜧ[ cᴍ.merge! relative: ʀ ]              # recursion
          else # no change from #simplify
            x = cᴍ.expand                           # we'll try to #expand now
          if x != cᴍ then                           # #expand did bring change
            ꜧ[ x.merge! relative: ʀ ]               # recursion
          else # no change from #expand either
            if x.empty? then # use standard dimensionless quantity
              std_0_qnt = SY.Dimension( :∅ ).standard_quantity
              ʀ ? std_0_qnt.relative : std_0_qnt.absolute
            elsif x.singular? then
              qnt = x.first[0]                      # unwrap the quantity
              qnt.relative? == ʀ ? qnt : qnt.colleague
            else
              x.new_quantity( relative: ʀ )         # construct new quantity
            end
          end
        end
      ꜧ[ args.merge( relative: ʀ ) ] = ɪ            # act of caching
    end
  }

  # Singular compositions consist of only one quantity.
  # 
  def singular?
    size == 1 && first[1] == 1
  end

  # Atomic compositions are singular compositions, whose quantity dimension
  # is a base dimension.
  # 
  def atomic?
    singular? && first[0].dimension.base?
  end

  # Returns a new instance with same hash.
  # 
  def +@
    self.class[ self ]
  end

  # Negates hash exponents.
  # 
  def -@
    self.class[ self.with_values do |v| -v end ]
  end

  # Merges two compositions.
  # 
  def + other
    self.class[ self.merge( other ) { |_, v1, v2| v1 + v2 } ]
  end

  # Subtracts two compositions.
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
                      raise TErr, "Compositions with rational exponents " +
                        "not implemented!" if val % number != 0
                      val / number
                    end ]
  end

  # Simplifies a quantity hash by applying simplification rules.
  # 
  def simplify
    ꜧ = self.to_hash
    puts "simplifying #{ꜧ}" if SY::DEBUG
    SIMPLIFICATION_RULES.each { |rule| rule.( ꜧ ) }
    self.class[ ꜧ ].tap { |_| puts "result is #{_}" if SY::DEBUG }
  end

  # Returns the quantity appropriate to this composition.
  # 
  def to_quantity args={}
    # All the work is delegated to the quantity table:
    QUANTITY_TABLE[ args.merge( self ) ]
  end

  # Directly (without attempts to simplify) creates a new quantity from self.
  # If self is empty or singular, SY::Amount, resp. the singular quantity
  # in question is returned.
  # 
  def new_quantity args={}
    SY::Quantity.new args.merge( composition: self )
  end

  # Dimension of a quantity composition is the sum of its dimensions.
  # 
  def dimension
    map { |qnt, exp| qnt.dimension * exp }.reduce SY::Dimension.zero, :+
  end

  # Infers the mapping of the composition's quantity. (Mapping
  # defines mapping of a quantity to the standard quantity of its dimension.)
  # 
  def infer_mapping
    puts "#infer_mapping; hash is #{self}" if SY::DEBUG
    map do |qnt, exp|
      qnt.standardish? ? SY::Mapping.identity :
        qnt.mapping_to( qnt.standard ) ** exp
    end.reduce( SY::Mapping.identity, :* )
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
    puts "#expand: #{self} not irreducible" if SY::DEBUG
    self.class[ reduce( self.class.empty ) { |cᴍ, pair|
                  qnt, exp = pair
                  puts "#expand: qnt: #{qnt}, exp: #{exp}" if SY::DEBUG
                  puts "cᴍ is #{cᴍ}" if SY::DEBUG
                  ( cᴍ + if qnt.irreducible? then
                         self.class.singular( qnt ) * exp
                       else
                         qnt.composition * exp
                       end.tap { |x| puts "Adding #{x}." if SY::DEBUG }
                    ).tap { |x| puts "Result is #{x}." if SY::DEBUG }
                } ]
      .tap{ |rslt| puts "#expand: result is #{rslt}" if SY::DEBUG }
  end
end # class SY::Composition
