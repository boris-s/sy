#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/quantity/sps.rb.
#
# File sps.rb defines class SY::Quantity::Sps, a superscripted
# product string representing quantity. Its specification follows.
# *****************************************************************

require_relative 'test_loader'
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/sps.rb'
puts SY::Quantity.instances.size
describe "sy/quantity/sps.rb - quantity term string" do
  it "permits all previously defined quantities" do
puts SY::Quantity.instances.size
    SY::Quantity::Sps.symbols.must_equal [ :Foo, :Bar, :FootLength ]
    SY::Quantity.dimensionless name: "Baz"
    SY::Quantity::Sps.symbols.must_equal [ :Foo, :Bar, :FootLength, :Baz ]
    SY::Quantity.forget :Baz
    SY::Quantity::Sps.symbols.must_equal [ :Foo, :Bar, :FootLength ]
  end

  it "does not permit prefixes" do
    SY::Quantity::Sps.prefixes.must_equal []
  end

  it "works" do
    SY::Quantity::Sps.new( "Foo.Bar⁻¹" ).to_hash
      .must_equal( { "Foo" => 1, "Bar" => -1 } )
    -> { SY::Quantity::Sps.new "Foo.Baz⁻¹" }.must_raise TypeError
  end
end
