#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/dimension/base.rb
#
# File base.rb defines basic physical dimensions of SY (length, mass, time,
# electric charge and temperature). Its specification follows.
# **************************************************************************

require_relative 'test_loader'
# Require the tested component itself.
require_relative '../../../lib/sy/dimension/base'

describe "sy/dimension/base.rb" do
  it "should define basic physical dimensions" do
    SY::Dimension::BASE.to_a.sort
      .must_equal [ [:L, :LENGTH],
                    [:M, :MASS],
                    [:T, :TIME],
                    [:Q, :ELECTRIC_CHARGE],
                    [:Θ, :TEMPERATURE] ].sort
  end

  it "should have #all_symbols method" do
    SY::Dimension::BASE.all_symbols
      .must_equal SY::Dimension::BASE.keys + SY::Dimension::BASE.values
  end

  it "should have #normalize_symbol method" do
    SY::Dimension::BASE.normalize_symbol( "TEMPERATURE" )
      .must_equal :TEMPERATURE
    SY::Dimension::BASE.normalize_symbol( :M )
      .must_equal :MASS
    -> { SY::Dimension::BASE.normalize_symbol "foo" }.must_raise TypeError
  end
end
