#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/se.rb.
#
# File se.rb defines class Se (superscripted exponent), which is used in
# construction of Sps (superscripted product string), such as "kg.m.s⁻²".
# Se is a subclass of String, which represents strings such as "⁰", "¹",
# "²", "⁴²", "⁻⁴²". Specification of its main features is below.
# **************************************************************************

require_relative 'test_loader'
module SY; end
require_relative '../../lib/sy/quantity.rb'

describe "quantity.rb" do
  # FIXME: These look more like acceptance tests.
  before do
    # @q1 = SY::Quantity.new of: '∅'
    # @q2 = SY::Quantity.dimensionless
    # @amount_in_dozens = begin
    #                       SY.Quantity( "AmountInDozens" )
    #                     rescue
    #                       SY::Quantity.dimensionless amount: 12, ɴ: "AmountInDozens"
    #                     end
    # @inch_length = begin
    #                  SY.Quantity( "InchLength" )
    #                rescue NameError
    #                  SY::Quantity.of SY::Length.dimension, ɴ: "InchLength"
    #                end
  end

  it "should behave as expected" do
    skip
    refute_equal @q1, @q2
    assert @q1.absolute? && @q2.absolute?
    assert @q1 == @q1.absolute
    assert_equal false, @q1.relative?
    assert_equal SY::Composition.new, @q1.composition
    @q1.set_composition SY::Composition[ SY::Amount => 1 ]
    assert_equal SY::Composition[ SY::Amount => 1 ], @q1.composition
    @amount_in_dozens.must_be_kind_of SY::Quantity
    d1 = @amount_in_dozens.magnitude 1
    a12 = SY::Amount.magnitude 12
    mda = @amount_in_dozens.measure of: SY::Amount
    r, w = mda.r, mda.w
    ra = r.( a12.amount )
    @amount_in_dozens.magnitude ra
    ra = @amount_in_dozens.read( a12 )
    assert_equal @amount_in_dozens.magnitude( 1 ),
                 @amount_in_dozens.read( SY::Amount.magnitude( 12 ) )
    assert_equal SY::Amount.magnitude( 12 ),
                 @amount_in_dozens.write( 1, SY::Amount )
    SY::Length.composition.must_equal SY::Composition.singular( :Length )
  end
end
