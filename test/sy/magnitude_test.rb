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
