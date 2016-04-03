#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Test loader file. Loads everything necessary for testing, including Ruby
# test library, but does not run any tests on its own.
# **************************************************************************

require 'minitest/autorun'

# Make an empty module named SY for testing purposes.
# 
module SY
  def self.const_missing sym
    if sym.to_s == sym.to_s.upcase then # Assume it is a unit name.
      1
    else # Assume it is a magnitude name
      sym.to_s
    end
  end
end
