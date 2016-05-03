#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Test loader file. Loads everything necessary for testing, including Ruby
# test library, but does not run any tests on its own.
# *****************************************************************

require_relative '../test_loader'
# Load dependencies.
require 'y_support/flex_coerce'
require 'y_support/literate'
require_relative '../../../lib/sy/magnitude'

# Mention class named SY::Unit for testing purposes.
# 
class SY::Unit < SY::Magnitude
end
