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


  # === Basic quantities

  Length = Quantity.standard of: :L

  Mass = Quantity.standard of: :M

  Time = Quantity.standard of: :T

  ElectricCharge = Quantity.standard of: :Q

  Temperature = Quantity.standard of: :Θ


  # === Basic units of basic quantities

  METRE = Unit.standard of: Length, short: "m"

  SECOND = Unit.standard of: Time, short: "s"

  COULOMB = Unit.standard of: ElectricCharge, short: "C"

  KELVIN = Unit.standard of: Temperature, short: "K"


  # === Gram and kilogram

  GRAM = Unit.of Mass, short: "g", amount: 0.001

  KILOGRAM = Unit.standard of: Mass, amount: 1000.g


  # # === Derived units of basic quantities

  DALTON = Unit.of Mass, short: "Da", amount: 1.66053892173e-27.kg

  MINUTE = Unit.of Time, short: "min", amount: 60.s

  HOUR = Unit.of Time, short: "h", amount: 60.min

  
  # === Derived quantities
  
  Speed = Length / Time

  Acceleration = Speed / Time

  Force = Acceleration * Mass

  Energy = Force * Length

  Power = Energy / Time

  Area = Length ** 2

  Volume = Length ** 3

  Pressure = Force / Area

  Amount = Quantity.standard of: Dimension.zero

  Molarity = Amount / Volume

  ElectricCurrent = ElectricCharge / Time

  ElectricPotential = Energy / ElectricCharge

  Frequency = 1 / Time


  # === Their units
  
  NEWTON = Unit.standard of: Force, short: "N"

  JOULE = Unit.standard of: Energy, short: "J"

  # Using thermochemical calorie.
  # 
  CALORIE = Unit.of Energy, short: "cal", amount: 4.184.J

  WATT = Unit.standard of: Power, short: "W"

  LITRE = Unit.of( Volume, { short: "l", amount: 1.dm³ } )

  PASCAL = Unit.standard of: Pressure, short: "Pa"

  # Instead of using mole, I find it more natural to count in "units",
  # (as in 1.unit.s⁻¹).
  # 
  UNIT = Unit.standard of: Amount

  # Mole in this library is defined as AVOGADRO_CONSTANT units.
  # 
  MOLE = Unit.of Amount, short: "mol", amount: AVOGADRO_CONSTANT

  # 1.M, unit of molarity.
  # 
  MOLAR = Unit.standard of: Molarity, short: "M", amount: 1.mol.l⁻¹

  AMPERE = Unit.standard of: ElectricCurrent, short: "A"

  VOLT = Unit.standard of: ElectricPotential, short: "V"

  # CELSIUS = Unit.of Quantity.of( Temperature.dimension ), short: "°C"

  # Now we would do singleton modifications to CELSIUS.quantity, so that arithmetic
  # and coerce method work to make the whole behave as expected.

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
