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
require_relative 'sy_loader'

# Run unit tests for sy.rb.
# 
describe "sy.rb" do
  it "should have certain code features" do
    ( defined? SY::AUTOINCLUDE ).must_equal "constant"
    Numeric.ancestors.must_include ExpressibleInUnits
  end
end
