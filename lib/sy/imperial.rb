# coding: utf-8

require_relative '../sy'

# Imperial units.
# 
module SY
  # === Length
  INCH = Unit.of Length, amount: 25.4 * 0.001 * METRE
  # short: 'in' would be ambiguous
  FOOT = Unit.of Length, short: 'ft', amount: 12 * INCH
  YARD = Unit.of Length, short: 'yd', amount: 3 * FOOT
  # forget CHAIN
  FURLONG = Unit.of Length, short: 'fur', amount: 220 * YARD
  MILE = Unit.of Length, short: 'mi', amount: 5_280 * FOOT
  FATHOM = Unit.of Length, short: 'ftm', amount: 1.853184 * METRE
  NAUTICAL_MILE = Unit.of Length, amount: 1000 * FATHOM

  # === Area
  ACRE = Unit.of Area, amount: ( 1.0 / 640 ) * MILE ** 2

  # === Volume
  PINT = Unit.of Volume, amount: 568.26125 * ( 0.01 * METRE ) ** 3
  # FIXME: PINT = Unit.of Volume, amount: 568.26125.ml didn't work, it gave 1000 times more value
  # something is wrong with the conversion mechanics
  QUART = Unit.of Volume, amount: 2 * PINT
  GALLON = Unit.of Volume, short: 'gal', amount: 8 * PINT

  # === Mass
  POUND = Unit.of Mass, short: 'lb', amount: 453.59237 * GRAM
  OUNCE = Unit.of Mass, short: 'oz', amount: ( 1.0 / 16 ) * POUND
  STONE = Unit.of Mass, amount: 14 * POUND
  FIRKIN = Unit.of Mass, short: 'fir', amount: 90 * POUND
  IMPERIAL_TON = Unit.of Mass, amount: 2240 * POUND

  # === Time
  FORTNIGHT = Unit.of Time, short: 'ftn', amount: 1_209_600 * SECOND
end
