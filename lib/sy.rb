# coding: utf-8
# encoding: utf-8

require 'mathn'

unless defined? SY::UNIT_TEST
  require 'y_support/core_ext'
  require 'y_support/name_magic'
  require 'y_support/flex_coerce'
  require 'y_support/literate'

  require 'active_support/core_ext/module/delegation'
  require 'active_support/core_ext/string/starts_ends_with'

  require_relative 'sy/version'
  require_relative 'sy/prefixes'
  require_relative 'sy/se'
  require_relative 'sy/sps'
  require_relative 'sy/dimension'
  require_relative 'sy/quantity'
  require_relative 'sy/magnitude'
  require_relative 'sy/unit'
  require_relative 'sy/units'
  # require_relative 'sy/matrix'
end

# SY is a library of physical units. It defines classes for
# physical dimensions (SY::Dimension) such as LENGTH, quantities
# (SY::Quantity) such as Speed, Force or Energy, and units, such as
# metre, newton or joule. After you require SY, you can say
# 5.metre, or Rational( 5, 2 ).metre, and the computer will
# understand that these numbers represent magnitudes of the
# physical quantity SY::Length expressed in the unit
# SY::METRE. Equally, we can use abbreviations (such as 5.m,
# 2.5.m), prefixes (such as 5.km, 5.kilometre, 5.km), exponents
# (such as 5.m² for 5 square metres) and chaining (such as 5.m.s⁻¹
# to denote speed of 5 metres per second). Imperial units (miles,
# pounds, inches etc.) are available by require
# 'sy/imperial'. Described behavior is achieved by automatic
# extending of Numeric class when you type require 'sy'. If you
# wish to use SY without extending Numeric class, use require
# 'sy/noinclude'.
#
# SY uses Unicode superscript characters (such as ², ³, ⁻¹) to
# denote unit exponents (such as 1.m³, 1.m.s⁻¹). Please learn to
# type them quickly. Until you learn how to type them efficiently,
# you can use alternative syntax, such as 1.m(3),
# 1.m.s(-1). However, Unicode exponents will make the physical
# models that you will be constructing with SY much more
# readable. And we know that code is (usually) write once, read
# many times. So it pays off to make the model more readable for
# the many subsequent revisions.
#
# Furthermore, due to the fact that some units and their
# abbreviations are very simple words, there can be collisions with
# method names from other libraries. For example ActiveSupport
# already provides handling for time units (hour, minute, second),
# whose names collide with SY methods of the same name. Since SY
# relies on #method_missing to create the unit methods just in time
# when you ask for them, methods defined by ActiveSupport will
# prevent SY from creating its own unit methods. This is a feature,
# not a design error. To access SY methods, you can still use
# abbreviations (5.s, 5.h, 5.min).
# 
# In this file (sy.rb), module SY is defined and along with it, a
# number of frequrently used physical quantities, units and
# physical constants. SY library uses NameMagic mixin (part of
# YSupport) to automagically name quantities and units simply
# by assigning them to constants. Example:
#
# METRE = Unit.standard of: Length, short: "m"
# 
# will make the system immediately know that 5.metre represents a
# magnitude of quantity "Length". This is how the code statements
# in this file work. In case I forgot to include your favorite
# quantity / unit in SY, you are free to define it on your own.
#
module SY
  AUTOINCLUDE = true unless defined? SY::AUTOINCLUDE
  Numeric.class_exec { ★ SY::Units } if SY::AUTOINCLUDE
  Unit.class_exec { ★ SY::Units }

  # === Dimensionless quantities

  Amount = Quantity.standard of: Dimension.zero

  # # Defines quantity term simplification rule.
  # Quantity::Term[ Amount: 1 ] >> Quantity::Term[]

  # # FIXME: The above rule is wrong, because Amount should stay
  # # when alone, but be disposable when in more complex terms.
 
  # # # Perhaps this should be said differently:
  # Amount.disposable! # This method should work only for
  #                    # dimensionless quantities

=begin
  UNIT = Unit.basic of: Amount
  Unit.const_magic
  
  Nᴀ = AVOGADRO_CONSTANT = 6.02214e23

  MoleAmount = Amount / Nᴀ
  MOLE = Unit.basic of: MoleAmount, short: "mol"

  # === Quantities of dimension LENGTH

  Length = Quantity.standard of: Dimension[ :LENGTH ]
  METRE = Unit.basic of: Length, short: "m"

  # === Quantities of dimension MASS
  
  Mass = Quantity.standard of: Dimension[ :MASS ]
  KILOGRAM = Unit.basic of: Mass, short: "kg"
  # FIXME: Make sure magnitudes coerce Numerics.
  # GRAM = Unit 0.001 * KILOGRAM, short: "g"
=end

=begin
  TON = Unit 1000 * KILOGRAM, short: "t"
  DALTON = Unit 1.66053892173e-27 * KILOGRAM, short: "Da"
=end

  # === Quantities of dimension TIME

=begin
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

  # FIXME: We shirked Speed.standard! I wonder what problems will
  # it cause. Maybe the division operator should guess that the
  # constructed quantity is standard because both Length and Time
  # are standard. But this should be confirmed only when NameMagic
  # detects assignment to Speed constant, since there were no
  # earlier named quantities of the dimension L.T⁻¹. Slowly, I no
  # longer think that @standard_quantity should be a property of
  # Dimension instances. But then again, maybe yes, just it should
  # be possible to overwrite it.

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
