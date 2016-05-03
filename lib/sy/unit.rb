# coding: utf-8

# Unit of measurement.
# 
class SY::Unit < SY::Magnitude
  require_relative 'unit/sps'
  ★ NameMagic and permanent_names!

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
      puts "Hello from naming_exec.try! Self is '#{self}'."
      puts "#{nameless_instances.size} nameless instances."

      fail "#{subject} must not be empty!" if empty?
      upcase, downcase = upcase(), downcase()
      unless self == upcase || self == downcase
        « "must be either all upper case or all lower case"
        fail "Name '#{self}' is not acceptable!"
      end
      « "must not start with a full prefix (mili, mega...)"
      SY::PREFIXES.each { |full:, **_|
        fail "Name '#{self} starts with prefix '#{full}'!" if
          downcase.starts_with? full unless
          full.empty? or PROTECTED_NAMES.include? downcase
      }.tap { |x| puts "PREFIXES class is #{x.class}." }
      upcase
    }
  end

  selector :abbreviation
  alias short abbreviation

  class << self
    # Basic unit of a given quantity is a chosen SY::Unit instance
    # whose number equals 1. Example:
    # 
    #   NEWTON = Unit.basic of: Force, short: "N"
    # 
    def basic of:, **named_args
      new **named_args.update( number: 1, quantity: of )
    end

    # Unit of a given quantity. Example:
    #
    #   MINUTE = Unit.of Time, number: 60, abbreviation: "min"
    # 
    def of quantity, **named_args
      new **named_args.update( quantity: quantity )
    end

    # The core constructor of +SY::Unit+ class. Has mandatory
    # parameter +:quantity+, optional parameter +:number+ (defaults
    # to 1) and optional parameter +:abbreviation+ alias +:short+.
    # Naming parameters work as usual for constructors of classes
    # that include +NameMagic+. Abbreviation can only be set if the
    # unit has a name. (Most units are expected to have one.)
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
            puts "Hello from named_exec of #{self}!"
            instance_variable_set :@abbreviation, abbrev.to_s if
              abbreviation
            # Warn about collisions if warnings are on.
            warn_about_method_collisions
          }
        end
      }
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

  private

  # Checks the existing instance methods of the classes that
  # include SY::Units and warns about method collisions for this
  # unit (if the warnings are on). This method may be invoked only
  # after the receiver unit has obtained name and abbreviation, but
  # before any of the user classes has had chance to define a unit
  # method through activation of SY::Units#method_missing.
  # 
  def warn_about_method_collisions
    return nil
    # TODO: Warnings are not implemented yet.
  end
end # class SY::Unit
