#encoding: utf-8

require 'y_support/name_magic'
require 'y_support/all'
require_relative 'sy/version'

require_relative 'sy/unit_methods_mixin'
require_relative 'sy/fixed_assets_of_the_module'
require_relative 'sy/dimension'
require_relative 'sy/quantity'
require_relative 'sy/magnitude'
require_relative 'sy/unit'

# Applying the unit method extension to Numeric.
# 
class Numeric
  include ::SY::UnitMethodsMixin
end

# These requires will be necessary as soon as y_support is made according
# to the structure of active_support.
# 
# require 'y_support/core_ext/object/blank'
# require 'y_support/core_ext/module/delegation'
# require 'y_support/core_ext/hash/reverse_merge'
# require 'y_support/core_ext/array/extract_options'

module SY

  Nᴀ = AVOGADRO_CONSTANT = 6.02214e23


  # === Standard quantities of basic dimensions

  Length = Quantity.standard of: Dimension( :L )

  Mass = Quantity.standard of: Dimension( :M )

  Time = Quantity.standard of: Dimension( :T )

  ElectricCharge = Quantity.standard of: Dimension( :Q )

  Temperature = Quantity.standard of: Dimension( :Θ )


  # === Their units

  GRAM = Unit.of Mass, short: "g"

  KILOGRAM = Unit.standard of: Mass, amount: 1000.g

  METRE = Unit.standard of: Length, abbreviation: "m"

  SECOND = Unit.standard of: Time, abbreviation: "s"

  COULOMB = Unit.standard of: ElectricCharge, abbreviation: "C"

  KELVIN = Unit.standard of: Temperature, abbreviation: "K"

  DALTON = Unit.of Mass, abbreviation: "Da", amount: 1.66053892173e-27.kg

  MINUTE = Unit.of Time, abbreviation: "min", amount: 60.s

  HOUR = Unit.of Time, abbreviation: "h", amount: 60.min

  
  # === Other quantities
  
  Speed = ( Length / Time ).standard

  Acceleration = ( Speed / Time ).standard

  Force = ( Acceleration * Mass ).standard

  Energy = ( Force * Length ).standard

  Power = ( Energy / Time ).standard

  Area = ( Length ** 2 ).standard

  Volume = ( Length ** 3 ).standard

  Pressure = ( Force / Area ).standard

  Amount = Quantity.standard of: Dimension.zero

  MoleAmount = Quantity.dimensionless

  # Molarity is not a standard quantity. Let the standard quantity remain
  # unnamed with dimension L⁻³, and molarity a standalone named quantity.
  # 
  Molarity = Amount / Volume

  ElectricCurrent = ( ElectricCharge / Time ).standard

  ElectricPotential = ( Energy / ElectricCharge ).standard

  # Again, let us the standard quantity of T⁻¹ dimension be unnamed, and
  # Frequency with Hz as its standard unit, be a standalone named quantity.
  # 
  Frequency = 1 / Time

  CelsiusTemperature = Quantity.of Temperature.dimension
  # TODO: Now we would do singleton modifications to this quantity, so that
  # arithmetic would work as it should.

  # === Their units
  
  NEWTON = Unit.standard of: Force, abbreviation: "N"

  JOULE = Unit.standard of: Energy, abbreviation: "J"

  # Using thermochemical calorie.
  # 
  CALORIE = Unit.of Energy, abbreviation: "cal", amount: 4.184.J

  WATT = Unit.standard of: Power, abbreviation: "W"

  LITRE = Unit.of( Volume, { abbreviation: "l", amount: 1.dm³ } )

  PASCAL = Unit.standard of: Pressure, abbreviation: "Pa"

  # Instead of using mole, I find it more natural to count in "units",
  # (as in 1.unit.s⁻¹).
  # 
  UNIT = Unit.standard of: Amount

  # Mole in this library is defined as AVOGADRO_CONSTANT units.
  # 
  MOLE = Unit.standard of: MoleAmount, short: "mol", amount: UNIT * Nᴀ

  # 1.M, unit of molarity.
  # 
  MOLAR = Unit.standard of: Molarity, abbreviation: "M", amount: 1.mol.l⁻¹

  AMPERE = Unit.standard of: ElectricCurrent, abbreviation: "A"

  VOLT = Unit.standard of: ElectricPotential, abbreviation: "V"

  CELSIUS = Unit.standard of: CelsiusTemperature, short: "°C"

  HERTZ = Unit.of Frequency, short: "Hz"
end

# Feature proposals for later development:
# 
# alias :Celsius :celsius
# alias :degree_celsius :celsius
# alias :degree_Celsius :celsius
# alias :°C :celsius                 # with U+00B0 DEGREE SIGN
# alias :˚C :celsius                 # with U+02DA RING ABOVE
# alias :℃ :celsius                  # U+2103 DEGREE CELSIUS
# 
# alias :Fahrenheit :fahrenheit
# alias :degree_fahrenheit :fahrenheit
# alias :degree_Fahrenheit :fahrenheit
# alias :°F :fahrenheit              # with U+00B0 DEGREE SIGN
# alias :˚F :fahrenheit              # with U+02DA RING ABOVE
# alias :℉ :fahrenheit               # U+2109 DEGREE FAHRENHEIT
# 
# degree, alias deg, ° # angle measure
# arcminute, alias ʹ, ′ # angle measure
# arcsecond, alias ʹʹ, ′′, ″
