#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Test loader file. Loads everything necessary for testing, including Ruby
# test library, but does not run any tests on its own. To run the tests,
# open files:
#
# unit_tests.rb to run all unit tests.
# acceptance_tests.rb to run all acceptance tests.
# all_tests.rb to run all the tests.
# 
# **************************************************************************

# The following will load Ruby spec-style library
require 'mathn'
require 'minitest/autorun'
