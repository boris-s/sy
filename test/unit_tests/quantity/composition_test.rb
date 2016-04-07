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
    @c = SY::Quantity::Composition
  end

  describe "instance methods" do
    it "must have basic instance methods" do
      flunk "Quantity::Composition unit tests not written!"
    end
  end


  describe "sy/quantity/composition/table" do
    before do
      @t = SY::Quantity::Composition::Table
    end

    it "..." do
      flunk "Tests for composition table not written!"
    end
  end
end
