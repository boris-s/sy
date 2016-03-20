#encoding: utf-8

module SY
  # Magnitude of a metrological quantity
  # 
  class Magnitude
#     include UnitMethodsMixin
#     include Comparable

#     def self.of qnt, oo
#       oo = { n: oo } unless oo.is_a? Hash
#       n = oo[:number] || oo[:n] or raise AE, "Magnitude number not given!"
#       named_args = { quantity: qnt }.merge! case n
#                                             when Numeric then { n: n }
#                                             else { n: n.to_f } end
#       if n < 0 then
#         SignedMagnitude.new oo.merge( named_args ).merge!( sign: :- )
#       else new oo.merge( named_args ) end
#     end
    
#     attr_reader :quantity, :number
#     alias :n :number
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

#     # SAME QUANTITY magnitudes compare by their numbers
#     def <=> other
#       aE_same_quantity( other )
#       self.n <=> other.n
#     end

#     # #abs absolute value - Magnitude with number.abs
#     def abs; self.class.of quantity, number: n.abs end
      
#     # addition
#     def + other
#       aE_same_quantity( other )
#       self.class.of( quantity, n: self.n + other.n )
#     end

#     # subtraction
#     def - other
#       aE_same_quantity( other )
#       self.class.of( quantity, n: self.n - other.n )
#     end

#     # multiplication
#     def * other
#       case other
#       when Magnitude
#         self.class.of( quantity * other.quantity, n: self.n * other.n )
#       when Numeric then [1, other]
#         self.class.of( quantity, n: self.n * other )
#       else
#         raise ArgumentError, "magnitudes only multiply with magnitudes and numbers"
#       end
#     end

#     # division
#     def / other
#       case other
#       when Magnitude
#         self.class.of( quantity / other.quantity, n: self.n / other.n )
#       when Numeric then [1, other]
#         self.class.of( quantity, n: self.n / other )
#       else
#         raise ArgumentError, "magnitudes only divide by magnitudes and numbers"
#       end
#     end

#     # power
#     def ** arg
#       return case arg
#              when Magnitude then self.n ** arg.n
#              else
#                raise ArgumentError unless arg.is_a? Numeric
#                self.class.of( quantity ** arg, n: self.n ** arg )
#              end
#     end

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

#     # #to_s converter gives the magnitude in its most favored units
#     def to_s
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
#     end

#     # #inspect
#     def inspect; "magnitude #{to_s} of #{quantity}" end

#     private

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

#     def aE_same_quantity other
#       raise ArgumentError unless other.kind_of? Magnitude
#       unless self.dimension == other.dimension
#         raise ArgumentError, "Magnitudes not of the same dimension " +
#           "(#{dimension} vs. #{other.dimension})."
#       end
#       unless self.quantity == other.quantity
#         raise ArgumentError, "Although the dimensions of the magnitudes " +
#           "match, they are not the same quantity " +
#           "(#{quantity.inspect} vs. #{other.quantity.inspect})."
#       end
#     end
#     alias :aE_same_quantity :aE_same_quantity
#   end # class Magnitude
  
#   # SignedMagnitude allows its number to be negative
#   class SignedMagnitude < Magnitude
#     def initialize oo
#       @quantity = oo[:quantity] || oo[:of]
#       raise ArgumentError unless @quantity.kind_of? Quantity
#       @number = oo[:number] || oo[:n]
#     end
#   end
# end

# module SY
#   # Unit of measurement.
#   # 
#   class Unit < Magnitude
#     # Basic unit constructor. Either as
#     # u = Unit.basic of: quantity
#     # or
#     # u = Unit.basic quantity
#     def self.basic opts
#       new opts.merge( number: 1 )
#     end

#     PREFIX_TABLE.map{|e| e[:full] }.each{ |full_pfx|
#       eval( "def #{full_pfx}\n" +
#             "self * #{PREFIXES[full_pfx][:factor]}\n" +
#             "end" ) unless full_pfx.empty?
#     }

#     # Unlike ordinary magnitudes, units can have names and abbreviations.
#     attr_reader :name, :abbr
#     alias :short :abbr
#     alias :symbol :abbr

#     def initialize oj
#       super
#       @name = oj[:name] || oj[:ɴ]
#       # abbreviation can be introduced by multiple keywords
#       @abbr = oj[:short] || oj[:abbreviation] || oj[:abbr] || oj[:symbol]
#       if @name then
#         # no prefixed names, otherwise there will be multiple prefixes!
#         @name = @name.to_s              # convert to string
#         # the unit name is entered into the UNITS_WITHOUT_PREFIX table:
#         UNITS_WITHOUT_PREFIX[@name] = self
#         # and FAV_UNITS table keys are updated:
#         FAV_UNITS[quantity] = FAV_UNITS[quantity] + [ self ]
#       end
#       if @abbr then
#         raise ArgumentError unless @name.present? # name must be given if abbreviation is given
#         # no prefixed abbrevs, otherwise there will be multiple prefixes!
#         @abbr = @abbr.to_s           # convert to string
#         # the unit abbrev is entered into the UNITS_WITHOUT_PREFIX table
#         UNITS_WITHOUT_PREFIX[abbr] = self
#       end
#     end

#     # #abs absolute value - Magnitude with number.abs
#     def abs; Magnitude.of quantity, number: n.abs end
      
#     # addition
#     def + other
#       aE_same_quantity( other )
#       Magnitude.of( quantity, n: self.n + other.n )
#     end

#     # subtraction
#     def - other
#       aE_same_quantity( other )
#       Magnitude.of( quantity, n: self.n - other.n )
#     end

#     # multiplication
#     def * other
#       case other
#       when Magnitude
#         Magnitude.of( quantity * other.quantity, n: self.n * other.n )
#       when Numeric then [1, other]
#         Magnitude.of( quantity, n: self.n * other )
#       else
#         raise ArgumentError, "magnitudes only multiply with magnitudes and numbers"
#       end
#     end

#     # division
#     def / other
#       case other
#       when Magnitude
#         Magnitude.of( quantity / other.quantity, n: self.n / other.n )
#       when Numeric then [1, other]
#         Magnitude.of( quantity, n: self.n / other )
#       else
#         raise ArgumentError, "magnitudes only divide by magnitudes and numbers"
#       end
#     end

#     # power
#     def ** arg
#       return case arg
#              when Magnitude then self.n ** arg.n
#              else
#                raise ArgumentError unless arg.is_a? Numeric
#                Magnitude.of( quantity ** arg, n: self.n ** arg )
#              end
#     end

#     # #basic? inquirer
#     def basic?; @number == 1 end
  end # class Magnitude
end # module SY
