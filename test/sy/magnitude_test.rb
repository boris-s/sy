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
require_relative '../../lib/sy/magnitude.rb'

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
