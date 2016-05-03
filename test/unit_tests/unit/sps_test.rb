#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/dimension/sps.rb.
#
# File sps.rb defines class SY::Unit::Sps, a superscripted product
# string representing a unit term, such as "metre.second⁻¹",
# "m.K⁻¹" etc. Its specification follows.
# *****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/class'
require 'y_support/name_magic'
require 'y_support/flex_coerce'
require 'active_support/core_ext/string/starts_ends_with'
# Require the SY files needed by the tested component.
require_relative '../../../lib/sy/se'
require_relative '../../../lib/sy/sps'
require_relative '../../../lib/sy/prefixes'
require_relative '../../../lib/sy/dimension'
require_relative '../../../lib/sy/quantity'
require_relative '../../../lib/sy/unit'
# Require the tested component itself.
require_relative '../../../lib/sy/unit/sps.rb'

describe "sy/unit/sps.rb - unit term string" do
  before do
    @Time = SY::Quantity.standard( of: :T )
    @Length = SY::Quantity.standard( of: :L )
    @s = SY::Unit.basic of: @Time, name: "second", short: "s"
    @m = SY::Unit.basic of: @Length, name: "metre", short: "m"
  end

  it "admits all existing unit symbols" do
    SY::Unit::Sps.symbols
    flunk "Tests not written!"
  end
end # describe
