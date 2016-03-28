#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# TODO: Not sure if this test is still valid.
# **************************************************************************

require_relative 'test_loader'
module SY; end
require_relative '../../lib/sy/measure.rb'

describe "sy/measure.rb" do
  it "old tests" do
    skip
    i = SY::Measure.identity
    a, b = SY::Measure.new( ratio: 2 ), SY::Measure.new( ratio: 3 )
    assert_equal 1, i.ratio
    assert_equal 4, a.r.( 8 )
    assert_equal 3, b.w.( 1 )
    assert_equal 6, (a * b).w.( 1 )
    assert_equal 2, (a * b / b).w.( 1 )
    assert_equal 4, (a ** 2).w.( 1 )
    assert_equal 2, a.inverse.r.( 1 )
  end
end
