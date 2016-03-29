#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/unit.rb.
#
# File unit.rb defines class SY::Unit, representing a metrological unit.
# Specification of its code features follows.
# **************************************************************************

require_relative 'test_loader'

# FIXME: These all look more like acceptance tests than unit tests.

describe "sy/unit.rb" do
  it "should work" do
    assert_equal SY::Unit.instance( :SECOND ), SY::Unit.instance( :second )
  end
end
