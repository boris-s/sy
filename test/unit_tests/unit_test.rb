#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/unit.rb.
#
# File unit.rb defines class SY::Unit, representing a metrological unit. A
# unit in SY is basically a named magnitude (SY::Magnitude). Table of units
# is used to define unit methods on the user classes (mainly Numeric).
# Specification of its code features follows.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/module'
require 'y_support/flex_coerce'
require 'y_support/unicode'
# Require sy files needed by the tested component.
require_relative '../../lib/sy/magnitude'
require_relative '../../lib/sy/sps'
# Require the tested component itself.
require_relative '../../lib/sy/unit'

describe "sy/unit/sps.rb" do
  require_relative 'unit/sps_test.rb'
end

describe "sy/unit.rb" do
  it "must be a subclass of SY::Magnitude" do
    SY::Unit.ancestors.must_include SY::Magnitude
  end

  describe "constructors" do
    it "must have .standard constructor" do
      SY::Unit.methods.must_include :standard
    end
  end

  it "should define operators +, -, *, /, % and negation" do
    SY::Unit.instance_methods.must_include :+
    SY::Unit.instance_methods.must_include :-
    SY::Unit.instance_methods.must_include :*
    SY::Unit.instance_methods.must_include :/
    SY::Unit.instance_methods.must_include :-@
  end

  it "should define power operator **" do
    SY::Unit.instance_methods.must_include :**
  end

  it "should define #coerce method" do
    SY::Unit.instance_methods.must_include :coerce
  end
end
