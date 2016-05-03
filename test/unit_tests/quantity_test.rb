#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/quantity.rb.
#
# File quantity.rb defines class SY::Quantity, the core class of
# SY. That's because a physical magnitude is a pair [ quantity,
# number ]. Magnitudes can be added / subtracted from one another
# only when they are of the same quantity. A quantity may have a
# physical dimension, but there are also dimensionless quantities.
# Quantity is important because it defines the physical meaning
# of its magnitudes. For example, Entropy and ThermalCapacity have
# the same dimension, but different physical meaning. Code
# specifications for quantity.rb follow.
# *****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/unicode'
require 'y_support/name_magic'
require 'y_support/core_ext/module'
require 'active_support/core_ext/module/delegation'
# Require the tested component itself.
require_relative '../../lib/sy/quantity.rb'

# Test the subordinate assets
require_relative 'quantity/function_test'
require_relative 'quantity/ratio_test'
require_relative 'quantity/term_test'
require_relative 'quantity/table_test'

# FIXME: See to it that the tests of all subordinate assets
# of quantity are invoked by the above statements.

describe "quantity.rb" do
  it "should define Quantity::Error" do
    assert SY::Quantity::Error < TypeError
  end

  it "should use NameMagic with permanent naming" do
    assert SY::Quantity.include? NameMagic
    assert SY::Quantity.permanent_names?
  end

  describe "class methods" do
    it "should have .of constructor" do
      SY::Quantity.methods.must_include :of
    end

    it "should have .dimensionless constructor" do
      SY::Quantity.methods.must_include :dimensionless
    end

    it "should have .standard accessor" do
      SY::Quantity.methods.must_include :standard
    end
  end

  it "should have #dimension selector" do
    SY::Quantity.instance_methods.must_include :dimension
  end

  it "should have #function selector" do
    SY::Quantity.instance_methods.must_include :function
  end

  # FIXME: Below are only sample tests from dimension_tests.rb

  it "should define operators +, -, *, / and negation" do
    SY::Quantity.instance_methods.must_include :+
    SY::Quantity.instance_methods.must_include :-
    SY::Quantity.instance_methods.must_include :*
    SY::Quantity.instance_methods.must_include :/
    SY::Quantity.instance_methods.must_include :-@
  end

  it "should define #inverse method" do
    SY::Quantity.instance_methods.must_include :inverse
  end

  it "should carry its own definition of #to_s method" do
    SY::Quantity.instance_methods( false ).must_include :to_s
  end

  it "should carry its own definition of #inspect method" do
    SY::Quantity.instance_methods( false ).must_include :inspect
  end
end
