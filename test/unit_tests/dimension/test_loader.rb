#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Test loader file. Loads everything necessary for testing, including Ruby
# test library, but does not run any tests on its own.
# **************************************************************************

require_relative '../test_loader'

# Make an empty class named SY::Dimension for testing purposes.
# 
class SY::Dimension < Hash
end
