#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/se.rb.
#
# File se.rb defines class Se (superscripted exponent), which is used in
# construction of Sps (superscripted product string), such as "kg.m.s⁻²".
# Se is a subclass of String, which represents strings such as "⁰", "¹",
# "²", "⁴²", "⁻⁴²". Specification of its main features is below.
# **************************************************************************

require_relative 'test_loader'
module SY; end
require_relative '../../lib/sy/prefixes.rb'

describe "sy/prefixes.rb" do
  it "should have a table of standard unit prefixes" do
    SY::PREFIXES.map { |row| row[:full] }.sort
      .must_equal [ "exa", "peta", "tera", "giga", "mega", "kilo",
                    "mili", "micro", "nano", "pico", "femto", "atto",
                    "hecto", "deka","deci", "centi", "" ].sort
  end
end
