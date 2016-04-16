#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/magnitude.rb.
#
# File se.rb defines class SY::Magnitude, representing a magnitude of a metrological quantity. A magnitude is basically a pair [ quantity, number ], which behaves as a number with respect to relevand mathematical operations, while retaining its affiliation to the quantity. Specification of the main code features follows.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/module'
require 'y_support/flex_coerce'
require 'y_support/unicode'
# Require sy files needed by the tested component.
# Require the tested component itself.
require_relative '../../lib/sy/magnitude'

describe "sy/magnitude.rb" do
  it "must define Magnitude::Error" do
    assert SY::Magnitude::Error < TypeError
  end

  it "must have .of constructor" do
    SY::Magnitude.methods.must_include :of
  end

  it "must have #quantity and #number selectors" do
    SY::Magnitude.instance_methods.must_include :quantity
    SY::Magnitude.instance_methods.must_include :number
  end

  it "should define operators +, -, *, /, % and negation" do
    SY::Magnitude.instance_methods.must_include :+
    SY::Magnitude.instance_methods.must_include :-
    SY::Magnitude.instance_methods.must_include :*
    SY::Magnitude.instance_methods.must_include :/
    SY::Magnitude.instance_methods.must_include :-@
  end

  it "should define power operator **" do
    SY::Magnitude.instance_methods.must_include :**
  end

  it "should define #coerce method" do
    SY::Magnitude.instance_methods.must_include :coerce
  end

  it "should carry its own definition of #to_s method" do
    SY::Magnitude.instance_methods( false ).must_include :to_s
  end

  it "should carry its own definition of #inspect method" do
    SY::Magnitude.instance_methods( false ).must_include :inspect
  end
end
