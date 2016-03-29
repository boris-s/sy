#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for SY, a Ruby library of physical units.
#
# This file gradually runs all unit tests for SY.
# **************************************************************************

# ACCEPTANCE TESTS
describe SY::Dimension do
  before do
    skip
    ldim = SY::Dimension[ :LENGTH ]
    # FIXME: Currently the missing "to_hash" method in
    # SY::Sps is the problem of this base class not actually
    # being customized to handle Sps-es representing Dimension.
    # I think that a custom subclass would be good, but I don't
    # know where: In dimension.rb? or in a subdirectory?
    tdim = SY::Dimension[ :TIME ]
  end

  # FIXME: Go ahead through dimension.rb and write the unit tests.
  # 
  it "old tests" do
    skip

    # Instances should provide access to base dimensions.
    assert_equal [0, 1], [:L, :M].map { |ß| SY.Dimension( :M ).send ß }
    assert_equal [1, 0], [:L, :M].map { |ß| SY.Dimension( :L )[ß] }

    # #to_a, #to_hash, #zero?
    ll = SY::BASE_DIMENSIONS.letters
    SY.Dimension( :M ).to_a.must_equal ll.map { |l| l == :M ? 1 : 0 }
    SY.Dimension( :M ).to_hash.must_equal Hash[ ll.zip SY.Dimension( :M ).to_a ]
    SY.Dimension( :M ).zero?.must_equal false
    SY::Dimension.zero.zero?.must_equal true
    SY.Dimension( nil ).to_a.must_equal [ 0, 0, 0, 0, 0 ]

    # Dimension arithmetic
    assert SY.Dimension( :L ) + SY.Dimension( :M ) == SY.Dimension( 'L.M' )
    assert SY.Dimension( :L ) - SY.Dimension( :M ) == SY.Dimension( 'L.M⁻¹' )
    assert SY.Dimension( :L ) * 2 == SY.Dimension( 'L²' )
    assert SY.Dimension( M: 2 ) / 2 == SY.Dimension( :M )
  end

  it "should be a subclass of Hash" do
    SY::Dimension.ancestors.must_include Hash
  end

  describe "dimension arithmetics" do
    describe "addition" do
      it "should add the exponents of the operands" do
        # FIXME
      end
    end

    describe "subtraction" do
      it "should subtract the exponents of the operands" do
        # FIXME
      end
    end

    describe "multiplication by an integer" do
      it "should multiply the exponents by an integer" do
        # FIXME
      end

      it "should reject non-integer operands" do
        # FIXME
      end

      it "should also allow the first operand to be integer" do
        # FIXME: such as 2 * Dimension[ :L ]
      end
    end

    describe "division by an integer" do
      it "should divide the exponents by the operand when all are divisible" do
        # FIXME
      end

      it "should reject non-integer divisor" do
        # FIXME
      end

      it "should reject the divisor if any of the exponents not divisible" do
        # FIXME
      end
    end
  end

  it "should always give the same instance for the same dimension" do
    assert SY::Dimension[ :L ].equal ldim
    # FIXME: And other similar tests of the .[] constructor so forth
    assert SY::Dimension[ L: 1, T: -1 ].equal ldim - 2 * tdim
    # And so forth.
  end

  describe "similarities and differences to its parent Hash" do
    it "should reject .new method" do
      -> { SY::Dimension.new( :L ) }.must_raise NoMethodError
    end

    it "should have #== method working as expected" do
      # FIXME #== method
    end

    it "should not allow #merge/#merge! method ... " do
      # FIXME to construct abnormal dimensions,
      # neither it should be possible with other Hash-inherited methods
    end
  end
end

describe "sy gem" do
  it "should give method name collision warning" do
    # warn if prospective unit method name already defined
  end

  it "should give redefine warning" do
    # 
  end
end
