# encoding: utf-8

require 'y_support/null_object'
require 'y_support/name_magic'
require 'y_support/core_ext/hash'
require 'y_support/typing'
require 'y_support/unicode'
require 'y_support/abstract_algebra'

require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/string/starts_ends_with'

require_relative 'sy/version'
require_relative 'sy/expressible_in_units'
require_relative 'sy/fixed_assets_of_the_module'
require_relative 'sy/measure'
require_relative 'sy/dimension'
require_relative 'sy/quantity'
require_relative 'sy/composition'
require_relative 'sy/magnitude'
require_relative 'sy/absolute_magnitude'
require_relative 'sy/signed_magnitude'
require_relative 'sy/unit'
require_relative 'sy/matrix'

# The most prominent feature of SY is, that it extends the Numeric class
# with methods corresponding to units and their abbreviations.
#
# In other words, we can say 5.metre, or Rational( 5, 2 ).metre, and the
# computer will understand, that these numbers represent magnitudes of the
# physical quantity SY::Length expressed in the unit SY::METRE. Equally,
# we can use abbreviations (such as 5.m, 2.5.m), prefixes (such as 5.km,
# 5.kilometre, 5.km), exponents (such as 5.m² for 5 square metres) and
# chaining (such as 5.m.s⁻¹ to denote speed of 5 metres per second).
#
# You should definitely learn how to type Unicode exponent characters, such
# as ², ³, ⁻¹ etc. It is possible to use alterantive syntax such as 5.m.s(-1)
# instead of 5.m.s⁻¹, but you should avoid it whenever possible. Unicode
# exponents make the physical models that you will be constructing with SY
# much more readable. And we know that code is (usually) write once, read
# many times. So it pays off to type an extra keystroke when writing the to
# make the model more readable for the many subsequent revisions.
#
# One more remark here would be, that due to the fact, that many unit names
# and abbreviations are very short and common words, there can be collisions.
# For example ActiveSupport already provides handling for time units (hour,
# minute, second etc.), which would collide with SY methods of the same name.
# Since SY relies on method_missing, if these methods are already defined for
# numerics, SY method_missing will not activate and ActiveSupport methods will
# be used. In this particular case, SY methods still can be invoked using
# abbreviations (5.s, 5.h, 5.min)
# 
module SY
  AUTOINCLUDE = true unless defined? ::SY::AUTOINCLUDE
end

Numeric.class_exec { include ::SY::ExpressibleInUnits } if SY::AUTOINCLUDE

# === Instead of introduction
# 
# SY module defines certain usual constants, quantities and units. The best
# introduction to how SY works would be if we take a look at the examples
# of the most common quantities and units right here in the SY module:
# 
module SY
  # Let SY::Amount be a standard dimensionless quantity:
  Amount = Quantity.standard of: Dimension.zero

  # Let SY::UNIT be a standard unit of SY::Amount. Note that the upcase name
  # of the constant "UNIT" implies, via YSupport's NameMagic mixin, that the
  # name of the object becomes :unit and that it is possible to use syntax
  # such as 42.unit to create magnitudes of SY::Amount.
  puts "About to construct UNIT." if SY::DEBUG
  UNIT = Unit.standard of: Amount
  puts "UNIT constructed. SY::Unit instances are " +
    "#{SY::Unit.instance_names}" if SY::DEBUG

  # AVOGADRO_CONSTANT (Nᴀ) is a certain well-known amount of things:
  Nᴀ = AVOGADRO_CONSTANT = 6.02214e23

  # Let SY::MoleAmount be another dimensionless quantity:
  MoleAmount = Quantity.dimensionless coerces: Amount

  # And let SY::MOLE be its standard unit, related to SY::Amount via Nᴀ:
  puts "About to construct MOLE." if SY::DEBUG
  MOLE = Unit.standard of: MoleAmount, short: "mol", amount: Nᴀ * UNIT
  puts SY::Unit.__instances__ if SY::DEBUG
  puts "MOLE constructed. SY::Unit instances are" +
    "#{SY::Unit.instance_names}" if SY::DEBUG

  # === Basic dimension L (length)

  # Let SY::Length be a standard quantity of basic dimension L:
  Length = Quantity.standard of: :L

  # Let SY::METRE be its standard unit.
  METRE = Unit.standard of: Length, short: "m"

  # === Basic dimension M (mass)
  
  # Let SY::Mass be a standard quantity of basic dimension M:
  Mass = Quantity.standard of: :M

  # Let SY::KILOGRAM be its standard unit:
  KILOGRAM = Unit.standard of: Mass, short: "kg"
  # Let SY::GRAM be another unit of SY::Mass, equal to 0.001.kg:
  GRAM = Unit.of Mass, amount: 0.001 * KILOGRAM, short: "g"
  # Let SY::TON be another...
  TON = Unit.of Mass, amount: 1000 * KILOGRAM, short: "t"
  # And SY::DALTON another...
  DALTON = Unit.of Mass,
                   short: "Da",
                   amount: 1.66053892173e-27 * KILOGRAM

  # === Basic dimension T

  # Let SY::Time be a standard quantity of basic dimension T:
  Time = Quantity.standard of: :T

  # Let SY::SECOND be its standard unit:
  SECOND = Unit.standard of: Time, short: "s"
  # Let SY::MINUTE be another unit:
  MINUTE = Unit.of Time, short: "min", amount: 60 * SECOND
  # And SY::HOUR another:
  HOUR = Unit.of Time, short: "h", amount: 60 * MINUTE

  # === Basic dimension Q

  # Let SY::ElectricCharge be a standard quantity of basic dimension Q:
  ElectricCharge = Quantity.standard of: :Q

  # And SY::COULOMB be its standard unit:
  COULOMB = Unit.standard of: ElectricCharge, short: "C"

  # === Basic dimension Θ

  # Let SY::Temperature be a standard quantity of basic dimension Θ:
  Temperature = Quantity.standard of: :Θ

  # And  SY::KELVIN be its standard unit:
  KELVIN = Unit.standard of: Temperature, short: "K"

  # Now let us define a useful constant:
  TP_H₂O = TRIPLE_POINT_OF_WATER = 273.15 * KELVIN

  # Celsius temperature is a little bit peculiar in that it has offset of
  # 273.15.K with respect to Kelvin temperature, and I am not sure whether
  # at this moment SY is handling this right. But nevertheless:
  CelsiusTemperature = Quantity.of :Θ, coerces_to: Temperature

  CELSIUS_MEASURE = SY::Measure.simple_offset( TRIPLE_POINT_OF_WATER.to_f )

  # Degree celsius is SY::CELSIUS
  CELSIUS = Unit.standard( of: CelsiusTemperature,
                           short: '°C', measure: CELSIUS_MEASURE )

  module CelsiusMagnitude
    def + m2
      puts "CelsiusMagnitude#+ method with #{m2}"   # FIXME: This message doesn't show.
      return magnitude amount + m2.amount if
        m2.quantity == SY::Temperature ||
          m2.quantity.colleague == SY::Temperature
      raise QuantityError, "Addition of Celsius temepratures is ambiguous!" if
        m2.quantity == SY::CelsiusTemperature
      super
    end

    def - m2
      puts "CelsiusMagnitude#- method with #{m2}"   # FIXME: This message doesn't show.
      return magnitude amount - m2.amount if
        m2.quantity == SY::Temperature ||
          m2.quantity.colleague == SY::Temperature
      return super.( SY::Temperature ) if m2.quantity == SY::CelsiusTemperature
      super
    end

    # FIXME: #% method etc
  end

  # Making sure that for Celsius temperature, #°C returns absolute magnitude.
  # 
  class Numeric
    def °C
      SY::CelsiusTemperature.absolute.magnitude self
    end
  end

  # FIXME: Make this more systematic.
  # FIXME: Make sure that SI prefixes may not be used with Celsius
  # FIXME: Make sure that highly unusual SI prefixes may not be used

  class << CelsiusTemperature.send( :Magnitude )
    include SY::CelsiusMagnitude
  end

  class << CelsiusTemperature.relative.send( :Magnitude )
    include SY::CelsiusMagnitude
  end

  # alias :°C :celsius                 # with U+00B0 DEGREE SIGN
  # alias :˚C :celsius                 # with U+02DA RING ABOVE
  # alias :℃ :celsius                  # U+2103 DEGREE CELSIUS

  # FahrenheitTemperature = Quantity.of :Θ
  # FAHRENHEIT = Unit.standard of: FahrenheitTemperature, short: '°F'
  # # alias :°F :fahrenheit              # with U+00B0 DEGREE SIGN
  # # alias :˚F :fahrenheit              # with U+02DA RING ABOVE
  # # alias :℉ :fahrenheit               # U+2109 DEGREE FAHRENHEIT
  # # FIXME: Patch FahrenheitTemperature to make it work with SY::Temperature

  
  # HUMAN_BODY_TEMPERATURE = 37.°C.( KELVIN )
  # STANDARD_TEMPERATURE = 25.°C.( KELVIN )
  HUMAN_BODY_TEMPERATURE = TP_H₂O + 37 * KELVIN
  STANDARD_LABORATORY_TEMPERATURE = TP_H₂O + 25 * KELVIN

  # === Dimensionless quantities

  # For now, these are just unimplemented proposals of what users might expect
  # from SY:
  # 
  # degree, alias deg, ° # angle measure
  # arcminute, alias ʹ, ′ # angle measure
  # arcsecond, alias ʹʹ, ′′, ″

  # === Quantities of composite dimensions

  # Quantity SY::Area is obtained by raising quantity SY::Length to 2:
  Area = Length ** 2

  # Quantity SY::Volume is obtained by raising quantity SY::Length to 3:
  Volume = Length ** 3

  # SY::LitreVolume is another quantity of the same dimension as SY::Volume:
  LitreVolume = Quantity.of Volume.dimension, coerces_to: Volume

  # SY::LITRE is the standard unit of SY::LitreVolume:
  LITRE = Unit.standard of: LitreVolume, short: "l", amount: 0.001 * METRE ** 3

  # At this point, there are certain things to note. Since standard units of
  # SY::Area and SY::Volume have not been specified, they are assumed to be
  # simply 1.metre², resp. 1.metre³. But LitreVolume, whose standard unit
  # has been named litre, with abbreviation "l", will from now on present
  # its magnitudes expressed in litres, rather than cubic metres. While
  # theoretically, LitreVolume and Volume both have dimension L³ and both
  # can be used to express volume, LitreVolume in SY conveys the context of
  # chemistry.

  # SY::Molarity is obtained by dividing SY::MoleAmount by SY::LitreVolume:
  Molarity = ( MoleAmount / LitreVolume ).protect!

  # Standard unit of SY::Molarity is SY::MOLAR:
  MOLAR = Unit.standard of: Molarity, short: "M"

  # Let us now note the #protect! directive at the line above defining
  # SY::Molarity. Method #protect! prevents Molarity from understanding itself
  # as merely L⁻³ (or 1/metre³), as would follow from its dimensional analysis.
  # Method #protect! causes Molarity to appreciate its identity as :molar,
  # which is exactly what chemists expect.

  # SY::Frequency, a quantity that many will expect:
  Frequency = 1 / Time

  # SY::HERTZ is its unit:
  HERTZ = Unit.of Frequency, short: "Hz"
  # Fixme: it would be expected that 1.s(-1) would not present itself as 1.Hz,
  # provided that we did not make :hertz standard unit of Frequency

  # Define SY::Speed as SY::Length / SY::Time and make it a standard quantity
  # of its dimension.
  Speed = ( Length / Time ).standard!

  # Similar for SY::Acceleration:
  Acceleration = ( Speed / Time ).standard!

  # For SY::Force...
  Force = ( Acceleration * Mass ).standard!

  # This time, make SY::NEWTON its standard unit:
  NEWTON = Unit.standard of: Force, short: "N"

  # For SY::Energy...
  Energy = ( Force * Length ).standard!

  # make SY::JOULE its standard unit:
  JOULE = Unit.standard of: Energy, short: "J"
  # SY::CALORIE means thermochemical calorie:
  CALORIE = Unit.of Energy, short: "cal", amount: 4.184 * JOULE

  # SY::Power...
  Power = ( Energy / Time ).standard!

  # make SY::WATT its standard unit:
  WATT = Unit.standard of: Power, short: "W"

  # SY::Pressure...
  Pressure = ( Force / Area ).standard!

  # make SY::PASCAL its standard unit:
  PASCAL = Unit.standard of: Pressure, short: "Pa"

  # SY::ElectricCurrent...
  ElectricCurrent = ( ElectricCharge / Time ).standard!

  # make SY::AMPERE its standard unit:
  AMPERE = Unit.standard of: ElectricCurrent, short: "A"

  # SY::ElectricPotential...
  ElectricPotential = ( Energy / ElectricCharge ).standard!

  # make SY::VOLT its standard unit:
  VOLT = Unit.standard of: ElectricPotential, short: "V"

  # TODO: This should raise a friendly error:
  # MOLAR = Unit.standard of: Molarity, short: "M", amount: 1.mol.l⁻¹
  # (normal way of definition is MOLAR = Unit.standard of: Molarity, short: "M"
  # and it has already been defined to boot)

  # SY::Molality...
  Molality = MoleAmount / Mass

  # make SY::MOLAL its unit (but don't make it a standard unit...):
  MOLAL = Unit.of Molality

  # SY::Molecularity...
  Molecularity = Amount / LitreVolume

  # Having defined Joules and Kelvins, we can spell out the Boltzmann constant:
  Kʙ = BOLTZMANN_CONSTANT = 1.380648813e-23 * JOULE / KELVIN
end
