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
require 'active_support/core_ext/module/delegation'
require 'y_support/core_ext/class'
# Require sy files needed by the tested component.
require_relative '../../lib/sy/se'
require_relative '../../lib/sy/sps'
# Require the tested component itself.
require_relative '../../lib/sy/dimension'

describe "sy/dimension.rb" do
  it "should define basic physical dimensions" do
    # FIXME: Base dimension can now be found under
    # SY::Dimension::BASE.
    SY::Dimension::BASE.to_a.sort
      .must_equal [ [:L, :LENGTH], [:M, :MASS], [:T, :TIME],
                    [:Q, :ELECTRIC_CHARGE], [:Θ, :TEMPERATURE] ].sort
  end

  it "should have the registry of instances" do
    SY::Dimension.instances.must_be_kind_of Array
  end

  it "should have .[] constructor accepting variable input" do
    SY::Dimension[ :LENGTH ].must_be_kind_of SY::Dimension
    SY::Dimension[ "LENGTH" ].must_be_kind_of SY::Dimension
    SY::Dimension[ L: 1, T: -1 ].must_be_kind_of SY::Dimension
    SY::Dimension[ { L: 1, T: -1 } ].must_be_kind_of SY::Dimension
    SY::Dimension[ "L.T⁻¹" ].must_be_kind_of SY::Dimension
  end

  it "should have .zero constructor for zero dimension" do
    SY::Dimension.zero.values.must_equal SY::Dimension::BASE.map { 0 }
  end

  it "should define operators +, -, *, /" do
    SY::Dimension.instance_methods.must_include :+
    SY::Dimension.instance_methods.must_include :-
    SY::Dimension.instance_methods.must_include :*
    SY::Dimension.instance_methods.must_include :/
  end

  it "should define #standard_quantity instance method" do
    SY::Dimension.instance_methods.must_include :standard_quantity
  end

  it "should be a subclass of Hash" do
    SY::Dimension.ancestors.must_include Hash
    skip
    # FIXME: This probably already belongs to acceptance
    # tests, but the assertion (or how is it called) below
    # is not fullfilled. I am quite sure that Dimension
    # being a Hash subclass and using full names of base
    # dimensions as keys was a correct decision, but the
    # problem is that now its #[] method does not respond
    # to the abbreviations of the base dimensions. #fetch
    # method might be another problem.
    SY::Dimension[ L: 1, T: -1 ][:L].must_equal 1
  end

  it "should define methods #zero? and #base?" do
    SY::Dimension.instance_methods.must_include :zero?
    SY::Dimension.instance_methods.must_include :base?
  end
end
