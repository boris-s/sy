#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Test loader file. Loads everything necessary for testing,
# including Ruby test library. Does not run any tests on its own.
# *****************************************************************

require_relative '../test_loader'

# Require the external libraries needed by the tested component.
require 'y_support/unicode'
require 'y_support/name_magic'
require 'y_support/flex_coerce'
require 'y_support/core_ext/module'
require 'active_support/core_ext/module/delegation'

# Require quantity.rb and other files needed by its assets.
require_relative '../../../lib/sy/se.rb'
require_relative '../../../lib/sy/sps.rb'
require_relative '../../../lib/sy/dimension.rb'
require_relative '../../../lib/sy/quantity.rb'
require_relative '../../../lib/sy/magnitude.rb'

# Define testing quantities.
SY::Quantity.dimensionless name: :Foo
SY::Quantity.dimensionless name: :Bar
SY::Quantity.of dimension: :LENGTH, name: :FootLength
