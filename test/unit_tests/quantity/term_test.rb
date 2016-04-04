#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/quantity/term.rb.
#
# File quantity/term.rb defines class SY::Quantity::Term, which represents
# a product of a certain number of quantities raised to certain exponents.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/term.rb'

describe "sy/quantity/term" do
  before do
    @t = SY::Quantity::Term
  end

  describe "instance methods" do
    it "must have basic instance methods" do
      skip
      flunk "Quantity::Term unit tests not written!"
    end
  end
end
