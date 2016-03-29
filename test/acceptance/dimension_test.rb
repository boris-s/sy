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
        skip
        @L[ "TIME" ].must_equal 0
        @L[ :M ].must_equal
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
        skip
        @L.values_at( :L, :T ).must_equal [ 1, 0 ]
        @L.values_at( "LENGTH", "T", :TEMPERATURE, :M ).must_equal [ 1, 0, 0, 0 ]
      end

      it "should have #== method working as expected" do
        flunk "Test not written!"
        # FIXME #== method
      end

      it "should not allow #merge/#merge! method ... " do
        # FIXME: to construct abnormal dimensions,
        # neither it should be possible with other Hash-inherited methods
        flunk "Test not written! #merge method is crucial for dimension arithmetics!"
      end
    end

    describe "dimension arithmetics" do
      describe "negation" do
        it "should negate the exponents" do
          ( -@L ).must_equal SY::Dimension[ L: -1 ]
          ( -@Z ).must_equal @Z
        end

        it "should always return the same object for the same dimension" do
          skip
          ( -SY::Dimension[ "L.T⁻¹" ] ).object_id
            .must_equal SY::Dimension[ "T.L⁻¹" ].object_id
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
          skip
          ( SY::Dimension[ "L.M.T⁻¹" ] + SY::Dimension[ "Q.L²" ] ).object_id
                  .must_equal SY::Dimension[ "M.Q.L³.T⁻¹" ].object_id
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
          skip
          ( SY::Dimension[ "M.Q.L³.T⁻¹" ] - SY::Dimension[ "Q.L²" ] ).object_id
            .must_equal SY::Dimension[ "L.M.T⁻¹" ].object_id
        end
      end

      describe "coercion for the purposes of multiplication by an integer" do
        it "should have #coerce method allowing multiplication by an integer" do
          flunk "Test not written!"
        end
      end

      describe "multiplication by an integer" do
        it "should multiply the exponents by an integer" do
          skip
          ( @L * 0 ).must_equal @Z
          ( @L * 1 ).must_equal @L
          ( @L * 3 ).must_equal SY::Dimension[ "L³" ]
        end

        it "should always return the same object for the same dimension" do
          skip
          ( SY::Dimension[ "L.T⁻¹" ] * 2 ).object_id
            .must_equal SY::Dimension[ "L²T⁻²" ].object_id
        end
        
        it "should reject non-integer operands" do
          skip
          -> { @L * 2.5 }.must_raise TypeError
        end
        
        it "should also allow the first operand to be integer" do
          skip
          ( 0 * @T ).must_equal @Z
          ( 1 * @T ).must_equal @T
          ( -2 * SY::Dimension[ "L.T⁻¹" ] ).must_equal SY::Dimension[ "T².L⁻²" ]
        end
      end
      
      describe "division by an integer" do
        it "should divide the exponents by the operand when all are divisible" do
          skip
          ( @Z / 2 ).must_equal @Z
          ( @L / 1 ).must_equal @L
          ( SY::Dimension[ "L³" ] / 3 ).must_equal @L
        end

        it "should always return the same object for the same dimension" do
          skip
          ( SY::Dimension[ "L⁴.M⁴" ] / 2 ).object_id
            .must_equal SY::Dimension[ "L².M²" ].object_id
        end

        it "should reject non-integer divisor" do
          skip
          -> { @L / 1.0 }.must_raise TypeError
        end
        
        it "should reject the divisor if any of the exponents not divisible" do
          skip
          -> { SY::Dimension[ L: 3 ] / 2 }.must_raise TypeError
        end
      end
    end

    it "should always return the same instance for the same dimension" do
      @Z.object_id.must_equal SY::Dimension.zero.object_id
      skip
      assert @Z.equal SY::Dimension[ {} ]
      assert @L.equal SY::Dimension[ :LENGTH ]
      assert @L.equal SY::Dimension[ "LENGTH" ]
      assert @L.equal SY::Dimension[ "L" ]
      assert @L.equal SY::Dimension[ LENGTH: 1 ]
      assert @L.equal SY::Dimension[ L: 1 ]
      assert @L.equal SY::Dimension[ { LENGTH: 1 } ]
      assert @L.equal SY::Dimension[ { L: 1 } ]
      assert SY::Dimension[ L: 1, T: -1 ].equal @L - @T
      assert SY::Dimension[ "LENGTH.TIME⁻¹" ].equal @L - @T
      assert SY::Dimension[ "LENGTH.T⁻¹" ].equal @L - @T
      assert SY::Dimension[ "L.T⁻¹" ].equal @L - @T
      assert @Z.equal @L - @L
      assert @Z.equal @T - @T
      assert SY::Dimension[ "L³" ].equal @L * 3
    end

    it "should have other features" do # these were old tests
      skip
      # #to_a, #to_hash, #zero?
      ll = SY::BASE_DIMENSIONS.letters
      SY.Dimension( :M ).to_a.must_equal ll.map { |l| l == :M ? 1 : 0 }
      SY.Dimension( :M ).to_hash.must_equal Hash[ ll.zip SY.Dimension( :M ).to_a ]
      SY.Dimension( :M ).zero?.must_equal false
      SY::Dimension.zero.zero?.must_equal true
      SY.Dimension( nil ).to_a.must_equal [ 0, 0, 0, 0, 0 ]
    end
  end
end
