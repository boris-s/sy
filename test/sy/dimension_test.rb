#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/dimension.rb.
#
# File dimension.rb defines class SY::Dimension, representing physical
# dimensions, such as LENGTH.TIME⁻¹, or MASS.LENGTH⁻³. Each metrological
# quantity has its dimension. For example, dimension LENGTH.TIME⁻¹ is best
# known from quantity "SY::Speed", and dimension "MASS.LENGTH⁻³" from
# quantity "SY::Density". But a single dimension can have more than one
# quantity. For example, entropy and thermal capacity have both same
# dimension, but they are distinct physical quantities.
# TODO: Check if I chose this example right.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/array'
require 'y_support/core_ext/hash'
require 'y_support/typing'
require 'y_support/flex_coerce'
require 'active_support/core_ext/module/delegation'
require 'y_support/core_ext/class'
# Require sy files needed by the tested component.
require_relative '../../lib/sy/se'
require_relative '../../lib/sy/sps'
# Require the tested component itself.
require_relative '../../lib/sy/dimension'

describe "sy/dimension.rb" do
  it "should define basic physical dimensions" do
    SY::Dimension::BASE.to_a.sort
      .must_equal [ [:L, :LENGTH], [:M, :MASS], [:T, :TIME],
                    [:Q, :ELECTRIC_CHARGE], [:Θ, :TEMPERATURE] ].sort
  end

  it "should have the registry of instances" do
    SY::Dimension.instances.must_be_kind_of Array
  end

  it "should have .[] and .zero constructors" do
    SY::Dimension.methods.must_include :[]
    SY::Dimension.methods.must_include :zero
  end

  it "should define operators +, -, *, / and negation" do
    SY::Dimension.instance_methods.must_include :+
    SY::Dimension.instance_methods.must_include :-
    SY::Dimension.instance_methods.must_include :*
    SY::Dimension.instance_methods.must_include :/
    SY::Dimension.instance_methods.must_include :-@
  end

  it "should define #standard_quantity instance method" do
    SY::Dimension.instance_methods.must_include :standard_quantity
  end

  it "should be a subclass of Hash" do
    SY::Dimension.ancestors.must_include Hash
  end

  it "should define methods #zero? and #base?" do
    SY::Dimension.instance_methods.must_include :zero?
    SY::Dimension.instance_methods.must_include :base?
  end

  it "should define #to_sps method" do
    SY::Dimension.instance_methods.must_include :to_sps
  end

  it "should carry its own definition of #to_s method" do
    SY::Dimension.instance_methods( false ).must_include :to_s
  end

  it "should carry its own definition of #inspect method" do
    SY::Dimension.instance_methods( false ).must_include :inspect
  end

  it "should define #coerce method" do
    SY::Dimension.instance_methods.must_include :coerce
  end

  it "should define #standard_composition method" do
    SY::Dimension.instance_methods.must_include :standard_composition
  end
end
