#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Test loader file. Loads everything necessary for testing, which includes
# Ruby test library, entire SY gem and imperial units, but does not run any
# tests on its own.
# **************************************************************************

require 'minitest/autorun'
# require 'mathn'
require_relative '../../lib/sy'
require_relative '../../lib/sy/imperial'
