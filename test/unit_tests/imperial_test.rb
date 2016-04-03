#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file imperial.rb.
#
# File imperial.rb defines imperial units. Imperial units are not provided
# by plain <em>require 'sy'</em>, they must be specifically required by
# <em>require 'sy/imperial'</em>. Code features of imperial.rb are specified
# below.
# **************************************************************************

require_relative 'test_loader'
# Set flag to tell the file imperial.rb not to automatically require sy.rb.
SY::UNIT_TEST = true
# Set up the mocks of the key SY objects.
class SY::Unit
  class << self; def of *args; 1 end end
end
# Require the tested component itself.
require_relative '../../lib/sy/imperial'

# Run unit tests for sy.rb.
# 
describe "imperial.rb" do
  it "should attempt to define certain units of amount" do
    ( defined? SY::DOZEN ).must_equal "constant"
  end

  it "should attempt to define certain units of length" do
    ( defined? SY::INCH ).must_equal "constant"
    ( defined? SY::FOOT ).must_equal "constant"
    ( defined? SY::YARD ).must_equal "constant"
    ( defined? SY::FURLONG ).must_equal "constant"
    ( defined? SY::MILE ).must_equal "constant"
    ( defined? SY::FATHOM ).must_equal "constant"
    ( defined? SY::NAUTICAL_MILE ).must_equal "constant"
  end

  it "should attempt to define certain units of area" do
    ( defined? SY::ACRE ).must_equal "constant"
  end

  it "should attempt to define certain units of volume" do
    ( defined? SY::PINT ).must_equal "constant"
    ( defined? SY::QUART ).must_equal "constant"
    ( defined? SY::GALLON ).must_equal "constant"
  end

  it "should attempt to define certain units of mass" do
    ( defined? SY::POUND ).must_equal "constant"
    ( defined? SY::OUNCE ).must_equal "constant"
    ( defined? SY::STONE ).must_equal "constant"
    ( defined? SY::FIRKIN ).must_equal "constant"
    ( defined? SY::IMPERIAL_TON ).must_equal "constant"
  end

  it "should attempt to define certain units of time" do
    ( defined? SY::FORTNIGHT ).must_equal "constant"
  end

  it "should attempt to define certain units of speed" do
    ( defined? SY::MPH ).must_equal "constant"
  end
end
