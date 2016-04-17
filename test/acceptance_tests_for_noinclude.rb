#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Another set of acceptance tests for the case when SY is loaded by
# require 'sy/noinclude'.
#
# Loading SY by require 'sy/noinclude' prevents automatic inclusion
# of the unit methods in the relevant built-in classes, such as
# Numeric. This is preferred by the users who believe that
# "require" statement should avoid including any gem modules in the
# built-in classes (unless the user invokes "include" statement).
#
# Since noinclude option alters the behavior of SY in such way that
# it cannot be restored to normal by require 'sy', acceptance tests
# for noinclude option have to be run separately.
# *****************************************************************

require 'minitest/autorun'
# require 'mathn'
require_relative '../lib/sy/noinclude'
require_relative '../lib/sy/imperial'

describe "case of require 'sy/noinclude'" do
  it "should show at least some signs of life" do
    skip
    # SY::Length.magnitude( 1 ).must_equal SY::METRE
    # SY::Length.magnitude( 2 ).must_equal SY::METRE * 2
    # SY::Volume.magnitude( 1 ).must_equal SY::METRE ** 3
    # # without caring for exhaustive test coverage...
  end
end

describe "..." do
  it "should show signs of life" do
    skip
    # SY::YARD.must_equal SY::FOOT * 3
    # SY::POUND.must_equal 16 * SY::OUNCE
  end
end
