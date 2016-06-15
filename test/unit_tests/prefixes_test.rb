#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Unit tests for file sy/prefixes.rb.
#
# File prefixes.rb contains a table of standard prefixes
# SY::PREFIXES, an array of hashes. Each hash is a triple ie.
# contains 3 entries:
# 
#   1. prefix ("kilo", "mili", "mega"...)
#   2. abbreviation (k, m, M...)
#   3. factor denoted by the prefix (1e3, 1e-3, 1e6...)
#   
# Code specification follows below.
# *****************************************************************

require_relative 'test_loader'
module SY; end
require_relative '../../lib/sy/prefixes.rb'

describe "sy/prefixes.rb" do
  it "should have a table of standard unit prefixes" do
    [ "exa", "peta", "tera", "giga",
      "mega", "kilo", "mili", "micro",
      "nano", "pico", "femto", "atto",
      "hecto", "deka", "deci", "centi", ""
    ].sort.must_equal SY::PREFIXES.map { |row| row[:full] }.sort
  end

  it "should consist of hashes with keys :full, :short, :factor" do
    SY::PREFIXES.each do |row|
      row.keys.must_include :full
      row.keys.must_include :short
      row.keys.must_include :factor
    end
  end
end
