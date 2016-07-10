#! /usr/bin/ruby
# encoding: utf-8

# ****************************************************************
# Unit tests for file sy/quantity/term.rb
#
# File quantity/term.rb defines class SY::Quantity::Term, which
# represents a product of a certain number of quantities raised to
# certain exponents.
# ****************************************************************

require_relative 'test_loader'
# Require the dependency.
require_relative '../../../lib/sy'
# Require the tested component itself.
require_relative '../../../lib/sy/quantity/term'


describe "sy/quantity/term" do
  before do
    @Term = SY::Quantity::Term
    @Foo = SY::Quantity.instance :Foo
    @Bar = SY::Quantity.instance :Bar
    @FootLength = SY::Quantity.instance :FootLength
  end

  describe ".instances class method" do
    it "is a selector of @instances class-owned variable" do
      @Term.instances.must_be_kind_of Array
      assert @Term.instances.all? { |i|
        i.kind_of? SY::Quantity::Term
      }
    end
  end

  describe ".[] constructor" do
    it "works as expected with hash { quantity => exp }" do
      t = SY::Quantity::Term[ @Foo => 1, @Bar => -1 ]
      t.must_be_kind_of SY::Quantity::Term
    end

    it "when given a term, returns the same term" do
      t = SY::Quantity::Term[ @Foo => 1, @Bar => -1 ]
      SY::Quantity::Term[ t ].must_equal t
    end

    it "when given a quantity, returns its base term" do
      t = SY::Quantity::Term[ "Foo.Bar⁻¹" ]
      t.must_equal( { @Foo => 1, @Bar => -1 } )
    end
  end

  describe "#invert" do
    it "negates the term exponents" do
      SY::Quantity::Term.empty.invert.must_equal( {} )
      SY::Quantity::Term[ @Foo => 1 ].invert
        .must_equal SY::Quantity::Term[ @Foo => -1 ]
      SY::Quantity::Term[ @Foo => -1, @Bar => 1 ].invert
        .must_equal SY::Quantity::Term[ @Foo => 1, @Bar => -1 ]
    end
  end
end # describe "sy/quantity/term"
