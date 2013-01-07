#encoding: utf-8

require 'y_support/all'
require 'bigdecimal'

  # require './sy/version'
  # require './sy/expressible_in_units'
  # require './sy/fixed_assets_of_the_module'
  # require './sy/dimension'
  # require './sy/quantity'
  # require './sy/magnitude'
  # require './sy/absolute_magnitude'
  # require './sy/signed_magnitude'
  # require './sy/unit'

  require_relative 'sy/version'
  require_relative 'sy/expressible_in_units'
  require_relative 'sy/fixed_assets_of_the_module'
  require_relative 'sy/dimension'
  require_relative 'sy/quantity'
  require_relative 'sy/magnitude'
  require_relative 'sy/absolute_magnitude'
  require_relative 'sy/signed_magnitude'
  require_relative 'sy/unit'


# The hallmark of SY is its extension of the Numeric class with methods
# corresponding to selected metrological units and their abbreviations.
# 
Numeric.module_exec { include SY::ExpressibleInUnits }

module SY
  DEBUG = true

  # === Basic settings

  # Digits to take when constructing magnitude from a low-precision numeric.
  #
  NUMERIC_FILTER = 6

  Nᴀ = AVOGADRO_CONSTANT = 6.02214e23

  # === Basic dimension L

  Length = Quantity.standard of: :L
  METRE = Unit.standard of: Length, short: "m"

  # === Basic dimension M

  Mass = Quantity.standard of: :M
  KILOGRAM = Unit.standard of: Mass, short: "kg"
  GRAM = Unit.of Mass, amount: 0.001.kg, short: "g"
  TON = Unit.of Mass, amount: 1000.kg, short: "t"
  DALTON = Unit.of Mass, short: "Da", amount: 1.66053892173e-27.kg

  # === Basic dimension T

  Time = Quantity.standard of: :T
  SECOND = Unit.standard of: Time, short: "s"
  MINUTE = Unit.of Time, short: "min", amount: 60.s
  HOUR = Unit.of Time, short: "h", amount: 60.min

  # === Basic dimension Q

  ElectricCharge = Quantity.standard of: :Q
  COULOMB = Unit.standard of: ElectricCharge, short: "C"

  # === Basic dimension Θ

  Temperature = Quantity.standard of: :Θ
  KELVIN = Unit.standard of: Temperature, short: "K"

  CelsiusTemperature = Quantity.of :Θ
  CELSIUS = Unit.standard of: CelsiusTemperature, short: '°C'
  # FIXME: Patch CelsiusTemperature to make it work with SY::Temperature
  # alias :°C :celsius                 # with U+00B0 DEGREE SIGN
  # alias :˚C :celsius                 # with U+02DA RING ABOVE
  # alias :℃ :celsius                  # U+2103 DEGREE CELSIUS

  # FahrenheitTemperature = Quantity.of :Θ
  # FAHRENHEIT = Unit.standard of: FahrenheitTemperature, short: '°F'
  # # alias :°F :fahrenheit              # with U+00B0 DEGREE SIGN
  # # alias :˚F :fahrenheit              # with U+02DA RING ABOVE
  # # alias :℉ :fahrenheit               # U+2109 DEGREE FAHRENHEIT
  # # FIXME: Patch FahrenheitTemperature to make it work with SY::Temperature

  # === Dimensionless quantities

  Amount = Quantity.standard of: Dimension.zero
  UNIT = Unit.standard of: Amount

  MoleAmount = Quantity.dimensionless
  MOLE = Unit.standard of: MoleAmount, short: "mol", amount: UNIT * Nᴀ

  # degree, alias deg, ° # angle measure
  # arcminute, alias ʹ, ′ # angle measure
  # arcsecond, alias ʹʹ, ′′, ″

  # === Quantities of composite dimensions
  
  Area = Length ** 2
  Volume = Length ** 3
  LITRE = Unit.of Volume, short: "l", amount: 1.dm³

  Frequency = 1 / Time
  HERTZ = Unit.of Frequency, short: "Hz"

  Speed = ( Length / Time ).standard!

  Acceleration = ( Speed / Time ).standard!

  Force = ( Acceleration * Mass ).standard!
  NEWTON = Unit.standard of: Force, short: "N"

  Energy = ( Force * Length ).standard!
  JOULE = Unit.standard of: Energy, short: "J"
  # SY::CALORIE means thermochemical calorie.
  CALORIE = Unit.of Energy, short: "cal", amount: 4.184.J

  Power = ( Energy / Time ).standard!
  WATT = Unit.standard of: Power, short: "W"

  Pressure = ( Force / Area ).standard!
  PASCAL = Unit.standard of: Pressure, abbreviation: "Pa"

  ElectricCurrent = ( ElectricCharge / Time ).standard!
  AMPERE = Unit.standard of: ElectricCurrent, abbreviation: "A"

  ElectricPotential = ( Energy / ElectricCharge ).standard!
  VOLT = Unit.standard of: ElectricPotential, abbreviation: "V"

  Molarity = MoleAmount / Volume
  MOLAR = Unit.standard of: Molarity, abbreviation: "M", amount: 1.mol.l⁻¹

  Molality = MoleAmount / Mass
  MOLAL = Unit.of Molality
end
