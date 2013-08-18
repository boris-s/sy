#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# THIS IS SPEC-STYLE TEST FILE FOR SY PHYSICAL UNITS LIBRARY
# **************************************************************************

# The following will load Ruby spec-style library
require 'mathn'
require 'minitest/autorun'


# **************************************************************************
# THE SPECIFICATIONS START HERE
# **************************************************************************

describe "case of require 'sy/noinclude'" do
  before do
    # The following will load SY library
    # require 'sy'
    require './../lib/sy/noinclude'
  end

  it "should show at least some signs of life" do
    SY::Length.magnitude( 1 ).must_equal SY::METRE
    SY::Length.magnitude( 2 ).must_equal SY::METRE * 2
    SY::Volume.magnitude( 1 ).must_equal SY::METRE ** 3
    # without caring for exhaustive test coverage...
  end
end

describe "require 'sy/noinclude'; require 'sy/imperial'" do
  before do
    # The following will load SY library
    # require 'sy'
    require './../lib/sy/noinclude'
    require './../lib/sy/imperial'
  end

  it "should show signs of life" do
    SY::YARD.must_equal SY::FOOT * 3
    SY::POUND.must_equal 16 * SY::OUNCE
  end
end
