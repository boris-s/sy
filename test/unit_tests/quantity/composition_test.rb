#! /usr/bin/ruby
# encoding: utf-8

# ****************************************************************
# Unit tests for file sy/quantity/composition.rb.
#
# File quantity/term.rb defines class SY::Quantity::Composition...
# ****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/composition.rb'

describe "sy/quantity/composition" do
  before do
    @C = SY::Quantity::Composition
  end

  describe SY::Quantity::Composition::Table do
    before do
      @T = @C::Table
    end

    it "is a subclass of Hash" do
      assert @T < Hash
    end

    it "should have tests written" do
      flunk "Tests for composition table not written!"
    end
  end

  describe "instance methods" do
    it "should have tests written" do
      flunk "Tests of instance methods not written!"
    end
  end

end
