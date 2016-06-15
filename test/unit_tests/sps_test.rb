#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/sps.rb.
#
# File sps.rb defines class SY::Sps (superscripted product string),
# which represents strings such as "a².b⁻²", "foobar.baz²",
# "kg.m", "kg.m.s⁻²", "LENGTH.TIME⁻¹" etc. A mother class of
# SY::Dimension::Sps and SY::Unit::Sps.
# *****************************************************************

require_relative 'test_loader'
# Require the external libraries needed by the tested component.
require 'y_support/core_ext/class'
# Require the files needed by the tested component.
require_relative '../../lib/sy/se.rb'
# Require the tested component itself.
require_relative '../../lib/sy/sps.rb'

describe "sy/sps.rb - superscripted product string" do
  before do
    @a1 = { a: 1, b: -1 }
    @s1 = [:a, :b]
    @a2 = { Xa: 1, yb: -1, zc: 2, d: 1 }
    @s2 = ["a", "b", "c", "d", "e"]
    @p2 = ["X", "y", "z"]
  end

  it "should be a subclass of String" do
    SY::Sps.ancestors.must_include String
  end

  it "should have .parse class method" do
    SY::Sps.private_methods.must_include :parse
    m = SY::Sps.method :parse
    m.( "a.b⁻¹", symbols: [:a, :b] )
      .must_equal [["", "a", 1], ["", "b", -1]]
    m.( "Xa.yb⁻¹.zc².d",
        symbols: ["a", "b", "c", "d", "e"],
        prefixes: ["X", "y", "z"]
      ).must_equal [["X", "a", 1 ],
                    ["y", "b", -1],
                    ["z", "c", 2],
                    ["", "d", 1]]
    -> { m.( "foo" ) }.must_raise ArgumentError
    -> { m.( "foo", symbols: ["a"] ) }.must_raise TypeError
    -> { m.( "xa.yb⁻¹", symbols: ["a", "b"],
             prefixes: ["X", "y", "z"] ) }.must_raise TypeError
  end

  describe "constructors" do
    before do
      @sps1 = SY::Sps.new( "a.b⁻¹", symbols: [:a, :b] )
      @sps1 = SY::Sps.new( [[:a, 1], [:b, -1]], symbols: [:a, :b] )
      # @sps1 = SY::Sps.new( @a1, symbols: @s1 )
      @sps2 = SY::Sps.new( "Xa.yb⁻¹.zc².d",
                           symbols: ["a", "b", "c", "d", "e"],
                           prefixes: ["X", "y", "z"] )
      # @sps2 = SY::Sps.new( @a2, symbols: @s2, prefixes: @p2 )
    end

    describe ".new" do
      it "should accept variable input" do
        SY::Sps.new( { a: 1, b: -1 }, symbols: @s1 )
          .must_equal @sps1
        SY::Sps.new( [[:a, 1], [:b, -1]], symbols: @s1 )
          .must_equal @sps1
        SY::Sps.new( "a.b⁻¹", symbols: @s1 ).must_equal @sps1
        SY::Sps.new( "a¹.b⁻¹", symbols: @s1 ).must_equal @sps1
        SY::Sps.new( { Xa: 1, yb: -1, zc: 2, d: 1 },
                     symbols: @s2, prefixes: @p2 ).must_equal @sps2
        SY::Sps.new( [[:Xa, 1], [:yb, -1], [:zc, 2], [:d, 1]],
                     symbols: @s2, prefixes: @p2 ).must_equal @sps2
        SY::Sps.new( "Xa.yb⁻¹.zc².d",
                     symbols: @s2, prefixes: @p2 ).must_equal @sps2
        SY::Sps.new( "Xa¹.yb⁻¹.zc².d",
                     symbols: @s2, prefixes: @p2 ).must_equal @sps2
      end

      it "should reject zero exponents" do
        SY::Sps.new( { a: 0, b: 2 }, symbols: @s1 )
          .must_equal 'b²'
        -> { SY::Sps.new( "a⁰b²", symbols: @s1 ) }
          .must_raise TypeError
      end

      it "should reject same symbol occuring twice" do
        -> { SY::Sps.new [[:a, 1], [:a, 1]], symbols: @s1 }
          .must_raise TypeError
        -> { SY::Sps.new( { a: 1, xa: 1 },
                          symbols: @s1,
                          prefixes: [ :x ] ) }
          .must_raise TypeError
        -> { SY::Sps.new "a¹.b.a", symbols: @s1 }
          .must_raise TypeError
        -> { SY::Sps.new "km.m⁻²", symbols: [ :m ],
                         prefixes: [ :k ] }
          .must_raise TypeError
        -> { SY::Sps.new "ft².ft⁻²", symbols: [ :ft ] }
          .must_raise TypeError
      end
    end # describe ".new"
  end # describe "constructors"

  it "should have .customize private class method for " +
     "customizing instances" do
    SY::Sps.private_methods.must_include :customize
  end
  
  it "should have .normalize_symbol private class method" do
    SY::Sps.private_methods.must_include :normalize_symbol
  end

  describe "instance methods" do
    before do
      @sps1 = SY::Sps.new( @a1, symbols: @s1 )
      @sps2 = SY::Sps.new( @a2, symbols: @s2, prefixes: @p2 )
    end

    it "should have selectors #symbols and #prefixes" do
      @sps1.symbols.must_equal ["a", "b"]
      @sps1.prefixes.must_equal [""]
      @sps2.symbols.must_equal ["a", "b", "c", "d", "e"]
      @sps2.prefixes.must_equal ["X", "y", "z", ""]
    end

    it "should have #parse method" do
      @sps1.parse.must_equal [["", "a", 1], ["", "b", -1]]
      @sps2.parse.must_equal [["X", "a", 1], ["y", "b", -1],
                              ["z", "c", 2], ["", "d", 1]]
    end

    it "should have #to_hash method" do
      assert @sps1.to_hash ==
        { "a" => 1, "b" => -1 }
      assert @sps2.to_hash ==
        { "Xa" => 1, "yb" => -1, "zc" => 2, "d" => 1 }
    end

    it "should have #validate method" do
      @sps1.validate.must_equal @sps1
      @sps1.validate( symbols: @s2 ).must_equal @sps1
      -> { @sps2.validate symbols: @s1 }.must_raise TypeError
    end
  end
end
