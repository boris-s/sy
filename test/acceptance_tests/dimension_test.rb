#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Acceptance tests for SY::Dimension.
# **************************************************************************

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
      @full_symbols = :LENGTH, :TIME, :MASS, :TEMPERATURE, :ELECTRIC_CHARGE
      @short_symbols = :L, :T, :M, :Θ, :Q
      @full_strings = @full_symbols.map &:to_s
      @short_strings = @short_symbols.map &:to_s
      # Set up some sample dimensions.
      @L = SY::Dimension[ :LENGTH ]
      @T = SY::Dimension[ :TIME ]
      @M = SY::Dimension[ :MASS ]
      @Z = SY::Dimension.zero
    end

    describe "hash-like behavior" do
      it "should have #[] method returning the exponents of base dimensions" do
        @L[ :LENGTH ].must_equal 1
        @L[ "TIME" ].must_equal 0
        @L[ :M ].must_equal 0
        @L[ "Θ" ].must_equal 0
        @full_symbols.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
        @full_symbols.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
        @full_symbols.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
        @full_symbols.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
        @short_symbols.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
        @short_symbols.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
        @short_symbols.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
        @short_symbols.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
        @full_strings.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
        @full_strings.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
        @full_strings.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
        @full_strings.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
        @short_strings.map { |s| @L[s] }.must_equal [ 1, 0, 0, 0, 0 ]
        @short_strings.map { |s| @T[s] }.must_equal [ 0, 1, 0, 0, 0 ]
        @short_strings.map { |s| @M[s] }.must_equal [ 0, 0, 1, 0, 0 ]
        @short_strings.map { |s| @Z[s] }.must_equal [ 0, 0, 0, 0, 0 ]
        -> { @L[ :FOOBAR ] }.must_raise TypeError
      end

      it "should have #values_at method accepting variable notation" do
        @L.values_at( *@full_symbols ).must_equal [ 1, 0, 0, 0, 0 ]
        @L.values_at( :L, :T ).must_equal [ 1, 0 ]
        @L.values_at( "LENGTH", "T", :TEMPERATURE, :M ).must_equal [ 1, 0, 0, 0 ]
      end

      it "should have #== method working as expected" do
        ( @Z == @Z ).must_equal true
        ( @L == SY::Dimension[ :LENGTH ] ).must_equal true
        ( @L == SY::Dimension[ :MASS ] ).must_equal false
        ( @L == { FOO: 1, BAR: 0 } ).must_equal false
        ( @L == [ :FOO, :BAR ] ).must_equal false
        ( [ :FOO, :BAR ] == @L ).must_equal false
      end

      describe "#merge method" do
        it "should only accept Dimension-type arguments" do
          @L.merge( @Z ).must_equal @Z
          -> { @L.merge FOO: 1 }.must_raise TypeError
        end

        it "should return always the same instance for the same dimension" do
          assert @L.merge( @Z ).equal? @Z
          assert @Z.merge( @T ).equal? @T
          assert ( @T.merge @T do |_, a, b| 0 end ).equal? @Z
        end
      end

      it "should have disabled #merge! and #[]= methods" do
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

        it "should always return the same object for the same dimension" do
          assert ( -SY::Dimension[ "L.T⁻¹" ] ).equal? SY::Dimension[ "T.L⁻¹" ]
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

        it "should always return the same object for the same dimension" do
          assert SY::Dimension[ "M.Q.L³.T⁻¹" ]
                  .equal? SY::Dimension[ "L.M.T⁻¹" ] + SY::Dimension[ "Q.L²" ]
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

        it "should always return the same object for the same dimension" do
          assert ( SY::Dimension[ "M.Q.L³.T⁻¹" ] - SY::Dimension[ "Q.L²" ] )
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

        it "should always return the same object for the same dimension" do
          assert SY::Dimension[ "L².T⁻²" ].equal? SY::Dimension[ "L.T⁻¹" ] * 2
        end
        
        it "should reject non-integer operands" do
          -> { @L * 2.5 }.must_raise TypeError
        end
        
        it "should also allow the first operand to be integer" do
          ( 0 * @T ).must_equal @Z
          ( 1 * @T ).must_equal @T
          ( -2 * SY::Dimension[ "L.T⁻¹" ] ).must_equal SY::Dimension[ "T².L⁻²" ]
        end
      end
      
      describe "division by an integer" do
        it "should divide the exponents by the operand when all are divisible" do
          ( @Z / 2 ).must_equal @Z
          ( @L / 1 ).must_equal @L
          ( SY::Dimension[ "L³" ] / 3 ).must_equal @L
        end

        it "should always return the same object for the same dimension" do
          ( SY::Dimension[ "L⁴.M⁴" ] / 2 ).object_id
            .must_equal SY::Dimension[ "L².M²" ].object_id
        end

        it "should reject non-integer divisor" do
          -> { @L / 1.0 }.must_raise TypeError
        end
        
        it "should reject the divisor if any of the exponents not divisible" do
          -> { SY::Dimension[ L: 3 ] / 2 }.must_raise TypeError
        end
      end
    end

    it "should always return the same instance for the same dimension" do
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

    describe "#standard_quantity method" do
      it "should return always the same Quantity instance" do
        @Z.standard_quantity.must_be_kind_of SY::Quantity
        @Z.standard_quantity.object_id
          .must_equal ( @L - @L ).standard_quantity.object_id
        @L.standard_quantity.must_be_kind_of SY::Quantity
        @L.standard_quantity.object_id
          .must_equal ( SY::Dimension[ L: 2 ] / 2 ).standard_quantity.object_id
      end
    end

    it "should have #zero? method" do
      @Z.zero?.must_equal true
      @T.zero?.must_equal false
    end

    it "should have #base? method" do
      @L.base?.must_equal true
      @T.base?.must_equal true
      @Z.base?.must_equal false
      SY::Dimension[ L: 1, T: -1 ].base?.must_equal false
    end

    it "should have #to_sps method (superscripted product string)" do
      @L.to_sps.must_equal "LENGTH"
      @Z.to_sps.must_equal ""
      SY::Dimension[ L: 1, T: -2 ].to_sps.must_equal "LENGTH.TIME⁻²"
      @L.to_sps( false ).must_equal "L"
      @Z.to_sps( false ).must_equal ""
      SY::Dimension[ L: 1, T: -2 ].to_sps( false ).must_equal "L.T⁻²"
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
