#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/unit.rb.
#
# File unit.rb defines class SY::Unit, representing a metrological
# unit. A unit is basically a named instance of SY::Magnitude.
# *****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/module'
require 'y_support/flex_coerce'
require 'y_support/name_magic'
# Require sy files needed by the tested component.
require_relative '../../lib/sy/magnitude'
require_relative '../../lib/sy/sps'
# Require the tested component itself.
require_relative '../../lib/sy/unit'

describe "sy/unit/sps.rb" do
  # FIXME: Uncomment this test
  # require_relative 'unit/sps_test.rb'
end

describe "sy/unit.rb" do
  it "must be a subclass of SY::Magnitude" do
    SY::Unit.ancestors.must_include SY::Magnitude
  end

  it "must include NameMagic" do
    SY::Unit.must_include NameMagic
  end

  it "must have a list of PROTECTED_NAMES" do
    SY::Unit::PROTECTED_NAMES.must_include "kilogram"
  end

  describe "class methods" do
    it "must have certain constructors" do
      SY::Unit.must_respond_to :basic
      SY::Unit.must_respond_to :of
      SY::Unit.must_respond_to :new
    end

    it "must respond to certain other class methods" do
      SY::Unit.must_respond_to :warn_about_method_collisions
    end
  end

  describe "instance methods" do
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
end # describe "sy/unit.rb"
