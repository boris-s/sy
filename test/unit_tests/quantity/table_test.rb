#! /usr/bin/ruby
# encoding: utf-8

# ****************************************************************
# Unit tests for file sy/quantity/term.rb
#
# File quantity/term.rb defines class SY::Quantity::Term, which
# represents a product of a certain number of quantities raised to
# certain exponents.
# ****************************************************************

require_relative 'test_loader'
# Require the dependencies.
require 'y_support/name_magic'
require 'y_support/literate'
require_relative '../../../lib/sy/quantity'
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/table'

describe "SY::Quantity.table" do
  it "should have .table alias .multiplication_table selector" do
    SY::Quantity.table
      .must_be_kind_of SY::Quantity::Composition::Table
    SY::Quantity.multiplication_table.must_equal SY::Quantity.table
  end

  it "should have tests written" do
    # FIXME: I think the table is not even programmed yet.
    flunk "Tests not written!"
  end
end # describe "sy/quantity/term"
