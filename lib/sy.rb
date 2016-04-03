# encoding: utf-8

unless defined? SY::UNIT_TEST
  # require 'y_support/null_object'
  require 'y_support/name_magic'
  require 'y_support/core_ext/hash'
  require 'y_support/core_ext/array'
  require 'y_support/core_ext/module'
  # require 'y_support/core_ext/class'
  require 'y_support/typing'
  require 'y_support/flex_coerce'
  require 'y_support/unicode'
  # require 'y_support/abstract_algebra'

  require 'active_support/core_ext/module/delegation'
  # require 'active_support/core_ext/array/extract_options'
  # require 'active_support/core_ext/string/starts_ends_with'

  # require 'flex_coerce'

  require_relative 'sy/version'
  require_relative 'expressible_in_units'
  require_relative 'sy/prefixes'
  require_relative 'sy/se'
  require_relative 'sy/sps'
  require_relative 'sy/dimension'
  require_relative 'sy/quantity'
  require_relative 'sy/magnitude'
  require_relative 'sy/unit'
  # require_relative 'sy/matrix'
end

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
# The module SY defines certain physical quantities, units and frequently
# used constants. SY library uses NameMagic mixin ('y_support/name_magic') to
# automagically define the unit methods as soon as the newly defined unit is
# assigned to its constant. For example, as soon as we execute the line
#
# METRE = Unit.standard.of Length, short: "m"
# 
# the system will immediately know that expression 42.m is a number expressed
# in metres. Below, you can find all the metric physical quantities, units
# and constants introduced in SY. (Imperial units are found in the file
# sy/imperial.rb.) The user is free to define additional own quantities and
# units.
#
module SY
  AUTOINCLUDE = true unless defined? SY::AUTOINCLUDE
  # Numeric.class_exec { include ExpressibleInUnits } if SY::AUTOINCLUDE

  # === Dimensionless quantities

  Amount = Quantity.standard of: Dimension.zero

  # # Defines quantity term simplification rule.
  # Quantity::Term[ Amount: 1 ] >> Quantity::Term[]

  UNIT = Unit.standard of: Amount
  
  Nᴀ = AVOGADRO_CONSTANT = 6.02214e23

  # MoleAmount = Amount / Nᴀ
=begin
  MOLE = Unit.standard of: MoleAmount, short: "mol"

  # === Quantities of dimension LENGTH

  Length = Quantity.standard of: Dimension[ :LENGTH ]
  METRE = Unit.standard of: Length, short: "m"

  # === Quantities of dimension MASS
  
  Mass = Quantity.standard of: Dimension[ :MASS ]
  KILOGRAM = Unit.standard of: Mass, short: "kg"
  GRAM = Unit 0.001 * KILOGRAM, short: "g"
  TON = Unit 1000 * KILOGRAM, short: "t"
  DALTON = Unit 1.66053892173e-27 * KILOGRAM, short: "Da"

  # === Quantities of dimension TIME

  Time = Quantity.standard of: Dimension[ :TIME ]
  SECOND = Unit.standard of: Time, short: "s"
  MINUTE = Unit 60 * SECOND, short: "min"
  HOUR = Unit 60 * MINUTE, short: "h"
  DAY = Unit 24 * HOUR
  WEEK = Unit 7 * DAY
  SYNODIC_MONTH = Unit 29.530589 * DAY, short: "month"
  JULIAN_YEAR = Unit 365.25 * DAY, short: "year"

  # === Quantities of dimension ELECTRIC_CHARGE

  ElectricCharge = Quantity.standard of: Dimension[ :ELECTRIC_CHARGE ]
  COULOMB = Unit.standard of: ElectricCharge, short: "C"

  # === Quantities of dimension TEMPERATURE

  Temperature = Quantity.standard of: Dimension[ :TEMPERATURE ]
  KELVIN = Unit.standard of: Temperature, short: "K"

  TP_H₂O = TRIPLE_POINT_OF_WATER = 273.15 * KELVIN

  CelsiusTemperature = Temperature - TP_H₂O

  CELSIUS = Unit.standard of: CelsiusTemperature, short: '°C'

  # # FIXME: Make sure that SI prefixes may not be used with Celsius

  # === Quantities of composite dimensions

  Area = Length ** 2
  Volume = Length ** 3
  LitreVolume = 0.001 * Volume
  LITRE = Unit.standard of: LitreVolume, short: "l"

  Molarity = MoleAmount / LitreVolume
  MOLAR = Unit.standard of: Molarity, short: "M"
  # FIXME: We have shirked MOLAR.protect!, see the old style sy.rb.

  Frequency = 1 / Time
  HERTZ = Unit.of Frequency, short: "Hz"
  Speed = Length / Time
  # FIXME: We shirked Speed.standard! I wonder what problems will it cause.
  # Maybe the division operator should guess that the constructed quantity is
  # standard because both Length and Time are standard. But this should be
  # confirmed only when NameMagic detects assignment to Speed constant, since
  # there were no earlier named quantities of the dimension L.T⁻¹. Slowly,
  # I no longer think that @standard_quantity should be a property of
  # Dimension instances. But then again, maybe yes, just it should be possible
  # to overwrite it.

  SPEED_OF_LIGHT = 299_792_458 * METRE / SECOND

  LIGHTYEAR = Unit SPEED_OF_LIGHT * JULIAN_YEAR, short: "ly"

  Acceleration = Speed / Time
  Force = Acceleration * Mass
  NEWTON = Unit.standard of: Force, short: "N"
  Energy = Force * Length

  JOULE = Unit.standard of: Energy, short: "J"
  CALORIE = Unit 4.184 * JOULE, short: "cal"

  Power = Energy / Time
  WATT = Unit.standard of: Power, short: "W"

  WATTHOUR = Unit WATT * HOUR, short: "Wh"

  Pressure = Force / Area
  PASCAL = Unit.standard of: Pressure, short: "Pa"

  ElectricCurrent = ElectricCharge / Time
  AMPERE = Unit.standard of: ElectricCurrent, short: "A"

  ElectricPotential = Energy / ElectricCharge
  VOLT = Unit.standard of: ElectricPotential, short: "V"

  Molality = MoleAmount / Mass
  MOLAL = Unit.of Molality

  Molecularity = Amount / LitreVolume

  Kʙ = BOLTZMANN_CONSTANT = 1.380648813e-23 * JOULE / KELVIN

  ELEMENTARY_CHARGE = 1.60217656535e-19 * COULOMB

  ELECTRONVOLT = Unit ELEMENTARY_CHARGE * VOLT, short: "eV"
=end
end
