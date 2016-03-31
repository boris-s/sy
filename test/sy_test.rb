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

# Set up the mocks of the key SY objects.
ExpressibleInUnits = Module.new
module SY
  UNIT_TEST = true # Flag to tell sy.rb not to require all other files.
  DEBUG = false # Using mocks of the main objects; debug messages unhelpful. 

  class Dimension < Hash; def self.zero; end end

  class Quantity # SY::Quantity class mock.
    def self.standard *args; new *args end
    def self.dimensionless *args; new *args end
    def self.of *args; new *args end
    attr_reader :args
    def initialize *args; @args = args end
    def method_missing *args; self end
    def coerce *args; [1, 1] end
  end

  class Magnitude
  end

  class Unit < Magnitude # SY::Unit class mock.
    def self.of *args; 1 end
    def self.standard *args; 1 end
  end
end

# Require the tested component itself.
require_relative '../lib/sy'

# Clean up the offensive mocks.
module SY
  remove_const :Magnitude
end

describe "sy.rb" do
  it "should have AUTOINCLUDE code" do
    skip
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
    ( defined? SY::Nᴀ ).must_equal "constant"
  end

  it "should attempt to define MoleAmount" do
    ( defined? SY::MoleAmount ).must_equal "constant"
  end

  it "should attempt to define MOLE" do
    ( defined? SY::MOLE ).must_equal "constant"
  end

  it "should attempt to define Length" do
    ( defined? SY::Length ).must_equal "constant"
  end

  it "should attempt to define METRE" do
    ( defined? SY::METRE ).must_equal "constant"
  end

  it "should attempt to define Mass" do
    ( defined? SY::METRE ).must_equal "constant"
  end

  it "should attempt to define certain units of mass" do
    ( defined? SY::KILOGRAM ).must_equal "constant"
    ( defined? SY::GRAM ).must_equal "constant"
    ( defined? SY::TON ).must_equal "constant"
    ( defined? SY::DALTON ).must_equal "constant"
  end

  it "should attempt to define quantity Time" do
    ( defined? SY::Time ).must_equal "constant"
  end

  it "should define certain units of time" do
    ( defined? SY::SECOND ).must_equal "constant"
    ( defined? SY::MINUTE ).must_equal "constant"
    ( defined? SY::HOUR ).must_equal "constant"
    ( defined? SY::DAY ).must_equal "constant"
    ( defined? SY::WEEK ).must_equal "constant"
    ( defined? SY::SYNODIC_MONTH ).must_equal "constant"
    ( defined? SY::YEAR ).must_equal "constant"
  end

  it "should attempt to define ElectricCharge quantity" do
    skip
    ( defined? SY::ElectricCharge ).must_equal "constant"
  end

  it "should attempt to define certain units of electric charge" do
    skip
    ( defined? SY::COULOMB ).must_equal "constant"
  end

  it "should attempt to define Temperature quantity" do
    skip
    ( defined? SY::Temperature ).must_equal "constant"
  end

  it "should attempt to define certain units of temperature" do
    skip
    ( defined? SY::KELVIN ).must_equal "constant"
  end

  it "should attempt to define TRIPLE_POINT_OF_WATER constant" do
    skip
    ( defined? SY::TRIPLE_POINT_OF_WATER ).must_equal "constant"
    ( defined? SY::TP_H₂O ).must_equal "constant"
  end

  it "should attempt to define Celsius temperature and related assets" do
    skip
    flunk "Celsius temperatures not done yet!"
  end

  it "should attempt to define certain dimensionless quantities" do
    skip
    flunk "Extended set of dimensionless quantities not handled yet!"
  end

  it "should attempt to define quantity Area" do
    skip
    ( defined? SY::Area ).must_equal "constant"
  end

  it "should attempt to define quantity Volume" do
    skip
    ( defined? SY::Volume ).must_equal "constant"
  end

  it "should attempt to define quantity LitreVolume" do
    skip
    ( defined? SY::LitreVolume ).must_equal "constant"
  end

  it "should attempt to define certain volume units" do
    skip
    ( defined? SY::LITRE ).must_equal "constant"
  end

  it "should attempt to define quantity Molarity" do
    skip
    ( defined? SY::Molarity ).must_equal "constant"
  end

  it "should attempt to define unit MOLAR" do
    skip
    ( defined? SY::MOLAR ).must_equal "constant"
  end

  it "should attempt to define quantity Density" do
    skip
    # Density is not such a simple thing to say. Although commonly, people
    # will expect volumetric density with dimension M.L⁻³, there are many
    # other possible kinds of densities. I should check the terminology of
    # this physical unit.
    ( defined? SY::Density ).must_equal "constant"
  end

  it "should attempt to define quantity Frequency" do
    skip
    ( defined? SY::Frequency ).must_equal "constant"
  end

  it "should attempt to define quantity Frequency" do
    skip
    ( defined? SY::HERTZ ).must_equal "constant"
  end
end
