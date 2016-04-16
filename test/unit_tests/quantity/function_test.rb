#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/quantity/function.rb.
#
# File function.rb defines class SY::Quantity::Function, a function
# with easily accessible inverse. The class serves for the purposes
# of mapping quantities into one another, especially mapping a
# quantity to its parent quantity or its standard quantity.
# *****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext'
require 'y_support/literate'
require 'active_support/core_ext/module/delegation'
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/function'

describe "sy/quantity/function" do
  before do
    @f = SY::Quantity::Function
  end

  describe "instance methods" do
    it "must have basic instance methods" do
      im = @f.instance_methods
      im.must_include :closure
      im.must_include :inverse_closure
      im.must_include :call
      im.must_include :[]
      im.must_include :inverse
      im.must_include :*
      im.must_include :/
      im.must_include :**
      im.must_include :ratio?
    end
  end

  describe "constructors" do
    it "must have .new constructor" do
      i = @f.new -> x { x * 2 }, inverse: -> x { x / 2 }
      i.must_be_kind_of @f
      i.closure.( 21 ).must_equal 42
      i.inverse_closure.( 42 ).must_equal 21
    end

    it "must have .identity constructor" do
      @f.identity.must_be_kind_of SY::Quantity::Ratio
      @f.identity.coefficient.must_equal 1
    end

    it "must have .multiplication constructor" do
      @f.ratio( 7 ).must_be_kind_of SY::Quantity::Ratio
      @f.ratio( 7 ).coefficient.must_equal 7
    end

    it "must have .addition constructor" do
      @f.addition( 7 ).must_be_kind_of @f
      @f.addition( 7 ).( 10 ).must_equal 17
      @f.addition( 7 ).inverse_closure.( 10 ).must_equal 3
    end
  end

  describe "#ratio?" do
    it "must return false for Quantity::Function instances" do
      i1 = @f.new -> m { m + 1 }, inverse: -> m { m - 1 }
      i2 = @f.new -> m { m * 2 }, inverse: -> m { m / 2 }
      i1.ratio?.must_equal false
      i2.ratio?.must_equal false
    end
  end

  describe "#invert" do
    before do
      @i = @f.new -> m { m * 2 }, inverse: -> m { m / 2 }
    end

    it "must swap @closure and @inverse_closure" do
      @i.inverse.closure.must_equal @i.inverse_closure
      @i.inverse.inverse_closure.must_equal @i.closure
    end
  end

  describe "#*" do
    it "must perform function composition" do
      i1 = @f.ratio( 2 )
      i2 = @f.ratio( 3 )
      c = i1 * i2
      c.must_be_kind_of @f
      c.( 7 ).must_equal 42
      c.inverse_closure.( 42 ).must_equal 7
    end
  end

  describe "#/" do
    it "is defined as multiplication with inverse" do
      i1 = @f.ratio( 2 )
      i2 = @f.ratio( 3 )
      c = i1 / i2
      c.( 3 ).must_equal 2
      c.inverse_closure.( 2 ).must_equal 3
    end
  end

  describe "#**" do
    before do
      @i = @f.addition( 1 )
    end

    it "performs raises the function to the argument" do
      ( @i ** 1 ).( 0 ).must_equal 1
      ( @i ** 1 ).inverse_closure.( 0 ).must_equal -1
      ( @i ** 5 ).( 0 ).must_equal 5
      ( @i ** 5 ).inverse_closure.( 0 ).must_equal -5
      ( @i ** 0 ).( 42 ).must_equal 42
      ( @i ** 0 ).inverse_closure.( 42 ).must_equal 42
      ( @i ** -1 ).( 0 ).must_equal -1
      ( @i ** -1 ).inverse_closure.( 0 ).must_equal 1
      ( @i ** -5 ).( 0 ).must_equal -5
      ( @i ** -5 ).inverse_closure.( 0 ).must_equal 5
    end

    it "takes only integer arguments" do
      -> { @i ** 2.5 }.must_raise TypeError
    end
  end
end
