#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/quantity/ratio.rb.
#
# File function.rb defines class SY::Quantity::Ratio, which is a subclass of
# SY::Quantity::Function. Ratios are frequently used in defining scaled up /
# down quantities.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/class'
require 'y_support/typing'
require 'active_support/core_ext/module/delegation'
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/function.rb'
require_relative '../../../lib/sy/quantity/ratio.rb'

describe "sy/quantity/ratio" do
  before do
    @f = SY::Quantity::Ratio
  end

  it "should define a subclass of Quantity::Function with certain features" do
    assert @f < SY::Quantity::Function
    @f.new( 7 ).( 6 ).must_equal 42
    @f.new( 7 ).inverse_closure.( 42 ).must_equal 6
    @f.new( 7 ).coefficient.must_equal 7
    ( @f.new( 7 ) * @f.new( 6 ) ).coefficient.must_equal 42
    ( @f.new( 7 ) ** 2 ).coefficient.must_equal 49
    ( @f.new( 7 ) / @f.new( 2 ) ).coefficient.must_equal 3.5
    @f.new( 7 ).ratio?.must_equal true
  end
end
