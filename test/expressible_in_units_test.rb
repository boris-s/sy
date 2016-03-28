#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy.rb.
#
# File sy.rb is the basic part of SY, a Ruby gem that allows convenient
# representation of physical units. The file sy.rb defines module SY, and
# within it, most of the well-known physical units and constants. File
# sy.rb is also responsible for loading all other components of SY. This
# set of unit tests tests integrity and basic functionality of sy.rb.
# **************************************************************************

require_relative 'test_loader'
require_relative '../lib/expressible_in_units'

describe "expressible_in_units.rb" do
  it "should have certain code features" do
    ExpressibleInUnits::RecursionError.ancestors.must_include StandardError
  end

  # TODO: Fill in the remaining tests.
end
