# coding: utf-8

# Unit of measurement.
# 
class SY::Unit < SY::Magnitude
  require_relative 'unit/sps'
  ★ NameMagic

  # Since kilogram is officially the basic unit of mass, it would
  # be somehow stupid to disallow this unit name on the grounds
  # that it begins with "kilo". Blame the SI committee.
  # 
  PROTECTED_NAMES = [ "kilogram" ]

  # Let's make sure the user won't define unit names which
  # perchance start with one of the standard prefixes. Hook
  # #naming_exec is used to censor out unsuitable unit names.
  # 
  naming_exec do |ɴ|
    "unit name".( ɴ.to_s ).raises( NameError ).try {
      « "must be either all upper case or all lower case"
      fail unless self == upcase || self == downcase
      « "must not start with a full prefix (kilo, mili, mega...)"
      SY::PREFIXES.each { |pfx|
        if downcased_version.starts_with? pfx[:full] then
          « "starts with '#{pfx[:full]}' prefix!"
          fail unless pfx[:full].empty? or
                      PROTECTED_NAMES.include? downcase
        end
      }
    }
  end

  selector :abbreviation
  alias short abbreviation

  class << self
    # Basic unit of a given quantity is a chosen SY::Unit instance
    # whose number equals 1.
    # 
    # FIXME: Read Rdoc documentation and figure whether it is
    # possible to mark up Ruby code for added prettiness.
    # 
    # u = Unit.basic of: quantity
    # 
    def basic of:, **named_args
      new **named_args.update( number: 1, quantity: of )
    end

    # FIXME: Write the description.
    # FIXME: Write the tests for this method.
    # 
    def of quantity, **named_args
      new **named_args.update( quantity: of )
    end

    # This is the core constructor of +SY::Unit+ class. It takes
    # mandatory named argument +:quantity+, optional named argument
    # +:number+ (defaults to 1) and optional arguments to set the
    # name and abbreviation of the unit. Naming works as usual for
    # classes using +NameMagic", abbreviation is set by optional
    # argument +:short+, alias +:abbreviation+. Abbreviation can be
    # only given if unit name is given.
    # 
    def new quantity:, number: 1.0, **nn
      self[ quantity, number ].tap { |inst|
        named_args nn do
          may_have :short, alias: :abbreviation
          abbrev = delete( :short )
          consider_any_remaining_keys_unrecognized
          » "nameless instances should not have abbreviations"
          » "abbreviation property is therefore set upon naming"
          inst.named_exec {
            instance_variable_set :@abbreviation, abbrev.to_s if
              abbreviation
            # Warn about collisions if warnings are on.
            warn_about_method_collisions_of( self )
          }
        end
      }
    end

    # Checks the existing instance methods of the user classes of
    # SY::ExpressibleInUnits and warns about method collisions for
    # a specifc newly-defined unit given as an argument.
    # 
    def warn_about_method_collisions_of( unit )
      return nil # TODO: Warnings are not implemented yet.
    end
  end # class << self

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
