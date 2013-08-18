# encoding: utf-8

require 'sy'

# Imperial units.
# 
module SY
  # === Length
  INCH = Unit.of Length, amount: 25.4.mm # short: 'in' would be ambiguous
  FOOT = Unit.of Length, short: 'ft', amount: 12.inch
  YARD = Unit.of Length, short: 'yd', amount: 3.ft
  # forget CHAIN and FURLONG
  MILE = Unit.of Length, short: 'mi', amount: 5_280.ft
  FATHOM = Unit.of Length, short: 'ftm', amount: 1.853184.m
  NAUTICAL_MILE = Unit.of Length, amount: 1000.fathom

  # === Area
  ACRE = Unit.of Area, amount: ( 1.0 / 640 ).mile²

  # === Volume
  PINT = Unit.of Volume, amount: 568.26125.cm³
  # FIXME: PINT = Unit.of Volume, amount: 568.26125.ml didn't work, it gave 1000 times more value
  # something is wrong with the conversion mechanics
  QUART = Unit.of Volume, amount: 2.pint
  GALLON = Unit.of Volume, short: 'gal', amount: 8.pint

  # === Mass
  POUND = Unit.of Mass, short: 'lb', amount: 453.59237.g
  OUNCE = Unit.of Mass, short: 'oz', amount: ( 1.0 / 16 ).lb
  STONE = Unit.of Mass, amount: 14.lb
  IMPERIAL_TON = Unit.of Mass, amount: 2240.lb
end
