#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Acceptance tests for SY::Unit
# *****************************************************************

require_relative 'test_loader'

describe SY::Unit do
  describe "constructors" do
    before do
      @T = SY::Dimension[ :TIME ]
      @Time = SY::Quantity.of dimension: @T
    end

    describe ".basic" do
      it "constructs basic unit of a quantity" do
        u = SY::Unit.basic( of: @Time )
        u.must_be_kind_of SY::Unit
        u.number.must_equal 1.0
        u.quantity.must_equal @Time
        -> { SY::Unit.basic @Time }.must_raise ArgumentError
      end
    end
  end
end
