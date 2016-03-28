#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/dimension/sps.rb.
#
# File sps.rb defines class SY::Dimension::Sps...
# **************************************************************************

require_relative 'test_loader'
require_relative '../../../lib/sy/se.rb'
require_relative '../../../lib/sy/sps.rb'
require_relative '../../../lib/sy/dimension/base.rb'
require_relative '../../../lib/sy/dimension/sps.rb'

describe "sy/sps.rb - superscripted product string" do
  it "takes as admissible all possible symbols of base dimensions" do
    SY::Dimension::Sps.symbols
      .must_equal SY::Dimension::BASE.all_symbols.map( &:to_s )
  end

  it "does not allow prefixes" do
    SY::Dimension::Sps.prefixes.must_equal []
  end

  it "works" do
    SY::Dimension::Sps.new( "L.TEMPERATURE⁻¹" ).to_hash
      .must_equal( { "L" => 1, "TEMPERATURE" => -1 } )
    SY::Dimension::Sps.new( "MASS.LENGTH⁻²" ).to_hash
      .must_equal( { "MASS" => 1, "LENGTH" => -2 } )
    -> { SY::Dimension::Sps.new "FOO.BAR⁻¹" }.must_raise TypeError
  end

  it "does not allow double occurence of the same dimension" do
    -> { SY::Dimension::Sps.new "L.LENGTH⁻²" }.must_raise TypeError
  end
end
