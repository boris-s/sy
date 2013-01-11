#encoding: utf-8
#! /usr/bin/ruby

# **************************************************************************
# THIS IS SPEC-STYLE TEST FILE FOR SY PHYSICAL UNITS LIBRARY
# **************************************************************************

# The following will load Ruby spec-style library
require 'mathn'
require 'minitest/spec'
require 'minitest/autorun'

# The following will load SY library
require './../lib/sy'

# **************************************************************************
# THE SPECIFICATIONS START HERE
# **************************************************************************

describe SY do
  it "should have basic assets" do
    # Basic physical dimensions:
    SY::BASE_DIMENSIONS.to_a.sort
      .must_equal [ [:L, :LENGTH], [:M, :MASS], [:T, :TIME],
                    [:Q, :ELECTRIC_CHARGE], [:Θ, :TEMPERATURE] ].sort
    
    # Standard unit prefixes:
    SY::PREFIX_TABLE.map{|row| row[:full] }.sort
      .must_equal [ "exa", "peta", "tera", "giga", "mega", "kilo",
                    "mili", "micro", "nano", "pico", "femto", "atto",
                    "hecto", "deka","deci", "centi", "" ].sort
  end
end

describe SY::Dimension do
  it "should" do
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

    # #to_a, #to_hash, #zero?, 
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

describe "expected behavior" do
  it "should" do
    # Length quantity and typical units
    SY::METRE.must_be_kind_of SY::Unit
    SY::METRE.absolute?.must_equal true
    puts
    puts
    puts 1.metre.quantity.composition.to_hash
    puts

    1.metre.absolute.relative?.must_equal false
    1.m
    assert 1.metre.absolute != 1.metre.relative
    1.metre.relative.relative?.must_equal true


    SY::METRE.relative.must_equal 1.metre
    1.m.must_equal 1.metre
    1.m.must_equal 1000.mm
    SY::METRE.quantity.name.must_equal :Length
    assert_in_delta 0.9.µm, 900.nm, 1e-6.nm
    puts [ 1.m, 1.m ].min
    1.m + 1.m == 1.m
    assert_in_epsilon 1.m, 1.m, 0.1
    600.m.must_equal 0.6.km
    SY::METRE.quantity.must_equal SY::Length
    SY::Length.dimension.must_equal SY.Dimension( :L )
    SY.Dimension( :L ).standard_quantity.must_equal SY::Length
    SY::Length.standard_unit.must_equal SY::METRE
    SY::METRE.amount.must_equal 1
    SY::METRE.mili.amount.must_equal 0.001
    3.km.in( :dm ).must_equal 30_000
    ( 1.m + 20.cm ).must_equal 1_200.mm
    assert 1.mm.object_id != 1.mm.object_id
    assert 1.mm == 1.mm
    assert 1.01.m != 1.m
    assert_equal 1, 1.01.m <=> 1.m
    assert_equal 0, 1.00.m <=> 1.m
    assert_equal -1, 0.99.m <=> 1.m
    assert 0.9.mm < 1.mm
    assert 1.1.mm > 1.09.mm
    assert ( 0.1.m - ( 1.m - 0.9.m ) ).abs < 1.nm.abs
    # Mass quantity and typical units
    SY::KILOGRAM.must_be_kind_of SY::Unit
    SY::GRAM.must_be_kind_of SY::Unit
    assert SY::Mass.standard_unit.equal?( SY::KILOGRAM )
    1.kilogram.must_be_kind_of SY::Magnitude
    1.gram.must_be_kind_of SY::Magnitude
    1.kilogram.absolute.quantity.must_equal SY::Mass
    1.gram.absolute.quantity.must_equal SY::Mass
    ( SY::KILOGRAM * 1 ).must_equal SY::GRAM * 1000
    1.kilogram.must_equal 1000.g
    1.kg.to_f.must_equal 1
    1.g.to_f.must_equal 0.001
    1.miligram.must_equal 0.001.g
    1.mg.must_equal 1.miligram
    1.µg.must_equal 0.001.miligram
    1.ng.must_equal 0.001.microgram
    1.pg.quantity.must_equal 0.001.nanogram.quantity
    1.pg.amount.must_be_within_epsilon 0.001.nanogram.amount, 1e-6
    assert_equal 1.g, [1.g, 2.g].min
    assert_equal 1.mg, 1.g * 0.001
    1.pg.abs.must_be_within_epsilon 0.001.nanogram.abs, 1e-6
    SY::TON.must_be_kind_of SY::Unit
    1.ton.must_equal 1000.kg
    1.t.must_equal 1.ton
    1.kt.must_equal 1000.ton
    1.Mt.must_equal 1000.kiloton
    1.mm.quantity.name.must_equal :Length±
    SY::Length.standard_unit.must_equal SY::METRE
    SY::Length.standard_unit.name.must_equal :metre
    SY::Length.Unit.standard.must_equal SY::METRE
    SY.Quantity( :Length ).object_id.must_equal SY::Length.object_id
    SY::Length.relative.object_id.must_equal SY.Quantity( :Length± ).object_id
    SY.Quantity( :Length± ).colleague.name.must_equal :Length
    SY.Quantity( :Length± ).colleague.class.must_equal SY::Quantity
    SY.Quantity( :Length± ).colleague.object_id.must_equal SY::Length.object_id
    SY.Quantity( :Length± ).Unit.object_id.must_equal SY::Length.Unit.object_id
    1.mm.quantity.standard_unit.name.must_equal :metre
    1.mm.to_s.must_equal "0.001.m"
    1.mm.inspect.must_equal "#<±Magnitude: 0.001.m >"
    1.µs.inspect.must_equal "#<±Magnitude: 1e-06.s >"
    SY::AMPERE.name.must_equal :ampere
    SY::AMPERE.abbreviation.must_equal :A
    SY::AMPERE.dimension.must_equal 1.A.dimension
    SY.Magnitude( of: SY::ElectricCurrent, amount: 1 ).must_equal 1.A.absolute
    1.A.quantity.standard_unit.name.must_equal :ampere
    1.A.to_s( SY::AMPERE ).must_equal "1.A"
    1.A.to_s.must_equal "1.A"
    1.A.amount.must_equal 1
    1.A.quantity.standard_unit.abbreviation.must_equal :A
    1.A.inspect.must_equal "#<±Magnitude: 1.A >"

    1.l⁻¹.reframe( SY::Molarity ).quantity.must_equal SY::Molarity
    x = ( SY::Nᴀ / SY::LITRE )
    x = x.reframe( SY::Molarity )
    y = 1.molar.absolute
    y.quantity.must_equal x.quantity
    y.amount.must_equal y.amount
    m = 1.µM
    1.µM.quantity.relative?.must_equal true
    1.µM.quantity.name.must_equal :Molarity±
    1.µM.quantity.absolute.name.must_equal :Molarity
    7.µM.must_be_within_epsilon 5.µM + 2.µM, 1e-6
    +1.s.must_equal 1.s
    # -1.s.must_equal -1 * 1.s # must raise
    assert_equal -(-(1.s)), +(1.s)
    1.s⁻¹.quantity.must_equal ( 1.s ** -1 ).quantity
    1.s⁻¹.amount.must_equal ( 1.s ** -1 ).amount
    1.s⁻¹.must_equal 1.s ** -1
    q1 = ( 1.s⁻¹ ).quantity
    q2 = ( 1 / 1.s ).quantity
    puts q1.composition.to_hash
    puts q2.composition.to_hash
    # q1.object_id.must_equal q2.object_id
    # ( 1.s⁻¹ ).quantity.object_id.must_equal ( 1 / 1.s ).quantity.object_id
    ( 1 / 1.s ).must_equal 1.s⁻¹
    1.s⁻¹.( SY::Frequency ).must_equal 1.Hz
    # 7.°C.must_equal( 8.°C - 1.K )
    # (-15).°C.must_equal 258.15.K
    # 7000.µM.must_be_within_epsilon( 7.mM, 1e-9 )
    ::SY::Unit.instances.map do |i|
      begin
        i.abbreviation
      rescue
      end
    end.must_include :M
    SY::Unit.instance_names.must_include :mole
    # Avogadro's number is defined directly in SY
    1.mol.quantity.object_id.must_equal SY::Nᴀ.( SY::MoleAmount ).quantity.object_id
    SY::Nᴀ.( SY::MoleAmount ).must_equal 1.mol
    0.7.mol.l⁻¹.amount.must_equal 0.7
    q = 1.M.quantity
    1.M.must_equal 1.mol.l⁻¹.( SY::Molarity )
    1.M.must_equal 1.mol.l⁻¹.( SY::Molarity )
    # (if #reframe conversion method is not used, different quantities
    # do not compare. Arithmetics is possible because Magnitude operators
    # mostly give their results only in standard quantities.

    # Avogadro's number is defined directly in SY
    1.mol.must_equal SY::Nᴀ.unit.( SY::MoleAmount )


    0.7.M.must_equal 0.7.mol.l⁻¹.( SY::Molarity )
    # (if #is_actually! conversion method is not used, current
    # implementation will refuse to compare different quantities,
    # even if their dimensions match)

    30.Hz.must_equal 30.s⁻¹.( SY::Frequency )

    # Dalton * Avogadro must be 1 gram
    ( 1.Da * SY::Nᴀ ).must_be_within_epsilon( 1.g, 1e-6 )

    # kilogram
    1.kg.must_equal 1000.g
    ( 1.kg * 1.m.s⁻² ).( SY::Force ).must_be_within_epsilon 1.N, 1e-9

    # joule
    ( 1.N * 1.m ).( SY::Energy ).must_equal 1.J
    1e-23.J.K⁻¹.must_equal 1.0e-20.mJ.K⁻¹


    # pascal
    ( 1.N / 1.m ** 2 ).( SY::Pressure ).must_be_within_epsilon 1.Pa, 1e-9

    # watt
    ( 1.V * 1.A ).( SY::Power ).must_be_within_epsilon 1.W, 1e-9

    # pretty representation
    ( 1.m / 3.s ).to_s.must_equal( "0.333.m.s⁻¹" )
    ( 1.m / 7.01e7.s ).to_s.must_equal( "1.43e-08.m.s⁻¹" )

    puts ( 1.m.s⁻¹ * 1.s ).quantity.composition.to_hash
    assert_equal 1.m, 1.s * 1.m.s⁻¹

    assert_equal Matrix[[1.m]], Matrix[[1.m.s⁻¹, 2.m.s⁻¹]] * Matrix.column_vector( [1.s, 2.s] )
  end
end
