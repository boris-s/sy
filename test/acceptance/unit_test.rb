#! /usr/bin/ruby
# encoding: utf-8

# ****************************************************************************
# Acceptance tests for SY::Unit
# ****************************************************************************

require_relative 'test_loader'

describe SY::Unit do
  describe "constructors" do
    before do
      @T = SY::Dimension[ :TIME ]
      @Time = SY::Quantity.of @T
    end

    it "should have .basic constructor" do
      SY::Unit.standard( of: @Time ).must_be_kind_of SY::Unit
      SY::Unit.standard( of: @Time ).quantity.must_equal @Time
      -> { SY::Unit.standard @Time }.must_raise ArgumentError
    end
  end
end
