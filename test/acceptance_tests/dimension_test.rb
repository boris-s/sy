#! /usr/bin/ruby
# encoding: utf-8

# *****************************************************************
# Acceptance tests for SY::Dimension.
# *****************************************************************

require_relative 'test_loader'

describe SY::Dimension do
  it "should have .[] constructor accepting variable input" do
    SY::Dimension[ :LENGTH ].must_be_kind_of SY::Dimension
    SY::Dimension[ "LENGTH" ].must_be_kind_of SY::Dimension
    SY::Dimension[ L: 1, T: -1 ].must_be_kind_of SY::Dimension
    SY::Dimension[ { L: 1, T: -1 } ].must_be_kind_of SY::Dimension
    SY::Dimension[ "LENGTH.TIME⁻¹" ].must_be_kind_of SY::Dimension
    SY::Dimension[ "LENGTH.T⁻¹" ].must_be_kind_of SY::Dimension
    SY::Dimension[ "L.TIME⁻¹" ].must_be_kind_of SY::Dimension
    SY::Dimension[ "L.T⁻¹" ].must_be_kind_of SY::Dimension
  end

  it "should have .zero constructor for zero dimension" do
    SY::Dimension.zero.must_be_kind_of SY::Dimension
  end

  it "should reject .new constructor" do
    -> { SY::Dimension.new( :L ) }.must_raise NoMethodError
  end

  describe "features" do
    before do
      # Set up the lists of admissible base dimension symbols.
      @full_ßs = :LENGTH,
                   :TIME,
                   :MASS,
                   :TEMPERATURE,
                   :ELECTRIC_CHARGE
      @full_ςs = @full_ßs.map &:to_s
      @short_ßs = :L,
                  :T,
                  :M,
                  :Θ,
                  :Q
      @short_ςs = @short_ßs.map &:to_s
      # Set up some sample dimensions.
      @L = SY::Dimension[ :LENGTH ]
      @T = SY::Dimension[ :TIME ]
      @M = SY::Dimension[ :MASS ]
      @Z = SY::Dimension.zero
    end

    describe "hash-like behavior" do
      describe "#[]" do
        it "returns exponents when given base dimension symbols" do
          @L[ :LENGTH ].must_equal 1
          @L[ "TIME" ].must_equal 0
          @L[ :M ].must_equal 0
          @L[ "Θ" ].must_equal 0
          @full_ßs.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
          @full_ßs.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
          @full_ßs.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
          @full_ßs.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
          @short_ßs.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
          @short_ßs.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
          @short_ßs.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
          @short_ßs.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
          @full_ςs.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
          @full_ςs.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
          @full_ςs.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
          @full_ςs.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
          @short_ςs.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
          @short_ςs.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
          @short_ςs.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
          @short_ςs.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
          -> { @L[ :FOOBAR ] }.must_raise TypeError
        end
      end

      describe "#values_at" do
        it "should accept variable notation" do
          @L.values_at( *@full_ßs ).must_equal [ 1, 0, 0, 0, 0 ]
          @L.values_at( :L, :T ).must_equal [ 1, 0 ]
          @L.values_at( "LENGTH", "T", :TEMPERATURE, :M )
            .must_equal [ 1, 0, 0, 0 ]
        end
      end

      describe "#==" do
        it "should work as expected" do
          ( @Z == @Z ).must_equal true
          ( @L == SY::Dimension[ :LENGTH ] ).must_equal true
          ( @L == SY::Dimension[ :MASS ] ).must_equal false
          ( @L == { FOO: 1, BAR: 0 } ).must_equal false
          ( @L == [ :FOO, :BAR ] ).must_equal false
          ( [ :FOO, :BAR ] == @L ).must_equal false
        end
      end

      describe "#merge" do
        it "should only accept Dimension-type arguments" do
          @L.merge( @Z ).must_equal @Z
          -> { @L.merge FOO: 1 }.must_raise TypeError
        end

        it "should return same instance for the same dimension" do
          assert @L.merge( @Z ).equal? @Z
          assert @Z.merge( @T ).equal? @T
          assert ( @T.merge @T do |_, a, b| 0 end ).equal? @Z
        end
      end
    end

    describe "#merge! and #[]=" do
      it "should be disabled" do
        -> { @Z[ :LENGTH ] = 1 }.must_raise NoMethodError
        -> { @Z.merge!( LENGTH: 1 ) }.must_raise NoMethodError
      end
    end

    describe "dimension arithmetics" do
      describe "negation" do
        it "should negate the exponents" do
          ( -@L ).must_equal SY::Dimension[ L: -1 ]
          ( -@Z ).must_equal @Z
        end

        it "should return same object for the same dimension" do
          assert ( -SY::Dimension[ "L.T⁻¹" ] )
                  .equal? SY::Dimension[ "T.L⁻¹" ]
        end
      end

      describe "addition" do
        it "should add the exponents of the operands" do
          ( @Z + @L ).must_equal @L
          ( @L + @Z ).must_equal @L
          ( @Z + @Z ).must_equal @Z
          ( SY::Dimension[ "L.T⁻¹" ] + @T ).must_equal @L
          ( @L + @L ).must_equal SY::Dimension[ L: 2 ]
          ( @M + @T ).must_equal SY::Dimension[ M: 1, T: 1 ]
        end

        it "should return same object for the same dimension" do
          assert SY::Dimension[ "M.Q.L³.T⁻¹" ]
                  .equal? SY::Dimension[ "L.M.T⁻¹" ] +
                          SY::Dimension[ "Q.L²" ]
        end
      end

      describe "subtraction" do
        it "should subtract the exponents of the operands" do
          ( @L - @Z ).must_equal @L
          ( @T - @T ).must_equal @Z
          ( @Z - @L ).must_equal SY::Dimension[ L: -1 ]
          ( @Z - @Z ).must_equal @Z
          ( @L - @T ).must_equal SY::Dimension[ "L.T⁻¹" ]
          ( SY::Dimension[ L: 2 ] - @L ).must_equal @L
          ( SY::Dimension[ M: 1, T: 1 ] - @M ).must_equal @T
        end

        it "should return same object for the same dimension" do
          assert ( SY::Dimension[ "M.Q.L³.T⁻¹" ] -
                   SY::Dimension[ "Q.L²" ] )
                  .equal? SY::Dimension[ "L.M.T⁻¹" ]
        end
      end

      describe "type coercion" do
        it "should return object with certain qualities" do
          o1, o2 = @L.coerce 42
          assert o2.equal? @L
          o1.methods.must_include :operand
          o1.operand.must_equal 42
          ( o1 * o2 ).must_equal SY::Dimension[ L: 42 ]
          -> { o1 + o2 }.must_raise TypeError
          -> { o1 - o2 }.must_raise TypeError
          -> { o1 / o2 }.must_raise TypeError
          -> { o1 ** o2 }.must_raise TypeError
          -> { o1.foobar o2 }.must_raise TypeError
        end

        it "should be defined for integers and #* method" do
          assert ( 2 * @Z ).equal? @Z
          assert ( 3 * @L ).equal? @L * 3
          -> { 1 / @L }.must_raise TypeError
          -> { 1 + @L }.must_raise TypeError
        end
      end

      describe "multiplication by an integer" do
        it "should multiply the exponents by an integer" do
          ( @L * 0 ).must_equal @Z
          ( @L * 1 ).must_equal @L
          ( @L * 3 ).must_equal SY::Dimension[ "L³" ]
        end

        it "should return same object for the same dimension" do
          assert SY::Dimension[ "L².T⁻²" ]
                  .equal? SY::Dimension[ "L.T⁻¹" ] * 2
        end
        
        it "should reject non-integer operands" do
          -> { @L * 2.5 }.must_raise TypeError
        end
        
        it "should also allow the first operand to be integer" do
          ( 0 * @T ).must_equal @Z
          ( 1 * @T ).must_equal @T
          ( -2 * SY::Dimension[ "L.T⁻¹" ] )
            .must_equal SY::Dimension[ "T².L⁻²" ]
        end
      end
      
      describe "division by an integer" do
        it "should divide the exponents when all are divisible" do
          ( @Z / 2 ).must_equal @Z
          ( @L / 1 ).must_equal @L
          ( SY::Dimension[ "L³" ] / 3 ).must_equal @L
        end

        it "should return same object for the same dimension" do
          ( SY::Dimension[ "L⁴.M⁴" ] / 2 ).object_id
            .must_equal SY::Dimension[ "L².M²" ].object_id
        end

        it "should reject non-integer divisor" do
          begin
            @L / 1.0
          rescue TypeError => error
            error.message.must_equal <<-MSG.heredoc
              Divisor expected to be kind of Integer, but its class
              Float does not comply! Examined object: 1.0.
            MSG
          else flunk "TypeError expected!" end
        end
        
        it "should reject the divisor if any of the exponents " +
           "is not divisible by it, with a good error message" do
          begin
            SY::Dimension[ L: 3 ] / 2
          rescue TypeError => error
            error.message.must_equal <<-MSG.heredoc
              When trying to divide dimension L³ by 2, error has
              occurred: Exponent 3 is not divisible by 2! Note:
              When dividing a Dimension instance by an integer,
              all its exponents must be divisible by it. Dimension 
              L³ has exponents [ 3 ].
            MSG
          else flunk "TypeError expected!" end
        end
      end
    end

    it "should return same instance for the same dimension" do
      assert @Z.equal? SY::Dimension.zero
      assert @Z.equal? SY::Dimension[ {} ]
      assert @L.equal? SY::Dimension[ :LENGTH ]
      assert @L.equal? SY::Dimension[ "LENGTH" ]
      assert @L.equal? SY::Dimension[ "L" ]
      assert @L.equal? SY::Dimension[ LENGTH: 1 ]
      assert @L.equal? SY::Dimension[ L: 1 ]
      assert @L.equal? SY::Dimension[ { LENGTH: 1 } ]
      assert @L.equal? SY::Dimension[ { L: 1 } ]
      assert SY::Dimension[ L: 1, T: -1 ].equal? @L - @T
      assert SY::Dimension[ "LENGTH.TIME⁻¹" ].equal? @L - @T
      assert SY::Dimension[ "LENGTH.T⁻¹" ].equal? @L - @T
      assert SY::Dimension[ "L.T⁻¹" ].equal? @L - @T
      assert @Z.equal? @L - @L
      assert @Z.equal? @T - @T
      assert SY::Dimension[ "L³" ].equal? @L * 3
    end

    describe "#standard_quantity" do
      it "should return always the same Quantity instance" do
        @Z.standard_quantity.must_be_kind_of SY::Quantity
        assert @Z.standard_quantity
          .equal? ( @L - @L ).standard_quantity
        @L.standard_quantity.must_be_kind_of SY::Quantity
        assert @L.standard_quantity
          .equal? ( SY::Dimension[ L: 2 ] / 2 ).standard_quantity
      end
    end

    describe "#zero?" do
      it "should work as expected" do
        @Z.zero?.must_equal true
        @T.zero?.must_equal false
      end
    end

    describe "#base?" do
      it "should have #base? method" do
        @L.base?.must_equal true
        @T.base?.must_equal true
        @Z.base?.must_equal false
        SY::Dimension[ L: 1, T: -1 ].base?.must_equal false
      end
    end

    describe "#to_sps" do
      it "should return sps (superscripted product string)" do
        @L.to_sps.must_equal "LENGTH"
        @Z.to_sps.must_equal ""
        SY::Dimension[ L: 1, T: -2 ].to_sps
          .must_equal "LENGTH.TIME⁻²"
        @L.to_sps( false ).must_equal "L"
        @Z.to_sps( false ).must_equal ""
        SY::Dimension[ L: 1, T: -2 ].to_sps( false )
          .must_equal "L.T⁻²"
      end
    end

    describe "#to_s method" do
      it "should return short form of Sps" do
        @L.to_s.must_equal "L"
        SY::Dimension[ L: 1, T: -2 ].to_s.must_equal "L.T⁻²"
      end

      it "should return ∅ symbol for zero dimension" do
        @Z.to_s.must_equal "∅"
      end
    end

    describe "#inspect method" do
      it "should return specific strings" do
        @Z.inspect.must_equal "Dimension:∅"
        @L.inspect.must_equal "Dimension:L"
        ( @L - 2 * @T ).inspect.must_equal "Dimension:L.T⁻²"
      end
    end
  end
end
