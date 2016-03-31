#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Acceptance tests for SY::Quantity.
# **************************************************************************

require_relative 'test_loader'

describe SY::Quantity do
  before do
    @T = SY::Dimension[ :TIME ]
    @L = SY::Dimension[ :LENGTH ]
  end

  describe "constructors" do
    it "should have .of constructor" do
      SY::Quantity.of( @T ).must_be_kind_of SY::Quantity
      SY::Quantity.of( @T ).dimension.must_equal @T
    end

    it "should have .dimensionless constructor" do
      SY::Quantity.dimensionless.must_be_kind_of SY::Quantity
      assert SY::Quantity.dimensionless.dimension.zero?
    end

    it "should also have standard .new constructor" do
      SY::Quantity.new( dimension: @T ).must_be_kind_of SY::Quantity
      SY::Quantity.new( of: @T ).must_be_kind_of SY::Quantity
      SY::Quantity.new( dimension: @T ).dimension.must_equal @T
      SY::Quantity.new( of: @T ).dimension.must_equal @T
    end
  end

  describe ".standard accessor of standard quantity for a given dimension" do
    it "should work" do
      SY::Quantity.standard( of: @T ).must_be_kind_of SY::Quantity
      SY::Quantity.standard( of: @T ).dimension.must_equal @T
      assert SY::Quantity.standard( of: @T ).equal? @T.standard_quantity
    end
  end

  describe "#to_s" do
    it "..." do
    end
  end

  describe "#inspect" do
    it "should return specific strings" do
      # FIXME: These tests were stolen from dimension_test.rb
      # @Z.inspect.must_equal "#<Dimension:∅>"
      # @L.inspect.must_equal "#<Dimension:L>"
      # ( @L - 2 * @T ).inspect.must_equal "#<Dimension:L.T⁻²>"
    end
  end
end

# FIXME: These acceptance tests are legacy from SY 2.0.
# 
describe SY::Quantity do
  it "should have .standard constructor ... " do # FIXME: How the hell is Quantity supposed to behave?
    # FIXME: Line
    # Amount = Quantity.standard of: Dimension.zero
    # doesn't work. Write the tests that require it to work
    # and make it work.
  end

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
