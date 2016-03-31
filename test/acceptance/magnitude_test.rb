#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Acceptance tests for SY::Magnitude.
# **************************************************************************

require_relative 'test_loader'

describe SY::Magnitude do
  before do
    @T, @L = SY::Dimension[ :T ], SY::Dimension[ :L ]
    @Time = SY::Quantity.standard of: @T
    @Length = SY::Quantity.standard of: @L
  end

  describe ".new constructor" do
    it "must return expected magnitudes" do
      SY::Magnitude.new( @Time, 42 ).must_be_kind_of SY::Magnitude
      SY::Magnitude.new( quantity: @Time, number: 42 )
        .must_be_kind_of SY::Magnitude
      SY::Magnitude.new( @Time, 42 ).quantity.must_equal @Time
      SY::Magnitude.new( @Time, 42 ).number.must_equal 42
    end
  end

  describe ".[] constructor" do
    it "must return expected magnitudes" do
      SY::Magnitude[ @Time, 42 ].must_be_kind_of SY::Magnitude
      SY::Magnitude[ @Time, 42 ].quantity.must_equal @Time
      SY::Magnitude[ @Time, 42 ].number.must_equal 42
    end
  end

  describe ".of constructor" do
    it "must return expected magnitudes" do
      SY::Magnitude.of( @Length, number: 3 ).must_be_kind_of SY::Magnitude
    end
  end

  describe "Number-like behavior (ie. arithmetics)" do
    before do
      @t0 = SY::Magnitude.of @Time, number: 0
      @t1 = SY::Magnitude.of @Time, number: 1
      @l0 = SY::Magnitude.of @Length, number: 0
      @l2 = SY::Magnitude.of @Length, number: 2
    end

    describe "negation" do
      # FIXME
    end

    describe "addition" do
      # FIXME
    end

    describe "subtraction" do
      # FIXME
    end

    describe "multiplication" do
      it "must allow multiplication by numbers" do
        ( @t1 * 3 ).must_be_kind_of SY::Magnitude
        ( @t1 * 3 ).quantity.must_equal @Time
        ( @t1 * 3 ).number.must_equal 3
      end

      it "must allow multiplication by other magnitudes" do
        ( @t1 * @l2 ).must_be_kind_of SY::Magnitude
        ( @t1 * @l2 ).quantity.must_equal @t1.quantity * @l2.quantity
        ( @t1 * @l2 ).number.must_equal 2
      end
    end

    describe "division" do
      # FIXME
    end

    describe "raising to a power" do
      # FIXME
    end

    describe "coercion behavior" do
      it "should multiply numbers" do
        ( 2 * @l2 ).must_be_kind_of SY::Magnitude
        ( 2 * @l0 ).must_equal @l0
        ( 3 * @t1 ).must_equal @t1 * 3
      end
    end
  end
end

# FIXME: These all look more like acceptance tests than unit tests.
describe "sy/magnitude.rb" do
  before do
    # @m1 = 1.metre
    # @inch = SY::Unit.standard( of: @inch_length, amount: 2.54.cm,
    #                            ɴ: 'inch', short: '”' )
    # @i1 = @inch_length.magnitude 1
    # @il_measure = @inch_length.measure( of: SY::Length )
  end

  it "should work" do
    # @m1.quantity.must_equal SY::Length.relative
    # @inch_length.colleague.name.must_equal :InchLength±
    # @m1.to_s.must_equal "1.m"
    # @i1.amount.must_equal 1
    # assert_kind_of SY::Measure, @il_measure
    # assert_kind_of Numeric, @il_measure.ratio
    # assert_in_epsilon 0.0254, @il_measure.ratio
    # @il_measure.w.( 1 ).must_be_within_epsilon 0.0254
    # begin
    #   impossible_mapping = @inch_length.measure( of: SY::Amount )
    # rescue SY::DimensionError
    #   :dimension_error
    # end.must_equal :dimension_error
    # # reframing
    # 1.inch.reframe( @inch_length ).amount.must_equal 1
    # 1.inch.( @inch_length ).must_equal 1.inch
    # 1.inch.( SY::Length ).must_equal 2.54.cm
    # @inch_length.magnitude( 1 ).to_s.must_equal "1.”"
    # 1.inch.in( :mm ).must_be_within_epsilon 25.4
    # assert_equal SY::Unit.instance( :SECOND ), SY::Unit.instance( :second )
  end
end

describe "sy/magnitude.rb" do
  it "OLD TESTS -- should have working #<=> method" do
    # # First of all, these tests don't look like unit tests at all.
    # # They look more like acceptance tests.
    # assert_equal 0, 1.m <=> 100.cm
    # assert_equal 1, 1.m <=> 99.cm
    # assert_equal -1, 1.m <=> 101.cm
    # assert_equal SY::Length.composition * 3, 1.m³.quantity.composition
    # a, b = 10.hl, 1.m³
    # assert_equal SY::Volume.relative, b.quantity
    # assert_equal SY::LitreVolume.relative, a.quantity
    # assert_equal [SY::LitreVolume], SY::Volume.coerces
    # assert b.quantity.absolute.coerces?( a.quantity.absolute )
    # assert b.quantity.coerces?( a.quantity )
    # assert_equal 0, 1.l <=> 1.l
    # assert_equal -1, 1.m³ <=> 11.hl
    # assert_equal 1, 1.m³ <=> 9.hl
    # assert_equal 1.dm³, 1.dm³
  end
end
