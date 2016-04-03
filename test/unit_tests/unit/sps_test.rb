#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/dimension/sps.rb.
#
# File sps.rb defines class SY::Dimension::Sps, a superscripted product
# string representing dimension, such as "LENGTH.TIME⁻¹", "L.T⁻²",
# "L.TEMPERATURE⁻¹" etc. Its specification follows.
# **************************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/class'
require 'active_support/core_ext/module/delegation'
# Require the SY files needed by the tested component.
require_relative '../../../lib/sy/se.rb'
require_relative '../../../lib/sy/sps.rb'
require_relative '../../../lib/sy/dimension/base.rb'
# Require the tested component itself.
require_relative '../../../lib/sy/dimension/sps.rb'

describe "sy/unit/sps.rb - superscripted product string" do
  it "works" do
    skip
    flunk "Tests not written!"
  end
end
