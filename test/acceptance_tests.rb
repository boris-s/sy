#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Acceptance tests for SY, a Ruby library of physical units. This is the main
# set of the acceptance tests. In the file noinclude_tests.rb, there is
# another set of acceptance tests for the case when require 'sy/noinclude' is
# used.
# **************************************************************************

require_relative 'acceptance_tests/dimension_test'
require_relative 'acceptance_tests/quantity_test'
require_relative 'acceptance_tests/magnitude_test'
require_relative 'acceptance_tests/unit_test'
require_relative 'acceptance_tests/sy_test'
