#! /usr/bin/ruby
# encoding: utf-8

# **************************************************************************
# Unit tests for file sy/se.rb.
#
# File se.rb defines class Se (superscripted exponent), which is used in
# construction of Sps (superscripted product string), such as "kg.m.s⁻²".
# Se is a subclass of String, which represents strings such as "⁰", "¹",
# "²", "⁴²", "⁻⁴²". Specification of its main features is below.
# **************************************************************************

require_relative 'test_loader'
require_relative '../../lib/sy/se'
require_relative '../../lib/sy/sps'
require_relative '../../lib/sy/dimension'

describe "sy/dimension.rb" do
  it "should define basic physical dimensions" do
    # FIXME: Base dimension can now be found under
    # SY::Dimension::BASE.
    SY::Dimension::BASE.to_a.sort
      .must_equal [ [:L, :LENGTH], [:M, :MASS], [:T, :TIME],
                    [:Q, :ELECTRIC_CHARGE], [:Θ, :TEMPERATURE] ].sort
  end

  it "should have the registry of instances" do
    SY::Dimension.instances.must_be_kind_of Array
  end

  it "should have .[] constructor accepting variable input" do
    SY::Dimension[ :LENGTH ].must_be_kind_of SY::Dimension
    SY::Dimension[ "LENGTH" ].must_be_kind_of SY::Dimension
    SY::Dimension[ L: 1, T: -1 ].must_be_kind_of SY::Dimension
    SY::Dimension[ { L: 1, T: -1 } ].must_be_kind_of SY::Dimension
    SY::Dimension[ "L.T⁻¹" ].must_be_kind_of SY::Dimension
  end

  it "should have .zero constructor for zero dimension" do
    SY::Dimension.zero.values.must_equal SY::Dimension::BASE.map { 0 }
  end

  # FIXME: Go ahead through dimension.rb and write the unit tests.
  # 
  it "old tests" do
    skip
    # Dimension#new should return same instance when asked twice.
    
    assert_equal *[ :L, :L ].map { |d| SY::Dimension.new( d ).object_id }

    # Other Dimension constructors: #basic and #zero.
    SY::Dimension.basic( :L ).must_equal SY.Dimension( :L )
    SY::Dimension.zero.must_equal SY::Dimension.new( '' )

    # SY should have table of standard quantities.
    assert SY.Dimension( :L ).standard_quantity.is_a? SY::Quantity

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
end
