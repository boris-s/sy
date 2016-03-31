#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/magnitude.rb.
#
# File se.rb defines class SY::Magnitude, representing a magnitude of a metrological quantity. A magnitude is basically a pair [ quantity, number ], which behaves as a number with respect to relevand mathematical operations, while retaining its affiliation to the quantity. Specification of the main code features follows.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/module'
# Require sy files needed by the tested component.
# Require the tested component itself.
require_relative '../../lib/sy/magnitude'

describe "sy/magnitude.rb" do
  it "must have #quantity and #number selectors" do
    SY::Magnitude.instance_methods.must_include :quantity
    SY::Magnitude.instance_methods.must_include :number
  end
end

# FIXME: These all look more like acceptance tests than unit tests.

describe "sy/magnitude.rb" do
  before do
    # @m1 = 1.metre
    # @inch = SY::Unit.standard( of: @inch_length, amount: 2.54.cm,
    #                            ɴ: 'inch', short: '”' )
    # @i1 = @inch_length.magnitude 1
    # @il_measure = @inch_length.measure( of: SY::Length )
  end

  it "should work" do
    skip
    @m1.quantity.must_equal SY::Length.relative
    @inch_length.colleague.name.must_equal :InchLength±
    @m1.to_s.must_equal "1.m"
    @i1.amount.must_equal 1
    assert_kind_of SY::Measure, @il_measure
    assert_kind_of Numeric, @il_measure.ratio
    assert_in_epsilon 0.0254, @il_measure.ratio
    @il_measure.w.( 1 ).must_be_within_epsilon 0.0254
    begin
      impossible_mapping = @inch_length.measure( of: SY::Amount )
    rescue SY::DimensionError
      :dimension_error
    end.must_equal :dimension_error
    # reframing
    1.inch.reframe( @inch_length ).amount.must_equal 1
    1.inch.( @inch_length ).must_equal 1.inch
    1.inch.( SY::Length ).must_equal 2.54.cm
    @inch_length.magnitude( 1 ).to_s.must_equal "1.”"
    1.inch.in( :mm ).must_be_within_epsilon 25.4
    assert_equal SY::Unit.instance( :SECOND ), SY::Unit.instance( :second )
  end
end

describe "sy/magnitude.rb" do
  it "OLD TESTS -- should have working #<=> method" do
    skip
    # First of all, these tests don't look like unit tests at all.
    # They look more like acceptance tests.
    assert_equal 0, 1.m <=> 100.cm
    assert_equal 1, 1.m <=> 99.cm
    assert_equal -1, 1.m <=> 101.cm
    assert_equal SY::Length.composition * 3, 1.m³.quantity.composition
    a, b = 10.hl, 1.m³
    assert_equal SY::Volume.relative, b.quantity
    assert_equal SY::LitreVolume.relative, a.quantity
    assert_equal [SY::LitreVolume], SY::Volume.coerces
    assert b.quantity.absolute.coerces?( a.quantity.absolute )
    assert b.quantity.coerces?( a.quantity )
    assert_equal 0, 1.l <=> 1.l
    assert_equal -1, 1.m³ <=> 11.hl
    assert_equal 1, 1.m³ <=> 9.hl
    assert_equal 1.dm³, 1.dm³
  end
end
