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

  it "..." do
    flunk "Tests not written!"
  end
end
