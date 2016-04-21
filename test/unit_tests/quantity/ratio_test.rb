#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/quantity/ratio.rb.
#
# File ratio.rb defines class SY::Quantity::Ratio, which is a
# subclass of SY::Quantity::Function. Ratios are primarily used in
# defining scaled quantities.
# *****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/class'
require 'y_support/literate'
require 'active_support/core_ext/module/delegation'
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/function.rb'
require_relative '../../../lib/sy/quantity/ratio.rb'

describe "sy/quantity/ratio" do
  before do
    @F = SY::Quantity::Ratio
  end

  it "defines a specific subclass of Quantity::Function" do
    assert @F < SY::Quantity::Function
    @F.new( 7 ).ratio?.must_equal true
    @F.new( 7 ).( 6 ).must_equal 42
    @F.new( 7 ).inverse_closure.( 42 ).must_equal 6
    @F.new( 7 ).coefficient.must_equal 7
    ( @F.new( 7 ) * @F.new( 6 ) ).coefficient.must_equal 42
    ( @F.new( 7 ) ** 2 ).coefficient.must_equal 49
  end
end
