#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Acceptance tests for SY::Unit
# *****************************************************************

require_relative 'test_loader'

describe SY::Unit do
  before do
    skip
    @T = SY::Dimension[ :TIME ]
    @Time = SY::Quantity.of dimension: @T
  end

  describe "constructors" do
    describe ".basic" do
      it "constructs basic unit of a quantity" do
        u = SY::Unit.basic( of: @Time )
        u.must_be_kind_of SY::Unit
        u.number.must_equal 1.0
        u.quantity.must_equal @Time
        -> { SY::Unit.basic @Time }.must_raise ArgumentError
      end
    end
  end # describe "constructors"

  describe "instance methods" do
    before do
      @SECOND = SY::Unit.basic( of: @Time,
                                name: :second,
                                abbreviation: :s )
      @MINUTE = SY::Unit.of( @Time,
                             number: 60,
                             name: :minute,
                             short: :min )
    end

    describe "#abbreviation alias #short selector" do
      it "selects @abbreviation property" do
        @SECOND.short.must_equal "s"
        @MINUTE.abbreviation.must_equal "min"
      end
    end
  end
end # describe SY::Unit
