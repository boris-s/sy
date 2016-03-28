#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy.rb.
#
# File sy.rb is the basic part of SY, a Ruby gem that allows convenient
# representation of physical units. The file sy.rb defines module SY, and
# within it, most of the well-known physical units and constants. File
# sy.rb is also responsible for loading all other components of SY. This
# set of unit tests tests code features of sy.rb.
# **************************************************************************

require_relative 'test_loader'
# Require other necessary libraries.
# require 'y_support/name_magic'
# Set up the mocks of the key SY objects.
ExpressibleInUnits = Module.new
module SY
  UNIT_TEST = true # Flag to tell sy.rb not to require all other files.
  DEBUG = false # Using mocks of the main objects; debug messages unhelpful. 
#   def self.const_missing ß
#     if ß.to_s == ß.to_s.upcase then 1 # Assumed to be a unit.
#     else ß.to_s end
#   end
  class Dimension
    def self.zero; end
  end
  class Unit
#     include NameMagic
#     def self.of *args; 1 end
    def self.standard *args; 1 end
  end
  class Quantity
#     include NameMagic
    def self.standard *args; new *args end
    def self.dimensionless *args; new *args end
    attr_reader :args
    def initialize *args; @args = args end
  end
end
# Require the tested component itself.
require_relative '../lib/sy'


describe "sy.rb" do
  it "should have AUTOINCLUDE code" do
    ( defined? SY::AUTOINCLUDE ).must_equal "constant"
    Numeric.ancestors.must_include ExpressibleInUnits
  end

  it "should attempt to define Amount" do
    ( defined? SY::Amount ).must_equal "constant"
  end

  it "should attempt to define UNIT" do
    ( defined? SY::UNIT ).must_equal "constant"
  end

  it "should attempt to define AVOGADRO_CONSTANT" do
    ( defined? SY::AVOGADRO_CONSTANT ).must_equal "constant"
  end

  it "should attempt to define MoleAmount" do
    ( defined? SY::MoleAmount ).must_equal "constant"
  end

  it "should attempt to define MOLE" do
    ( defined? SY::MOLE ).must_equal "constant"
  end
end
