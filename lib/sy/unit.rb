#encoding: utf-8

require 'unit/sps'

module SY
  # Unit of measurement.
  # 
  class Unit < Magnitude
    # # Basic unit constructor. Either as
    # # u = Unit.basic of: quantity
    # # or
    # # u = Unit.basic quantity
    # def self.basic opts
    #   new opts.merge( number: 1 )
    # end

    # PREFIX_TABLE.map{|e| e[:full] }.each{ |full_pfx|
    #   eval( "def #{full_pfx}\n" +
    #         "self * #{PREFIXES[full_pfx][:factor]}\n" +
    #         "end" ) unless full_pfx.empty?
    # }

    # # Unlike ordinary magnitudes, units can have names and abbreviations.
    # attr_reader :name, :abbr
    # alias :short :abbr
    # alias :symbol :abbr

    # def initialize oj
    #   super
    #   @name = oj[:name] || oj[:ɴ]
    #   # abbreviation can be introduced by multiple keywords
    #   @abbr = oj[:short] || oj[:abbreviation] || oj[:abbr] || oj[:symbol]
    #   if @name then
    #     # no prefixed names, otherwise there will be multiple prefixes!
    #     @name = @name.to_s              # convert to string
    #     # the unit name is entered into the UNITS_WITHOUT_PREFIX table:
    #     UNITS_WITHOUT_PREFIX[@name] = self
    #     # and FAV_UNITS table keys are updated:
    #     FAV_UNITS[quantity] = FAV_UNITS[quantity] + [ self ]
    #   end
    #   if @abbr then
    #     raise ArgumentError unless @name.present? # name must be given if abbreviation is given
    #     # no prefixed abbrevs, otherwise there will be multiple prefixes!
    #     @abbr = @abbr.to_s           # convert to string
    #     # the unit abbrev is entered into the UNITS_WITHOUT_PREFIX table
    #     UNITS_WITHOUT_PREFIX[abbr] = self
    #   end
    # end

    # # #abs absolute value - Magnitude with number.abs
    # def abs; Magnitude.of quantity, number: n.abs end
      
    # # addition
    # def + other
    #   aE_same_quantity( other )
    #   Magnitude.of( quantity, n: self.n + other.n )
    # end

    # # subtraction
    # def - other
    #   aE_same_quantity( other )
    #   Magnitude.of( quantity, n: self.n - other.n )
    # end

    # # multiplication
    # def * other
    #   case other
    #   when Magnitude
    #     Magnitude.of( quantity * other.quantity, n: self.n * other.n )
    #   when Numeric then [1, other]
    #     Magnitude.of( quantity, n: self.n * other )
    #   else
    #     raise ArgumentError, "magnitudes only multiply with magnitudes and numbers"
    #   end
    # end

    # # division
    # def / other
    #   case other
    #   when Magnitude
    #     Magnitude.of( quantity / other.quantity, n: self.n / other.n )
    #   when Numeric then [1, other]
    #     Magnitude.of( quantity, n: self.n / other )
    #   else
    #     raise ArgumentError, "magnitudes only divide by magnitudes and numbers"
    #   end
    # end

    # # power
    # def ** arg
    #   return case arg
    #          when Magnitude then self.n ** arg.n
    #          else
    #            raise ArgumentError unless arg.is_a? Numeric
    #            Magnitude.of( quantity ** arg, n: self.n ** arg )
    #          end
    # end

    # # #basic? inquirer
    # def basic?; @number == 1 end
  end # class Unit
end # module SY

