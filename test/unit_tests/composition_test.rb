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
require_relative '../../lib/sy/composition.rb'

describe "sy/composition.rb" do
  it "should" do
    skip
    assert_equal SY::Amount, SY.Dimension( :∅ ).standard_quantity
    a = SY::Composition[ SY::Amount => 1 ]
    l = SY::Composition[ SY::Length => 1 ]
    assert SY::Composition.new.empty?
    assert a.singular?
    assert l.atomic?
    assert_equal SY::Composition[ SY::Amount => 1, SY::Length => 1 ], a + l
    assert_equal SY::Composition[ SY::Amount => 1, SY::Length => -1 ], a - l
    assert_equal SY::Composition[ SY::Length => 2 ], l * 2
    assert_equal l, l * 2 / 2
    assert_equal l.to_hash, (a + l).simplify.to_hash
    assert_equal SY::Amount, a.to_quantity
    assert_equal SY::Length, l.to_quantity
    assert_equal( SY.Dimension( 'L' ),
                  SY::Composition[ SY::Amount => 1, SY::Length => 1 ]
                    .to_quantity.dimension )
    assert_equal SY.Dimension( 'L' ), l.dimension
    assert_kind_of SY::Measure, a.infer_measure
  end
end
