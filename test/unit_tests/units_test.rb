#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/units.rb.
#
# Mixin SY::Units defined in sy/units.rb imbues its includers with
# the ability to respond to the unit methods. Examples:
#
#   1.metre / 1.second == 1.m.s⁻¹   #=> true
# 
# *****************************************************************

require_relative 'test_loader'
require_relative '../../lib/sy/units'

describe "includer class" do
  before do
    m = Module.new { include SY::Units }
    @C = Class.new { include m }
  end

  it "must respond to certain class methods" do
    @C.must_respond_to :warn_about_method_collisions
  end
end
