#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/se.rb.
#
# File se.rb defines class Se (superscripted exponent), which is
# used in construction of Sps (superscripted product string), such
# as "kg.m.s⁻²".  Se is a subclass of String, which represents
# strings such as "⁰", "¹", "²", "⁴²", "⁻⁴²". Specification of its
# main features follows below.
# *****************************************************************

require_relative 'test_loader'
# Require the tested component itself.
require_relative '../../lib/sy/se.rb'

describe "sy/se.rb - superscript exponent" do
  it "should have table of superscript characters" do
    SY::Se::TABLE['0'].must_equal '⁰'
    SY::Se::TABLE['1'].must_equal '¹'
    SY::Se::TABLE['7'].must_equal '⁷'
  end

  it "should have .new constructor" do
    SY::Se.new( '38' ).must_be_kind_of SY::Se
  end

  describe "constructor" do
    before do
      @s = SY::Se.new( '-9876543210' )
    end

    it "should accept variable input" do
      SY::Se.new( '0' ).must_equal '⁰'
      SY::Se.new( '1' ).must_equal '¹'
      SY::Se.new( '' ).must_equal '¹'
      SY::Se.new( '-1' ).must_equal '⁻¹'
      SY::Se.new( '25' ).must_equal '²⁵'
      SY::Se.new( 25 ).must_equal '²⁵'
      SY::Se.new( '²⁵' ).must_equal '²⁵'
      SY::Se.new( '-9876543210' ).must_equal '⁻⁹⁸⁷⁶⁵⁴³²¹⁰'
      SY::Se.new( -9876543210 ).must_equal '⁻⁹⁸⁷⁶⁵⁴³²¹⁰'
      SY::Se.new( '⁻⁹⁸⁷⁶⁵⁴³²¹⁰' ).must_equal '⁻⁹⁸⁷⁶⁵⁴³²¹⁰'
      # TODO: Handle rational numbers.
    end
  end

  it "should have #to_normal_numeral method" do
    SY::Se.instance_methods.must_include :to_normal_numeral
    SY::Se.new( -42 ).to_normal_numeral.must_equal '-42'
    SY::Se.new( '' ).to_normal_numeral.must_equal '1'
    SY::Se.new( '0' ).to_normal_numeral.must_equal '0'
    SY::Se.new( '1' ).to_normal_numeral.must_equal '1'
  end

  it "should have #to_int method" do
    SY::Se.instance_methods.must_include :to_int
    SY::Se.new( -42 ).to_int.must_equal -42
    SY::Se.new( '' ).to_int.must_equal 1
    SY::Se.new( '0' ).to_int.must_equal 0
    SY::Se.new( '1' ).to_int.must_equal 1
  end
end
