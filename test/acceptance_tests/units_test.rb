#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Acceptance tests for SY::Unit
# *****************************************************************

require_relative 'test_loader'

describe SY::Units do
  before do
    @M = m = Module.new { ★ SY::Units }
    @C = Class.new { ★ m }
  end

  describe "inclusion behavior of SY::Units" do
    it "must extend user modules with its module methods" do
      @M.singleton_class.must_include SY::Units::ModuleMethods
    end

    it "must extend user classes with its class methods" do
      @C.singleton_class.must_include SY::Units::ClassMethods
    end
  end

  describe "module methods" do
    # FIXME: Tests not written!
  end

  describe "class methods" do
    # FIXME: Tests not written!
  end

  describe "instance methods" do
    # FIXME: Tests not written!
  end
end # describe SY::Units
