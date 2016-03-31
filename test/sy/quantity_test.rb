#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/se.rb.
#
# File se.rb defines class Se (superscripted exponent), which is used in
# construction of Sps (superscripted product string), such as "kg.m.s⁻²".
# Se is a subclass of String, which represents strings such as "⁰", "¹",
# "²", "⁴²", "⁻⁴²". Specification of its main features is below.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/module'
# Require the tested component itself.
require_relative '../../lib/sy/quantity.rb'

describe "quantity.rb" do
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

  # FIXME: Below are only sample tests from dimension_tests.rb

  it "should define operators +, -, *, / and negation" do
    skip
    SY::Dimension.instance_methods.must_include :+
    SY::Dimension.instance_methods.must_include :-
    SY::Dimension.instance_methods.must_include :*
    SY::Dimension.instance_methods.must_include :/
    SY::Dimension.instance_methods.must_include :-@
  end

  it "should carry its own definition of #to_s method" do
    skip
    SY::Dimension.instance_methods( false ).must_include :to_s
  end

  it "should carry its own definition of #inspect method" do
    skip
    SY::Dimension.instance_methods( false ).must_include :inspect
  end
end
