#encoding: utf-8

# Unit of measurement.
# 
class SY::Unit < SY::Magnitude
  require_relative 'unit/sps'

  # include NameMagic

  class << self
    # Let us remember that magnitude is a pair [ quantity, number ]. Basic unit of a given quantity is a named magnitude whose number (ie. size) equals to 1.
    # 
    # FIXME: Figure out how to denote Ruby code in examples.
    # u = Unit.basic of: quantity
    # 
    def standard **options
      # FIXME: No mather how I look at it, there should be only
      # one basic unit object for every quantity. So I should
      # prevent this constructor from constructing more than
      # one basic unit. As for other (non-basic) units ...
      # This reeks of BasicUnit subclass... But I'll let it
      # slide for the time being, perhaps I had good reasons
      # for not making basic unit unique...
      new **options.merge( number: 1 )
    end
  end

  # PREFIX_TABLE.map{|e| e[:full] }.each{ |full_pfx|
  #   eval( "def #{full_pfx}\n" +
  #         "self * #{PREFIXES[full_pfx][:factor]}\n" +
  #         "end" ) unless full_pfx.empty?
  # }

  # Units have names and abbreviations. Necessary assets for unit names are
  # already provided by NameMagic module. Selectors for abbreviations are
  # defined below.
  #
  # selector :abbreviation
  # # FIXME: Consider the following aliases:
  # # alias short abbreviation
  # # alias symbol abbreviation
  # # alias abbr abbreviation

  def initialize of: fail( ArgumentError, "Parameter :of must be supplied!" ),
                 **options
    super
  #   super
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
  end

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
end # class SY::Unit
