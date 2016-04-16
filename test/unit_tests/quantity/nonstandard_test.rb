#! /usr/bin/ruby
#encoding: UTF-8

# *****************************************************************
# Unit tests for sy/quantity/nonstandard.rb
# 
# File quantity/nonstandard.rb defines class
# SY::Quantity::Nonstandard, which represents a nonstandard
# quantity type.
# *****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/module'
require 'y_support/name_magic'
require 'y_support/unicode'
require 'active_support/core_ext/module/delegation'
# Require the tested component itself.
require_relative '../../../lib/sy/quantity'
require_relative '../../../lib/sy/quantity/nonstandard'

describe SY::Quantity::Nonstandard do
  before do
    @q1 = SY::Quantity.standard of: :TEMPERATURE,
      name: :Temperature
    @q2 = SY::Quantity.nonstandard of: @q1,
      function: -> m { m + 273.15 }, inverse: -> m { m - 273.15 },
      name: :CelsiusTemperature
  end

  describe "#inverse" do
    it "should raise TypeError" do
      -> { @q2.inverse }.must_raise TypeError
    end

    it "should give expected error message" do
      begin; @q2.inverse; rescue TypeError => msg
      msg.must_equal "Attempt to invert a nonstandard quantity " +
        "CelsiusTemperature has occurred, but nonstandard " +
        "quantities may not be inverted!"
      end
    end
  end
end
