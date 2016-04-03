#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/prefixes.rb.
#
# File prefixes.rb contains a table of standard prefixes SY::PREFIXES, an
# array of triples (hash-type) containing full prefix ("kilo", "mili",
# "mega"...), abbreviation (k, m, M...) and factor the prefix denotes (1e3,
# 1e-3, 1e6...). The tests for the table follow.
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

  it "should have hash-type triples with :full, :short, :factor keys" do
    SY::PREFIXES.each do |row|
      row.keys.must_include :full
      row.keys.must_include :short
      row.keys.must_include :factor
    end
  end
end
