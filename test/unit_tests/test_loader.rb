#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Test loader file. Loads everything necessary for testing,
# including Ruby test library. Does not run any tests on its own.
# *****************************************************************

require 'minitest/autorun'
require 'mathn'

# Make an empty module named SY for testing purposes.
# 
module SY
end
