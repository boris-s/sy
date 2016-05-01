# coding: utf-8

# Magnitude is a number expressing amount of a physical
# quantity. It is basically pair [ quantity, number ] capable, with
# certain specifics, of mathematical operations typical for Numeric
# class. The distinctions are eg. that magnitudes of different
# quantities can't be added or subtracted, or SY::Quantity::Error
# is raised. Multiplication of two magnitudes results in a
# magnitude of a quantity that is the product of the factors'
# quantities.
# 
class SY::Magnitude < Struct.new :quantity, :number
  # ★ ExpressibleInUnits
  ★ Comparable
  ★ FlexCoerce

  coerces Numeric, :* do |o1, o2| o2 * o1 end

  # This error indicates an attempt to create impossible magnitude.
  # 
  class Error < TypeError; end

  class << self
    # This constructor expects a quantity and a named parameter
    # +:number+.
    # 
    def of quantity, number:
      self[ quantity, number ]
    end
  end
    
#     delegate :dimension, :basic_unit, :fav_units, to: :quantity

#     # A magnitude is basically a pair [quantity, number].
#     def initialize oj
#       @quantity = oj[:quantity] || oj[:of]
#       raise ArgumentError unless @quantity.kind_of? Quantity
#       @number = oj[:number] || oj[:n]
#       raise ArgumentError, "Negative number of the magnitude: #@number" unless
#         @number >= 0
#     end
#     # idea: for more complicated units (offsetted, logarithmic etc.),
#     # conversion closures from_basic_unit, to_basic_unit

  # Same quantity magnitudes compare by their numbers. Related
  # quantities are first converted to the same quantity using their
  # functions, and compared thereafter.
  # 
  def <=> other
    # TODO: This method just might call coerce.
    if quantity == other.quantity then
      number <=> other.number
    else
      number <=> ( quantity << other.quantity ).( other.number )
    end
  end

  def aE_same_quantity other
    raise ArgumentError unless other.kind_of? Magnitude
    unless self.dimension == other.dimension
      raise ArgumentError, "Magnitudes not of the same " +
        "dimension (#{dimension} vs. #{other.dimension})."
    end
    unless self.quantity == other.quantity
      raise ArgumentError, "Although the dimensions of the " +
        "magnitudes match, they are not the same quantity " +
        "(#{quantity.inspect} vs. #{other.quantity.inspect})."
    end
  end

#     # #abs absolute value - Magnitude with number.abs
#     def abs; self.class.of quantity, number: n.abs end

  # Negation. Results in a magnitude of the same quantity with negated
  # number.
  #
  def -@
    # FIXME
  end
      
  # Addition. A magnitude can be added only to a magnitude of the same
  # quantity.
  # 
  def + other
    # aE_same_quantity( other )
    # self.class.of( quantity, n: self.n + other.n )
  end

  # Subtraction. A magnitude can be subtracted only by a magnitude of the
  # same quantity.
  # 
  def - other
    # aE_same_quantity( other )
    # self.class.of( quantity, n: self.n - other.n )
  end

  # Multiplication. A magnitude can be multiplied by a number or
  # another magnitude.
  # 
  def * other
    case other
    when SY::Magnitude then
      self.class[ quantity * other.quantity,
                  number * other.number ]
    when Numeric then
      self.class[ quantity, number * other ]
    else
      fail ArgumentError, "Magnitudes only multiply with " +
                          "magnitudes and numbers!"
    end
  end

  # Division. A magnitude can only be divided by a number or
  # another magnitude (of arbitrary quantity).
  # 
  def / other
    # case other
    # when Magnitude
    #   self.class.of( quantity / other.quantity, n: self.n / other.n )
    # when Numeric then [1, other]
    #   self.class.of( quantity, n: self.n / other )
    # else
    #   raise ArgumentError, "magnitudes only divide by magnitudes and numbers"
    # end
  end

  # Raising to a power. A magnitude can (thus far) only be raised
  # to a number (Numeric class).
  # 
  def ** arg
    argument arg do must.be_a Numeric end
    # self.class.of( quantity ** arg, n: self.n ** arg )
    # # return case arg
    # #        when Magnitude then self.n ** arg.n
    # #        else
    # #          raise ArgumentError unless arg.is_a? Numeric
    # #          self.class.of( quantity ** arg, n: self.n ** arg )
    # #        end
  end

#     # Gives the magnitude as a numeric value in a given unit. Of course,
#     # the unit must be of the same quantity and dimension.
#     def numeric_value_in other
#       case other
#       when Symbol, String then
#         other = other.to_s.split( '.' ).reduce 1 do |pipe, sym| pipe.send sym end
#       end
#       aE_same_quantity( other )
#       self.n / other.number
#     end
#     alias :in :numeric_value_in

#     def numeric_value_in_basic_unit
#       numeric_value_in BASIC_UNITS[self.quantity]
#     end
#     alias :to_f :numeric_value_in_basic_unit

#     # Changes the quantity of the magnitude, provided that the dimensions
#     # match.
#     def is_actually! qnt
#       raise ArgumentError, "supplied quantity dimension must match!" unless
#         qnt.dimension == self.dimension
#       @quantity = qnt
#       return self
#     end
#     alias call is_actually!

#     #Gives a string expressing the magnitude in given units.
#     def string_in_unit unit
#       if unit.nil? then
#         number.to_s
#       else
#         str = ( unit.symbol || unit.name ).to_s
#         ( str == "" ? "%.2g" : "%.2g.#{str}" ) % numeric_value_in( unit )
#       end
#     end

  # #to_s converter gives the magnitude in its most favored units.
  # 
  def to_s
    super
    # FIXME
#       unit = fav_units[0]
#       str = if unit then string_in_unit( unit )
#             else # use fav_units of basic dimensions
#               hsh = dimension.to_hash
#               symbols, exponents = hsh.each_with_object Hash.new do |pair, memo|
#                 sym, val = pair
#                 u = Dimension.basic( sym ).fav_units[0]
#                 memo[u.symbol || u.name] = val
#               end.to_a.transpose
#               sps = SPS.( symbols, exponents )
#               "%.2g#{sps == '' ? '' : '.' + sps}" % number
    #             end
  end

  # #inspect
  def inspect
    super
    # FIXME
    # "magnitude #{to_s} of #{quantity}"
  end
  
  private

#     def same_dimension? other
#       case other
#       when Numeric then dimension.zero?
#       when Magnitude then dimension == other.dimension
#       when Quantity then dimension == other.dimension
#       when Dimension then dimension == other
#       else
#         raise ArgumentError, "The object (#{other.class} class) does not " +
#           "have defined dimension comparable to SY::Dimension"
#       end
#     end

#     def same_quantity? other
#       case other
#         when Magnitude then 

  # Legacy method used to assert that another magnitude is of the
  # same quantity as the receiver.
  # 
  # def aE_same_quantity other
  #   raise ArgumentError unless other.kind_of? Magnitude
  #   unless self.dimension == other.dimension
  #     raise ArgumentError, "Magnitudes not of the same " +
  #       "dimension (#{dimension} vs. #{other.dimension})."
  #   end
  #   unless self.quantity == other.quantity
  #     raise ArgumentError, "Although the dimensions of the " +
  #       "magnitudes match, they are not the same quantity " +
  #       "(#{quantity.inspect} vs. #{other.quantity.inspect})."
  #   end
  # end
end # class SY::Magnitude
  
# SignedMagnitude is a legacy class that allowed its number to be
# negative. Ordinary Magnitude class was only allowed to be
# positive. At this moment, SY::Magnitude allows its number to be
# both positive and negative. There might be some use for
# positive-only variety of Magnitudes, such as for expressing
# Temperature. (I'm aware of the possibility of negative
# temperatures, but this is too advanced a concept for SY.)
# Main use for absolute magnitudes in the earlier version of SY was
# as units, since negative amount of something cannot physically
# exist.
#
# TODO: I would de-emphasize absolute magnitudes. SY::Unit class
# should be simply a named subclass of SY::Magnitude. Absolute
# magnitudes would be constructed occassionally, such as with
# mass or temperature, their constructors would complain should a
# negative number be given to them. Connected to this are possible
# other constraints of constructed magnitudes. Constraints on
# magnitudes are low priority and would – if taken with sufficient
# seriousness – introduce great complication into quantity
# arithmethics.
# 
class SY::SignedMagnitude < SY::Magnitude
  # def initialize oo
  #   @quantity = oo[:quantity] || oo[:of]
  #   raise ArgumentError unless @quantity.kind_of? Quantity
  #   @number = oo[:number] || oo[:n]
  # end
end # SY::Magnitude
